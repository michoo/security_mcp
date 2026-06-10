#!/usr/bin/env python3
"""End-to-end test harness for every scanner exposed by the MCP server.

For each scanner it builds a small example target (one per scanner family),
runs the scanner's implementation, and checks that it produces a valid
report — SARIF 2.1.0 for the scanners that support it, JSON for the ones that
don't (currently only zaproxy).

Run from anywhere:

    uv run python tests/test_scanners.py
    # or
    python tests/test_scanners.py

Exit code is non-zero if any non-DAST scanner fails. DAST scanners (nuclei,
zaproxy) depend on the environment (template downloads, Docker, a live target)
and are reported as SKIP rather than hard failures when prerequisites are
missing.
"""
import asyncio
import json
import os
import shutil
import socket
import subprocess
import sys
import time
import urllib.request
from pathlib import Path

# --- make the repo importable and set cwd to the repo root (tools use ./tools/... paths) ---
REPO_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(REPO_ROOT))
os.chdir(REPO_ROOT)

EXAMPLES = REPO_ROOT / "tests" / "examples"

from security.trivy import (                                         # noqa: E402
    sca_trivy_scan_impl,
    iac_trivy_misconfig_scan_impl,
    license_trivy_scan_impl,
)
from security.osv_scanner import sca_osv_scanner_scan_impl           # noqa: E402
from security.gitleaks import secret_gitleaks_scan_impl             # noqa: E402
from security.nosey_parker import secret_nosey_parker_scan_impl     # noqa: E402
from security.titus import secret_titus_scan_impl                    # noqa: E402
from security.kingfisher import secret_kingfisher_scan_impl          # noqa: E402
from security.trufflehog import secret_trufflehog_scan_impl          # noqa: E402
from security.opengrep import sast_opengrep_scan_impl                # noqa: E402
from security.codeql import sast_codeql_scan_impl                    # noqa: E402
from security.plumber import pipeline_plumber_scan_impl              # noqa: E402
from security.nuclei import dast_nuclei_scan_impl                    # noqa: E402
from security.zap import dast_zaproxy_scan_impl                      # noqa: E402
from scanners import docker_image_present, ZAP_IMAGE                 # noqa: E402
from aggregate import deduplicate                                    # noqa: E402


# --------------------------------------------------------------------------- #
# Helpers
# --------------------------------------------------------------------------- #
def _text(result) -> str:
    """Extract the text payload from a scanner impl's TextContent list."""
    return result[0].text if result else ""


def validate_sarif(text: str):
    """Return (ok, n_results, detail) for a SARIF 2.1.0 document."""
    try:
        doc = json.loads(text)
    except (json.JSONDecodeError, TypeError):
        return False, 0, "output is not JSON/SARIF"
    if doc.get("version") != "2.1.0" or "runs" not in doc:
        return False, 0, f"not SARIF 2.1.0 (version={doc.get('version')!r})"
    n = sum(len(run.get("results", [])) for run in doc["runs"])
    return True, n, "SARIF 2.1.0"


def validate_json(text: str):
    """Return (ok, n, detail) for a plain JSON document (e.g. zaproxy)."""
    try:
        doc = json.loads(text)
    except (json.JSONDecodeError, TypeError):
        return False, 0, "output is not JSON"
    n = len(doc) if isinstance(doc, (list, dict)) else 0
    return True, n, "JSON"


def free_port() -> int:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(("127.0.0.1", 0))
        return s.getsockname()[1]


def make_pipeline_repo(tmp: Path) -> Path:
    """Copy the pipeline example into a temp git repo with a GitHub remote
    (plumber detects the provider from the git remote)."""
    dst = tmp / "pipeline_repo"
    shutil.copytree(EXAMPLES / "pipeline", dst)
    subprocess.run(["git", "init", "-q"], cwd=dst, check=False)
    subprocess.run(
        ["git", "remote", "add", "origin", "https://github.com/example/dast-test.git"],
        cwd=dst, check=False,
    )
    return dst


