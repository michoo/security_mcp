"""Report building and rendering for the scan CLI.

Takes the raw output of each scanner (SARIF 2.1.0 or JSON), normalizes it into
findings, and renders a consolidated report in Markdown, JSON and HTML.
"""
import html
import json
from typing import List, Optional

# SARIF result.level -> normalized severity
_LEVEL_TO_SEVERITY = {"error": "high", "warning": "medium", "note": "low", "none": "info"}
SEVERITY_ORDER = ["critical", "high", "medium", "low", "info"]


def _normalize_severity(value: Optional[str]) -> str:
    if not value:
        return "medium"
    v = value.strip().lower()
    if v in SEVERITY_ORDER:
        return v
    return _LEVEL_TO_SEVERITY.get(v, "medium")


def _sarif_rule_severities(run: dict) -> dict:
    """Map ruleId -> severity hinted by the rule metadata (used when a result
    has no explicit level), covering tools like trivy/osv that carry severity on
    the rule's properties."""
    out = {}
    driver = run.get("tool", {}).get("driver", {})
    for rule in driver.get("rules", []) or []:
        rid = rule.get("id")
        if not rid:
            continue
        props = rule.get("properties", {}) or {}
        sev = props.get("security-severity") or props.get("severity") or props.get("problem.severity")
        if isinstance(sev, str):
            # security-severity can be a numeric CVSS string
            try:
                score = float(sev)
                sev = ("critical" if score >= 9 else "high" if score >= 7
                       else "medium" if score >= 4 else "low")
            except ValueError:
                pass
            out[rid] = sev
    return out


def extract_findings(tool: str, fmt: str, text: str) -> dict:
    """Return {findings: [...], severity_counts: {...}, parse_error: str|None}."""
    findings: List[dict] = []

    if not text or not text.strip():
        return {"findings": [], "severity_counts": {}, "parse_error": "empty output (no report produced)"}
    try:
        doc = json.loads(text)
    except json.JSONDecodeError:
        return {"findings": [], "severity_counts": {}, "parse_error": "output was not valid JSON/SARIF"}

    if fmt == "json":
        # ZAP JSON report: site[].alerts[] with riskcode 0..3
        if not (isinstance(doc, dict) and "site" in doc):
            return {"findings": [], "severity_counts": {}, "parse_error": "not a recognized JSON report"}
        risk = {"0": "info", "1": "low", "2": "medium", "3": "high"}
        for site in doc.get("site", []) or []:
            for alert in site.get("alerts", []) or []:
                sev = risk.get(str(alert.get("riskcode", "")), "medium")
                instances = alert.get("instances") or []
                loc = (instances[0].get("uri", "") if instances else site.get("@name", ""))
                findings.append({
                    "rule": alert.get("alertRef") or alert.get("pluginid") or alert.get("name", ""),
                    "severity": sev,
                    "message": alert.get("name", ""),
                    "location": loc,
                })
        counts = {s: 0 for s in SEVERITY_ORDER}
        for f in findings:
            counts[f["severity"]] = counts.get(f["severity"], 0) + 1
        return {"findings": findings, "severity_counts": counts, "parse_error": None}

    if fmt == "sarif":
        if not (isinstance(doc, dict) and doc.get("version") == "2.1.0" and "runs" in doc):
            return {"findings": [], "severity_counts": {},
                    "parse_error": f"not SARIF 2.1.0 (version={doc.get('version') if isinstance(doc, dict) else type(doc).__name__!r})"}
        for run in doc.get("runs", []):
            rule_sev = _sarif_rule_severities(run)
            for res in run.get("results", []) or []:
                rid = res.get("ruleId", "")
                level = res.get("level")
                sev = _normalize_severity(level if level else rule_sev.get(rid))
                msg = (res.get("message", {}) or {}).get("text", "")
                loc = ""
                locs = res.get("locations") or []
                if locs:
                    phys = (locs[0].get("physicalLocation", {}) or {})
                    uri = (phys.get("artifactLocation", {}) or {}).get("uri", "")
                    line = (phys.get("region", {}) or {}).get("startLine")
                    loc = f"{uri}:{line}" if line else uri
                findings.append({"rule": rid, "severity": sev, "message": msg, "location": loc})
    # severity counts
    counts = {s: 0 for s in SEVERITY_ORDER}
    for f in findings:
        counts[f["severity"]] = counts.get(f["severity"], 0) + 1
    return {"findings": findings, "severity_counts": counts, "parse_error": None}


