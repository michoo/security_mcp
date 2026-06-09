#!/usr/bin/env python3
"""Command-line entrypoint to run a full (or partial) security scan and emit a
consolidated, dated report in Markdown, JSON and HTML under reports/.

Two modes, auto-detected from the target:
  - static  : target is a local directory  -> SCA / Secret / SAST / Pipeline tools
  - dynamic : target is an http(s) URL      -> DAST tools (nuclei, zaproxy)

Examples:
  uv run python cli.py ./myproject
  uv run python cli.py ./myproject --tools trivy,gitleaks,codeql --language python
  uv run python cli.py https://example.com --formats md,html
  uv run python cli.py --list
"""
import argparse
import asyncio
import os
import sys
import time
from collections import Counter
from datetime import datetime
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(REPO_ROOT))
os.chdir(REPO_ROOT)  # scanners reference ./tools/... relative to the repo root

from scanners import SCANNERS, BY_NAME, STATIC, DYNAMIC, scanners_for_mode, docker_image_present, ZAP_IMAGE  # noqa: E402
import report as report_mod  # noqa: E402
from aggregate import deduplicate  # noqa: E402
from config import scanner_enabled, env_var_for  # noqa: E402

# Scanners signal "ran but not applicable / prerequisite missing" with this prefix.
SKIP_PREFIX = "SKIPPED:"

# Tool-native phrases that also mean a benign skip rather than a hard error.
_SKIP_MARKERS = (
    "command not found", "is not installed", "not available", "is required",
    "unsupported language", "no package sources", "could not determine the provider",
    "not a git repository", "no workflows", "configuration file not found", "timed out",
)

_EXT_TO_LANG = {
    ".py": "python", ".js": "javascript", ".jsx": "javascript", ".ts": "javascript",
    ".tsx": "javascript", ".java": "java", ".kt": "java", ".go": "go", ".rb": "ruby",
    ".cs": "csharp", ".c": "cpp", ".cc": "cpp", ".cpp": "cpp", ".h": "cpp", ".hpp": "cpp",
    ".rs": "rust", ".swift": "swift",
}


def detect_language(directory: str) -> str | None:
    """Pick the most common CodeQL-supported language by file extension."""
    counts = Counter()
    for root, _dirs, files in os.walk(directory):
        if "/.git" in root or "/node_modules" in root:
            continue
        for f in files:
            lang = _EXT_TO_LANG.get(Path(f).suffix.lower())
            if lang:
                counts[lang] += 1
    return counts.most_common(1)[0][0] if counts else None


def classify_outcome(text: str, parse_error: str | None):
    """Return (status, reason). For 'ok', reason is None; otherwise reason is the
    scanner's own message explaining the skip/error (cleaned and truncated)."""
    if not parse_error:
        return "ok", None
    raw = (text or "").strip()
    low = raw.lower()
    if raw.startswith(SKIP_PREFIX):
        return "skipped", raw[len(SKIP_PREFIX):].strip()
    reason = (raw[:300] or parse_error)
    if any(marker in low for marker in _SKIP_MARKERS):
        return "skipped", reason
    return "error", reason


def preflight_skip(scanner) -> str | None:
    """Return a skip reason if a scanner's prerequisites are missing, else None.
    Avoids surprises like zaproxy triggering a multi-GB image pull mid-scan."""
    if scanner.name == "zaproxy" and not docker_image_present(ZAP_IMAGE):
        return f"ZAP docker image not present ({ZAP_IMAGE}); run tools/dast/zaproxy/install.sh"
    return None