class DastTarget:
    """Context manager that runs the FastAPI target and waits until it's up."""

    def __init__(self):
        self.port = free_port()
        self.url = f"http://127.0.0.1:{self.port}"
        self.proc = None

    def __enter__(self):
        self.proc = subprocess.Popen(
            [sys.executable, str(REPO_ROOT / "tests" / "dast_target.py"), "127.0.0.1", str(self.port)],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )
        deadline = time.time() + 20
        while time.time() < deadline:
            try:
                urllib.request.urlopen(self.url + "/ping", timeout=1)
                return self
            except Exception:
                if self.proc.poll() is not None:
                    raise RuntimeError("DAST target process exited before becoming ready")
                time.sleep(0.3)
        raise RuntimeError("DAST target did not become ready in time")

    def __exit__(self, *exc):
        if self.proc and self.proc.poll() is None:
            self.proc.terminate()
            try:
                self.proc.wait(timeout=5)
            except subprocess.TimeoutExpired:
                self.proc.kill()


# --------------------------------------------------------------------------- #
# Result reporting
# --------------------------------------------------------------------------- #
PASS, FAIL, SKIP = "PASS", "FAIL", "SKIP"
results = []  # list of (family, name, status, detail)


def record(family, name, status, detail):
    results.append((family, name, status, detail))
    icon = {"PASS": "✅", "FAIL": "❌", "SKIP": "⚠️ "}[status]
    print(f"  {icon} {family:9} {name:14} {status:4} — {detail}")


# --------------------------------------------------------------------------- #
# The tests
# --------------------------------------------------------------------------- #
async def run_sarif(family, name, coro, min_results=0):
    """Run a scanner expected to emit SARIF and record the outcome.

    min_results > 0 turns an empty-but-valid report into a FAIL — used for
    deterministic fixtures that are known to contain findings, so a scanner
    silently producing nothing is caught as a regression."""
    try:
        text = _text(await coro)
    except Exception as e:  # noqa: BLE001
        record(family, name, FAIL, f"impl raised {type(e).__name__}: {e}")
        return
    ok, n, detail = validate_sarif(text)
    if not ok:
        record(family, name, FAIL, detail)
    elif n < min_results:
        record(family, name, FAIL, f"{detail}, {n} result(s) (expected >= {min_results})")
    else:
        record(family, name, PASS, f"{detail}, {n} result(s)")


def check_dedup():
    """Unit-check the cross-tool deduplication used by the aggregated scans and
    the CLI --dedupe flag. Pure function, no external tools required."""
    print("\nAggregation / deduplication:")
    raw = [
        # same secret at the same location reported by three secret scanners
        {"rule": "aws-key", "severity": "high", "message": "AWS Access Key",
         "location": "config.env:3", "tools": ["gitleaks"]},
        {"rule": "aws-access-token", "severity": "critical", "message": "AWS Access Key",
         "location": "config.env:3", "tools": ["titus"]},
        {"rule": "np.aws", "severity": "medium", "message": "AWS Access Key",
         "location": "config.env:3", "tools": ["nosey_parker"]},
        # a distinct finding elsewhere
        {"rule": "KSV-0001", "severity": "high", "message": "Privileged container",
         "location": "insecure-pod.yaml:14", "tools": ["trivy-misconfig"]},
    ]
    out = deduplicate(raw)
    problems = []
    if len(out) != 2:
        problems.append(f"expected 2 unique findings, got {len(out)}")
    secret = next((f for f in out if f["location"] == "config.env:3"), None)
    if secret is None:
        problems.append("merged secret finding missing")
    else:
        if secret["severity"] != "critical":
            problems.append(f"expected highest severity 'critical', got {secret['severity']!r}")
        if secret["tools"] != ["gitleaks", "nosey_parker", "titus"]:
            problems.append(f"tools not unioned/sorted: {secret['tools']}")
        if secret.get("occurrences") != 3:
            problems.append(f"expected occurrences=3, got {secret.get('occurrences')}")
    if problems:
        record("Aggregate", "deduplicate", FAIL, "; ".join(problems))
    else:
        record("Aggregate", "deduplicate", PASS, "3 raw -> 2 unique, severity/tools merged")