def build_report(meta: dict, tool_results: List[dict], deduped: Optional[List[dict]] = None) -> dict:
    """Assemble the consolidated report data structure.

    meta: {mode, target, started_at, total_seconds, scan_seconds, report_seconds}
    tool_results: list of per-tool dicts with name/family/status/duration/findings/...
    deduped: optional list of cross-tool deduplicated findings (each with
        severity/rule/location/message/tools/occurrences). When provided, a
        "deduplicated" section is added to the report.
    """
    total_findings = sum(len(t.get("findings", [])) for t in tool_results)
    severity_totals = {s: 0 for s in SEVERITY_ORDER}
    for t in tool_results:
        for s, n in (t.get("severity_counts") or {}).items():
            severity_totals[s] = severity_totals.get(s, 0) + n
    report = {
        "meta": meta,
        "summary": {
            "tools_run": len(tool_results),
            "total_findings": total_findings,
            "severity_totals": severity_totals,
        },
        "tools": tool_results,
    }
    if deduped is not None:
        dedup_totals = {s: 0 for s in SEVERITY_ORDER}
        for f in deduped:
            dedup_totals[f["severity"]] = dedup_totals.get(f["severity"], 0) + 1
        report["summary"]["deduplicated_findings"] = len(deduped)
        report["summary"]["duplicates_removed"] = total_findings - len(deduped)
        report["deduplicated"] = {
            "count": len(deduped),
            "raw_count": total_findings,
            "severity_totals": dedup_totals,
            "findings": deduped,
        }
    return report


# --------------------------------------------------------------------------- #
# Renderers
# --------------------------------------------------------------------------- #
def render_json(report: dict) -> str:
    return json.dumps(report, indent=2, ensure_ascii=False)


def _sev_cell(counts: dict) -> str:
    parts = [f"{s[:4].upper()}:{counts.get(s, 0)}" for s in SEVERITY_ORDER if counts.get(s, 0)]
    return " ".join(parts) if parts else "-"


