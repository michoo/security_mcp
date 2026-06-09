"""Run every scanner of a given mode, then collect, aggregate and deduplicate
their findings into a single consolidated report.

This backs the two high-level MCP tools:
  - static  : runs all STATIC scanners against a local directory
  - dynamic : runs all DYNAMIC (DAST) scanners against an http(s) URL

Each individual scanner already emits SARIF/JSON; report.extract_findings()
normalizes that into flat findings ({rule, severity, message, location}). Here
we run them all, merge their findings, and collapse duplicates that several
scanners (or several runs of one scanner) report for the same issue.

Deduplication is deliberately conservative: a finding's identity is its
(location, message). Location is never dropped, and two genuinely different
secrets live at different file:line locations, so distinct secret values are
always preserved — the merge only ever unions the *tools* that reported the
same value at the same place.
"""
import os
import time
from collections import Counter
from datetime import datetime
from pathlib import Path
from typing import List, Optional

import report as report_mod
from report import SEVERITY_ORDER
from scanners import (
    STATIC,
    DYNAMIC,
    ZAP_IMAGE,
    scanners_for_mode,
    docker_image_present,
)

# Reports are written here by default, anchored to the repo root so the
# location is ./reports regardless of the process's current directory.
REPO_ROOT = Path(__file__).resolve().parent
DEFAULT_REPORTS_DIR = REPO_ROOT / "reports"
DEFAULT_FORMATS = ("md", "json", "html")

# Mirrors cli.py: a scanner signals a benign "ran but not applicable" this way.
SKIP_PREFIX = "SKIPPED:"
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


def detect_language(directory: str) -> Optional[str]:
    """Pick the most common CodeQL-supported language by file extension."""
    counts: Counter = Counter()
    for root, _dirs, files in os.walk(directory):
        if "/.git" in root or "/node_modules" in root:
            continue
        for f in files:
            lang = _EXT_TO_LANG.get(Path(f).suffix.lower())
            if lang:
                counts[lang] += 1
    return counts.most_common(1)[0][0] if counts else None


def _classify_outcome(text: str, parse_error: Optional[str]):
    """(status, reason). status is one of ok/skipped/error."""
    if not parse_error:
        return "ok", None
    raw = (text or "").strip()
    low = raw.lower()
    if raw.startswith(SKIP_PREFIX):
        return "skipped", raw[len(SKIP_PREFIX):].strip()
    reason = raw[:300] or parse_error
    if any(marker in low for marker in _SKIP_MARKERS):
        return "skipped", reason
    return "error", reason


def _preflight_skip(scanner) -> Optional[str]:
    if scanner.name == "zaproxy" and not docker_image_present(ZAP_IMAGE):
        return f"ZAP docker image not present ({ZAP_IMAGE}); run tools/dast/zaproxy/install.sh"
    return None


async def _run_one(scanner, target: str, language: str) -> dict:
    """Run a single scanner and return a per-tool result with its findings."""
    skip = _preflight_skip(scanner)
    if skip:
        return {"name": scanner.name, "family": scanner.family, "status": "skipped",
                "duration": 0.0, "findings": [], "error": skip}

    started = time.perf_counter()
    error = None
    text = ""
    try:
        out = await scanner.run(target, language=language)
        text = out[0].text if out else ""
    except Exception as e:  # noqa: BLE001
        error = f"{type(e).__name__}: {e}"
    duration = time.perf_counter() - started

    if error:
        parsed = {"findings": [], "severity_counts": {}, "parse_error": error}
        status, reason = "error", error
    else:
        parsed = report_mod.extract_findings(scanner.name, scanner.fmt, text)
        status, reason = _classify_outcome(text, parsed.get("parse_error"))

    # tag each finding with the scanner that produced it (used when merging)
    findings = []
    for f in parsed.get("findings", []) if status == "ok" else []:
        findings.append({**f, "tools": [scanner.name]})

    return {
        "name": scanner.name,
        "family": scanner.family,
        "status": status,
        "duration": round(duration, 2),
        "findings": findings,
        "severity_counts": parsed.get("severity_counts", {}) if status == "ok" else {},
        "error": reason if status != "ok" else None,
    }


def _severity_rank(sev: str) -> int:
    try:
        return SEVERITY_ORDER.index(sev)
    except ValueError:
        return len(SEVERITY_ORDER)


def _finding_key(f: dict):
    """Identity used for deduplication.

    Location is the strongest signal; the (whitespace-normalized) message
    disambiguates several distinct findings on the same line. Severity and
    rule id are intentionally excluded so the *same* issue reported by
    different tools — which often disagree on rule id and severity wording —
    still merges into one entry."""
    loc = (f.get("location") or "").strip().lower()
    msg = " ".join((f.get("message") or "").split()).lower()
    return loc, msg