async def main():
    import tempfile

    print("\n=== Security MCP — scanner SARIF test harness ===\n")
    sca_dir = str(EXAMPLES / "sca")
    iac_dir = str(EXAMPLES / "iac")
    secrets_dir = str(EXAMPLES / "secrets")
    sast_dir = str(EXAMPLES / "sast")

    with tempfile.TemporaryDirectory() as tmp:
        # SCA -------------------------------------------------------------
        print("SCA (Software Composition Analysis):")
        await run_sarif("SCA", "trivy", sca_trivy_scan_impl(sca_dir))
        await run_sarif("SCA", "osv-scanner", sca_osv_scanner_scan_impl(sca_dir))

        # IaC misconfiguration (trivy --scanners misconfig) ---------------
        print("\nIaC misconfiguration:")
        await run_sarif("IaC", "trivy-misconfig", iac_trivy_misconfig_scan_impl(iac_dir), min_results=1)

        # License compliance (trivy --scanners license) -------------------
        print("\nLicense compliance:")
        await run_sarif("License", "trivy-license", license_trivy_scan_impl(sca_dir))

        # Secret detection ------------------------------------------------
        print("\nSecret detection:")
        await run_sarif("Secret", "gitleaks", secret_gitleaks_scan_impl(secrets_dir))
        await run_sarif("Secret", "nosey_parker", secret_nosey_parker_scan_impl(secrets_dir))
        await run_sarif("Secret", "titus", secret_titus_scan_impl(secrets_dir))
        await run_sarif("Secret", "kingfisher", secret_kingfisher_scan_impl(secrets_dir))
        await run_sarif("Secret", "trufflehog", secret_trufflehog_scan_impl(secrets_dir), min_results=1)

        # SAST ------------------------------------------------------------
        print("\nSAST (Static Application Security Testing):")
        await run_sarif("SAST", "opengrep", sast_opengrep_scan_impl(sast_dir))
        await run_sarif("SAST", "codeql", sast_codeql_scan_impl(sast_dir, "python"))

        # Pipeline (CI/CD) ------------------------------------------------
        print("\nPipeline (CI/CD):")
        pipeline_repo = make_pipeline_repo(Path(tmp))
        await run_sarif("Pipeline", "plumber", pipeline_plumber_scan_impl(str(pipeline_repo)))

        # DAST ------------------------------------------------------------
        print("\nDAST (Dynamic Application Security Testing):")
        try:
            with DastTarget() as target:
                # nuclei → SARIF (needs templates; may require network on first run)
                text = _text(await dast_nuclei_scan_impl(target.url))
                ok, n, detail = validate_sarif(text)
                if ok:
                    record("DAST", "nuclei", PASS, f"{detail}, {n} result(s)")
                else:
                    record("DAST", "nuclei", SKIP, f"no SARIF (templates/network?): {text[:60].strip()}")

                # zaproxy → JSON (requires the ZAP Docker image to be pulled already)
                if not docker_image_present(ZAP_IMAGE):
                    record("DAST", "zaproxy", SKIP, "ZAP docker image not present (run install.sh)")
                else:
                    text = _text(await dast_zaproxy_scan_impl(target.url))
                    ok, n, detail = validate_json(text)
                    record("DAST", "zaproxy", PASS if ok else SKIP,
                           f"{detail}, {n} item(s)" if ok else f"no JSON: {text[:60].strip()}")
        except Exception as e:  # noqa: BLE001
            record("DAST", "nuclei", SKIP, f"target setup failed: {e}")
            record("DAST", "zaproxy", SKIP, "target setup failed")

    # Aggregation / dedup (pure function, no external tools) ---------------
    check_dedup()

    # Summary -------------------------------------------------------------
    n_pass = sum(1 for r in results if r[2] == PASS)
    n_fail = sum(1 for r in results if r[2] == FAIL)
    n_skip = sum(1 for r in results if r[2] == SKIP)
    print(f"\n=== Summary: {n_pass} passed, {n_fail} failed, {n_skip} skipped ===")
    if n_fail:
        print("FAILED:", ", ".join(f"{r[1]}" for r in results if r[2] == FAIL))
    return 1 if n_fail else 0


if __name__ == "__main__":
    sys.exit(asyncio.run(main()))