def render_markdown(report: dict) -> str:
    m = report["meta"]
    s = report["summary"]
    lines = []
    lines.append(f"# Security scan report")
    lines.append("")
    lines.append(f"- **Generated:** {m['generated_at']}")
    lines.append(f"- **Mode:** {m['mode']}")
    lines.append(f"- **Target:** `{m['target']}`")
    lines.append(f"- **Tools run:** {s['tools_run']}")
    lines.append(f"- **Total findings:** {s['total_findings']}  "
                 f"({', '.join(f'{k}={v}' for k, v in s['severity_totals'].items() if v)})")
    lines.append(f"- **Scan duration:** {m['scan_seconds']:.1f}s  |  "
                 f"**Report generation:** {m['report_seconds']:.2f}s  |  "
                 f"**Total:** {m['total_seconds']:.1f}s")
    lines.append("")
    dedup = report.get("deduplicated")
    if dedup is not None:
        lines.append("## Deduplicated findings")
        lines.append("")
        lines.append(f"- **Unique findings:** {dedup['count']} "
                     f"(from {dedup['raw_count']} raw; "
                     f"{dedup['raw_count'] - dedup['count']} duplicate(s) removed)  "
                     f"({', '.join(f'{k}={v}' for k, v in dedup['severity_totals'].items() if v) or 'none'})")
        lines.append("")
        if dedup["findings"]:
            lines.append("| Severity | Location | Tools | Rule | Message |")
            lines.append("|----------|----------|-------|------|---------|")
            for f in dedup["findings"]:
                msg = (f.get("message") or "").replace("\n", " ").replace("|", "\\|")[:200]
                tools = ", ".join(f.get("tools", []))
                occ = f.get("occurrences", 1)
                tools = f"{tools} (×{occ})" if occ > 1 else tools
                lines.append(f"| {f['severity']} | {f['location']} | {tools} | {f.get('rule', '')} | {msg} |")
        else:
            lines.append("_No findings._")
        lines.append("")
    lines.append("## Summary by tool")
    lines.append("")
    lines.append("| Tool | Family | Status | Duration | Findings | Severities |")
    lines.append("|------|--------|--------|---------:|---------:|------------|")
    for t in report["tools"]:
        lines.append(
            f"| {t['name']} | {t['family']} | {t['status']} | {t['duration']:.1f}s | "
            f"{len(t.get('findings', []))} | {_sev_cell(t.get('severity_counts', {}))} |"
        )
    lines.append("")
    lines.append("## Findings by tool")
    for t in report["tools"]:
        lines.append("")
        lines.append(f"### {t['name']} ({t['family']}) — {t['status']}")
        if t.get("error"):
            lines.append("")
            lines.append(f"> {t['error']}")
            continue
        findings = t.get("findings", [])
        if not findings:
            lines.append("")
            lines.append("_No findings._")
            continue
        lines.append("")
        lines.append("| Severity | Rule | Location | Message |")
        lines.append("|----------|------|----------|---------|")
        for f in findings:
            msg = (f["message"] or "").replace("\n", " ").replace("|", "\\|")[:200]
            lines.append(f"| {f['severity']} | {f['rule']} | {f['location']} | {msg} |")
    lines.append("")
    return "\n".join(lines)


_SEV_COLOR = {"critical": "#7d1128", "high": "#d7263d", "medium": "#f46036",
              "low": "#2e86ab", "info": "#6c757d"}