async def run_scanner(scanner, target, language, raw_dir) -> dict:
    """Run one scanner, persist its raw output, return a per-tool result dict."""
    print(f"  ▶ {scanner.name:14} ({scanner.family}) ...", flush=True)

    skip = preflight_skip(scanner)
    if skip:
        print(f"      {'skipped':8} {skip}", flush=True)
        return {"name": scanner.name, "family": scanner.family, "status": "skipped",
                "duration": 0.0, "findings": [], "severity_counts": {}, "error": skip}

    started = time.perf_counter()
    error = None
    text = ""
    try:
        out = await scanner.run(target, language=language)
        text = out[0].text if out else ""
    except Exception as e:  # noqa: BLE001
        error = f"{type(e).__name__}: {e}"
    duration = time.perf_counter() - started

    parsed = report_mod.extract_findings(scanner.name, scanner.fmt, text) if not error else {
        "findings": [], "severity_counts": {}, "parse_error": error,
    }
    if error:
        status, reason = "error", error
    else:
        status, reason = classify_outcome(text, parsed.get("parse_error"))

    # persist raw output (only when it is an actual report, not a skip/error message)
    if text and status == "ok":
        ext = "sarif" if scanner.fmt == "sarif" else "json"
        (raw_dir / f"{scanner.name}.{ext}").write_text(text, encoding="utf-8")

    findings = parsed.get("findings", [])
    if status == "ok":
        print(f"      ok       {len(findings)} finding(s) in {duration:.1f}s", flush=True)
    else:
        detail = (reason or "").replace("\n", " ")[:90]
        print(f"      {status:8} {detail} ({duration:.1f}s)", flush=True)
    return {
        "name": scanner.name,
        "family": scanner.family,
        "status": status,
        "duration": duration,
        "findings": findings,
        "severity_counts": parsed.get("severity_counts", {}),
        "error": reason if status != "ok" else None,
    }


