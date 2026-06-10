import json
import logging
import os
import subprocess
import mcp.types as types
from typing import List

from security.validation import ScanTargetError, resolve_scan_dir

logger = logging.getLogger(__name__)
TIMEOUT = 900  # 15 minutes default
trufflehog_path = "./tools/sd/trufflehog/trufflehog"


def _jsonl_to_sarif(jsonl: str, project_dir: str) -> str:
    """Convert TruffleHog's JSON-lines output to a SARIF 2.1.0 document.

    TruffleHog has no native SARIF output (only ``--json``, one finding object
    per line), so the conversion lives here to keep the downstream pipeline
    (report.extract_findings, dedup, tests) uniform. The raw secret value
    (``Raw``) is deliberately never copied into the report — only the detector
    name and file:line location.
    """
    results = []
    rules = {}
    for line in jsonl.splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            finding = json.loads(line)
        except json.JSONDecodeError:
            continue  # stray non-JSON line (defensive; logs go to stderr)
        if not isinstance(finding, dict) or "DetectorName" not in finding:
            continue
        detector = finding.get("DetectorName") or "unknown"
        description = finding.get("DetectorDescription") or f"TruffleHog {detector} detector"
        rules.setdefault(detector, {
            "id": detector,
            "shortDescription": {"text": description},
        })
        meta = (((finding.get("SourceMetadata") or {}).get("Data") or {}).get("Filesystem") or {})
        file = meta.get("file") or ""
        if file and os.path.isabs(file):
            file = os.path.relpath(file, project_dir)
        line_no = meta.get("line")
        location = {"physicalLocation": {"artifactLocation": {"uri": file}}}
        if isinstance(line_no, int) and line_no > 0:
            location["physicalLocation"]["region"] = {"startLine": line_no}
        verified = "verified" if finding.get("Verified") else "verification skipped"
        results.append({
            "ruleId": detector,
            "level": "error",
            "message": {"text": f"Potential {detector} secret detected ({verified})."},
            "locations": [location],
        })
    sarif = {
        "$schema": "https://json.schemastore.org/sarif-2.1.0.json",
        "version": "2.1.0",
        "runs": [{
            "tool": {"driver": {
                "name": "trufflehog",
                "informationUri": "https://github.com/trufflesecurity/trufflehog",
                "rules": list(rules.values()),
            }},
            "results": results,
        }],
    }
    return json.dumps(sarif)


async def secret_trufflehog_scan_impl(project_dir: str) -> List[types.TextContent]:
    """
    Scans the provided project directory for secrets using Truffle Security's
    `trufflehog` tool and returns a SARIF 2.1.0 report.

    TruffleHog emits JSON lines (``--json``) rather than SARIF, so this impl
    converts its findings to SARIF 2.1.0 before returning them. The scan runs
    with ``--no-verification`` so it never contacts external services to
    validate candidate credentials, and ``--no-update`` so it never phones home
    for updates, keeping it fully local. The function captures the output,
    handles common error scenarios (missing target, timeout, missing
    executable), and returns the results as structured text content.

    :param project_dir: The directory path that needs to be scanned for secrets using `trufflehog`.
    :type project_dir: str
    :return: A list of structured text content containing the SARIF report or error
        details about the `trufflehog` scan results.
    :rtype: List[types.TextContent]
    """
    try:
        project_dir = resolve_scan_dir(project_dir)
    except ScanTargetError as e:
        logger.error(f"trufflehog target error: {e}")
        return [types.TextContent(type="text", text=f"trufflehog target error: {e}")]

    logger.info(f"Starting trufflehog scan for target: {project_dir}")

    # Single-step scan: JSON findings on stdout, no external credential
    # validation and no update check (fully local).
    command = [trufflehog_path, "filesystem", "--json", "--no-verification", "--no-update", project_dir]

    try:
        result = subprocess.run(command, capture_output=True, text=True, timeout=TIMEOUT, check=False)

        logger.info("trufflehog process finished.")
        logger.debug(f"trufflehog stderr:\n{result.stderr}")

        if result.returncode != 0:
            message = result.stderr or f"trufflehog exited with code {result.returncode}."
            return [types.TextContent(type="text", text=message)]

        return [types.TextContent(type="text", text=_jsonl_to_sarif(result.stdout, project_dir))]

    except subprocess.TimeoutExpired:
        logger.error(f"trufflehog scan timed out after {TIMEOUT} seconds.")
        return [types.TextContent(type="text", text=f"trufflehog scan timed out after {TIMEOUT} seconds.")]
    except FileNotFoundError:
        logger.error("trufflehog command not found. Is trufflehog installed and in PATH?")
        return [types.TextContent(type="text", text="trufflehog command not found. Is trufflehog installed and in PATH?")]
    except Exception as e:
        logger.error(f"An unexpected error occurred while running trufflehog: {e}")
        return [types.TextContent(type="text", text=f"An unexpected error occurred while running trufflehog: {e}")]