def render_html(report: dict) -> str:
    m = report["meta"]
    s = report["summary"]

    def esc(x):
        return html.escape(str(x))

    rows = []
    for t in report["tools"]:
        sev = t.get("severity_counts", {})
        chips = "".join(
            f'<span class="chip" style="background:{_SEV_COLOR[k]}">{k[:4].upper()} {v}</span>'
            for k, v in sev.items() if v
        ) or "-"
        rows.append(
            f"<tr><td>{esc(t['name'])}</td><td>{esc(t['family'])}</td>"
            f"<td class='st-{esc(t['status'])}'>{esc(t['status'])}</td>"
            f"<td class='num'>{t['duration']:.1f}s</td>"
            f"<td class='num'>{len(t.get('findings', []))}</td><td>{chips}</td></tr>"
        )

    sections = []
    for t in report["tools"]:
        findings = t.get("findings", [])
        body = ""
        if t.get("error"):
            body = f"<p class='err'>{esc(t['error'])}</p>"
        elif not findings:
            body = "<p class='muted'>No findings.</p>"
        else:
            frows = "".join(
                f"<tr><td><span class='chip' style='background:{_SEV_COLOR[f['severity']]}'>"
                f"{esc(f['severity'])}</span></td><td>{esc(f['rule'])}</td>"
                f"<td class='loc'>{esc(f['location'])}</td><td>{esc((f['message'] or '')[:300])}</td></tr>"
                for f in findings
            )
            body = ("<table class='findings'><thead><tr><th>Severity</th><th>Rule</th>"
                    "<th>Location</th><th>Message</th></tr></thead><tbody>"
                    f"{frows}</tbody></table>")
        sections.append(
            f"<details open><summary><b>{esc(t['name'])}</b> "
            f"<span class='muted'>({esc(t['family'])} — {esc(t['status'])}, "
            f"{len(findings)} findings, {t['duration']:.1f}s)</span></summary>{body}</details>"
        )

    sev_summary = " ".join(
        f"<span class='chip' style='background:{_SEV_COLOR[k]}'>{k} {v}</span>"
        for k, v in s["severity_totals"].items() if v
    ) or "<span class='muted'>none</span>"

    dedup = report.get("deduplicated")
    dedup_html = ""
    if dedup is not None:
        if dedup["findings"]:
            drows = "".join(
                f"<tr><td><span class='chip' style='background:{_SEV_COLOR[f['severity']]}'>"
                f"{esc(f['severity'])}</span></td><td class='loc'>{esc(f['location'])}</td>"
                f"<td>{esc(', '.join(f.get('tools', [])))}"
                f"{(' (×' + str(f['occurrences']) + ')') if f.get('occurrences', 1) > 1 else ''}</td>"
                f"<td>{esc(f.get('rule', ''))}</td><td>{esc((f.get('message') or '')[:300])}</td></tr>"
                for f in dedup["findings"]
            )
            dedup_table = ("<table class='findings'><thead><tr><th>Severity</th><th>Location</th>"
                           "<th>Tools</th><th>Rule</th><th>Message</th></tr></thead><tbody>"
                           f"{drows}</tbody></table>")
        else:
            dedup_table = "<p class='muted'>No findings.</p>"
        dedup_sev = " ".join(
            f"<span class='chip' style='background:{_SEV_COLOR[k]}'>{k} {v}</span>"
            for k, v in dedup["severity_totals"].items() if v
        ) or "<span class='muted'>none</span>"
        dedup_html = (
            f"<h2>Deduplicated findings</h2>"
            f"<p><b>{dedup['count']}</b> unique finding(s) from {dedup['raw_count']} raw "
            f"({dedup['raw_count'] - dedup['count']} duplicate(s) removed) &nbsp; {dedup_sev}</p>"
            f"{dedup_table}"
        )

    return f"""<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8">
<title>Security scan report — {esc(m['generated_at'])}</title>
<style>
  body {{ font-family: system-ui, sans-serif; margin: 2rem; color: #1d1d1f; }}
  h1 {{ margin-bottom: .2rem; }}
  .meta {{ color:#444; margin-bottom:1.2rem; line-height:1.6; }}
  table {{ border-collapse: collapse; width: 100%; margin: .5rem 0 1.5rem; }}
  th, td {{ border: 1px solid #e2e2e2; padding: 6px 10px; text-align: left; font-size: 14px; }}
  th {{ background:#f6f6f7; }}
  td.num {{ text-align: right; font-variant-numeric: tabular-nums; }}
  td.loc {{ font-family: ui-monospace, monospace; font-size: 12px; }}
  .chip {{ color:#fff; padding: 1px 7px; border-radius: 10px; font-size: 11px; margin-right:3px; white-space:nowrap; }}
  .muted {{ color:#888; }}
  .err {{ color:#d7263d; }}
  .st-ok {{ color:#1a7f37; font-weight:600; }}
  .st-error {{ color:#d7263d; font-weight:600; }}
  .st-skipped {{ color:#9a6700; font-weight:600; }}
  details {{ border:1px solid #eee; border-radius:8px; padding:.5rem 1rem; margin:.6rem 0; }}
  summary {{ cursor:pointer; }}
</style></head><body>
<h1>Security scan report</h1>
<div class="meta">
  <div><b>Generated:</b> {esc(m['generated_at'])}</div>
  <div><b>Mode:</b> {esc(m['mode'])} &nbsp; <b>Target:</b> <code>{esc(m['target'])}</code></div>
  <div><b>Tools run:</b> {s['tools_run']} &nbsp; <b>Total findings:</b> {s['total_findings']} &nbsp; {sev_summary}</div>
  <div><b>Scan:</b> {m['scan_seconds']:.1f}s &nbsp; <b>Report generation:</b> {m['report_seconds']:.2f}s &nbsp; <b>Total:</b> {m['total_seconds']:.1f}s</div>
</div>
{dedup_html}
<h2>Summary by tool</h2>
<table><thead><tr><th>Tool</th><th>Family</th><th>Status</th><th>Duration</th><th>Findings</th><th>Severities</th></tr></thead>
<tbody>{''.join(rows)}</tbody></table>
<h2>Findings by tool</h2>
{''.join(sections)}
</body></html>
"""