async def run_scan(args) -> int:
    target = args.target
    # auto-detect mode
    is_url = target.startswith("http://") or target.startswith("https://")
    mode = args.mode or (DYNAMIC if is_url else STATIC)

    if mode == STATIC:
        target_abs = str(Path(target).resolve())
        if not Path(target_abs).is_dir():
            print(f"error: static target is not a directory: {target}", file=sys.stderr)
            return 2
        target = target_abs
    selected = scanners_for_mode(mode)

    # subset via --tools
    if args.tools:
        wanted = [t.strip() for t in args.tools.split(",") if t.strip()]
        unknown = [t for t in wanted if t not in BY_NAME]
        if unknown:
            print(f"error: unknown tool(s): {', '.join(unknown)}", file=sys.stderr)
            return 2
        disabled = [t for t in wanted if not scanner_enabled(t)]
        if disabled:
            print(f"  (skipping tool(s) disabled via environment: "
                  f"{', '.join(f'{t} [{env_var_for(t)}]' for t in disabled)})")
        wanted = [t for t in wanted if t not in disabled]
        selected = [s for s in selected if s.name in wanted]
        # honor tools from the other mode only if explicitly requested
        extra = [BY_NAME[t] for t in wanted if BY_NAME[t].mode != mode]
        selected = list({s.name: s for s in selected + extra}.values())
    if not selected:
        print(f"error: no scanners selected for mode '{mode}'", file=sys.stderr)
        return 2

    # language for codeql (static)
    language = args.language
    if any(s.needs_language for s in selected) and not language and mode == STATIC:
        language = detect_language(target)
        if language:
            print(f"  (auto-detected language for codeql: {language})")
        else:
            print("  (no CodeQL-supported language detected; codeql will be skipped)")
            selected = [s for s in selected if not s.needs_language]

    # output dir
    started_at = datetime.now()
    stamp = started_at.strftime("%Y%m%d-%H%M%S")
    out_dir = Path(args.output_dir) / f"scan_{stamp}_{mode}"
    raw_dir = out_dir / "raw"
    raw_dir.mkdir(parents=True, exist_ok=True)

    print(f"\nScanning [{mode}] target: {target}")
    print(f"Tools: {', '.join(s.name for s in selected)}\n")

    scan_start = time.perf_counter()
    tool_results = []
    for scanner in selected:
        tool_results.append(await run_scanner(scanner, target, language or "python", raw_dir))
    scan_seconds = time.perf_counter() - scan_start

    # optional cross-tool deduplication
    deduped = None
    if args.dedupe:
        tagged = [{**f, "tools": [t["name"]]} for t in tool_results for f in t.get("findings", [])]
        deduped = deduplicate(tagged)
        print(f"\nDeduplicated: {len(deduped)} unique finding(s) "
              f"from {len(tagged)} raw ({len(tagged) - len(deduped)} duplicate(s) removed)")

    # build + render report
    report_start = time.perf_counter()
    meta = {
        "mode": mode,
        "target": target,
        "generated_at": started_at.strftime("%Y-%m-%d %H:%M:%S"),
        "scan_seconds": scan_seconds,
        "report_seconds": 0.0,   # filled in below
        "total_seconds": 0.0,
    }
    data = report_mod.build_report(meta, tool_results, deduped)

    formats = [f.strip() for f in args.formats.split(",") if f.strip()]
    written = []
    if "json" in formats:
        (out_dir / "report.json").write_text(report_mod.render_json(data), encoding="utf-8")
        written.append(out_dir / "report.json")
    if "md" in formats:
        (out_dir / "report.md").write_text(report_mod.render_markdown(data), encoding="utf-8")
        written.append(out_dir / "report.md")
    if "html" in formats:
        (out_dir / "report.html").write_text(report_mod.render_html(data), encoding="utf-8")
        written.append(out_dir / "report.html")

    report_seconds = time.perf_counter() - report_start
    meta["report_seconds"] = report_seconds
    meta["total_seconds"] = scan_seconds + report_seconds
    # re-render so the durations are accurate in the files
    data = report_mod.build_report(meta, tool_results, deduped)
    if "json" in formats:
        (out_dir / "report.json").write_text(report_mod.render_json(data), encoding="utf-8")
    if "md" in formats:
        (out_dir / "report.md").write_text(report_mod.render_markdown(data), encoding="utf-8")
    if "html" in formats:
        (out_dir / "report.html").write_text(report_mod.render_html(data), encoding="utf-8")

    s = data["summary"]
    print(f"\n=== Done in {meta['total_seconds']:.1f}s — {s['total_findings']} finding(s) "
          f"across {s['tools_run']} tool(s) ===")
    print("Reports written to:")
    for p in written:
        print(f"  - {p}")
    print(f"Raw outputs: {raw_dir}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(prog="cli.py", description="Run security scanners and produce a consolidated report.")
    p.add_argument("target", nargs="?", help="directory (static mode) or http(s) URL (dynamic mode)")
    p.add_argument("--mode", choices=[STATIC, DYNAMIC], help="override auto-detected mode")
    p.add_argument("--tools", help="comma-separated subset of tools (default: all for the mode)")
    p.add_argument("--language", help="source language for codeql (auto-detected if omitted)")
    p.add_argument("--dedupe", action="store_true", help="add a cross-tool deduplicated findings section to the report")
    p.add_argument("--formats", default="md,json,html", help="report formats to write (default: md,json,html)")
    p.add_argument("--output-dir", default=str(REPO_ROOT / "reports"), help="reports output directory (default: ./reports)")
    p.add_argument("--list", action="store_true", help="list available tools and exit")
    return p


def main() -> int:
    args = build_parser().parse_args()
    if args.list:
        print("Available scanners:")
        for s in SCANNERS:
            lang = " (needs --language)" if s.needs_language else ""
            status = "" if scanner_enabled(s.name) else f"  [DISABLED via {env_var_for(s.name)}]"
            print(f"  {s.name:14} {s.family:9} {s.mode:8} -> {s.fmt}{lang}{status}")
        return 0
    if not args.target:
        print("error: a target (directory or URL) is required (or use --list)", file=sys.stderr)
        return 2
    return asyncio.run(run_scan(args))


if __name__ == "__main__":
    sys.exit(main())