def deduplicate(findings: List[dict]) -> List[dict]:
    """Collapse duplicate findings, keeping the highest severity and unioning
    the contributing tools and rule ids. Location is always preserved."""
    merged: dict = {}
    for f in findings:
        key = _finding_key(f)
        cur = merged.get(key)
        if cur is None:
            merged[key] = {
                "rule": f.get("rule", ""),
                "rules": sorted({f.get("rule", "")} - {""}),
                "severity": f.get("severity", "medium"),
                "message": f.get("message", ""),
                "location": f.get("location", ""),
                "tools": sorted(set(f.get("tools", []))),
                "occurrences": 1,
            }
            continue
        cur["occurrences"] += 1
        cur["tools"] = sorted(set(cur["tools"]) | set(f.get("tools", [])))
        if f.get("rule"):
            cur["rules"] = sorted(set(cur["rules"]) | {f["rule"]})
        if _severity_rank(f.get("severity", "")) < _severity_rank(cur["severity"]):
            cur["severity"] = f["severity"]
            cur["rule"] = f.get("rule", cur["rule"])
    out = list(merged.values())
    out.sort(key=lambda f: (_severity_rank(f["severity"]), f["location"]))
    return out


async def _run_all(mode: str, target: str, language: Optional[str] = None):
    """Run every scanner for `mode` sequentially. Returns (tool_results,
    scan_seconds, language) — each tool result carries its full findings list."""
    selected = scanners_for_mode(mode)

    if mode == STATIC and any(s.needs_language for s in selected):
        language = language or detect_language(target)
        if not language:
            selected = [s for s in selected if not s.needs_language]

    scan_start = time.perf_counter()
    tool_results = []
    for scanner in selected:
        tool_results.append(await _run_one(scanner, target, language or "python"))
    return tool_results, time.perf_counter() - scan_start, language


async def run_aggregated_scan(mode: str, target: str, language: Optional[str] = None) -> dict:
    """Run all scanners for `mode`, then return a compact deduplicated summary
    dict (per-tool finding counts only — not the full findings)."""
    tool_results, scan_seconds, language = await _run_all(mode, target, language)

    all_findings = [f for t in tool_results for f in t["findings"]]
    deduped = deduplicate(all_findings)

    severity_totals = {s: 0 for s in SEVERITY_ORDER}
    for f in deduped:
        severity_totals[f["severity"]] = severity_totals.get(f["severity"], 0) + 1

    statuses = Counter(t["status"] for t in tool_results)
    return {
        "mode": mode,
        "target": target,
        "language": language if mode == STATIC else None,
        "summary": {
            "tools_run": len(tool_results),
            "tools_ok": statuses.get("ok", 0),
            "tools_skipped": statuses.get("skipped", 0),
            "tools_error": statuses.get("error", 0),
            "raw_findings": len(all_findings),
            "deduplicated_findings": len(deduped),
            "duplicates_removed": len(all_findings) - len(deduped),
            "severity_totals": severity_totals,
            "scan_seconds": round(scan_seconds, 1),
        },
        "tools": [
            {k: t[k] for k in ("name", "family", "status", "duration", "error")}
            | {"findings": len(t["findings"])}
            for t in tool_results
        ],
        "findings": deduped,
    }


def _write_reports(out_dir: Path, data: dict, formats) -> List[Path]:
    """Render `data` to the requested formats and write them into out_dir.
    Returns the list of files written."""
    renderers = {
        "json": ("report.json", report_mod.render_json),
        "md": ("report.md", report_mod.render_markdown),
        "html": ("report.html", report_mod.render_html),
    }
    written = []
    for fmt in formats:
        if fmt not in renderers:
            continue
        fname, render = renderers[fmt]
        path = out_dir / fname
        path.write_text(render(data), encoding="utf-8")
        written.append(path)
    return written


async def run_and_persist(
    mode: str,
    target: str,
    output_dir: Optional[Path] = None,
    formats=DEFAULT_FORMATS,
    language: Optional[str] = None,
) -> dict:
    """Run all scanners for `mode`, deduplicate, build the consolidated report,
    write it to ``<output_dir>/scan_<stamp>_<mode>/`` in every requested format,
    and return the rendered artifacts.

    Returns a dict: {data, out_dir, written, markdown, json} where `data` is the
    full report structure (with the deduplicated section), `markdown`/`json` are
    the rendered strings, and `written` lists the files created on disk."""
    output_dir = Path(output_dir) if output_dir is not None else DEFAULT_REPORTS_DIR
    started_at = datetime.now()

    tool_results, scan_seconds, language = await _run_all(mode, target, language)

    report_start = time.perf_counter()
    all_findings = [f for t in tool_results for f in t["findings"]]
    deduped = deduplicate(all_findings)

    out_dir = output_dir / f"scan_{started_at.strftime('%Y%m%d-%H%M%S')}_{mode}"
    out_dir.mkdir(parents=True, exist_ok=True)

    meta = {
        "mode": mode,
        "target": target,
        "generated_at": started_at.strftime("%Y-%m-%d %H:%M:%S"),
        "scan_seconds": scan_seconds,
        "report_seconds": time.perf_counter() - report_start,
        "total_seconds": scan_seconds + (time.perf_counter() - report_start),
    }
    data = report_mod.build_report(meta, tool_results, deduped)
    written = _write_reports(out_dir, data, formats)

    return {
        "data": data,
        "out_dir": str(out_dir),
        "written": [str(p) for p in written],
        "markdown": report_mod.render_markdown(data),
        "json": report_mod.render_json(data),
    }