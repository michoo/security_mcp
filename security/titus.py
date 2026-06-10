import logging
import os
import shutil
import subprocess
import mcp.types as types
from typing import List

from security.validation import ScanTargetError, resolve_scan_dir

logger = logging.getLogger(__name__)
TIMEOUT = 900  # 15 minutes default
titus_path = "./tools/sd/titus/titus"
# Scan caches/datastores live under <repo>/data, independent of the current working directory.
DATA_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "data")


async def secret_titus_scan_impl(project_dir: str) -> List[types.TextContent]:
    """
    Scans the provided project directory for secrets using Praetorian's `titus`
    tool and returns a SARIF 2.1.0 report.

    The scan stores its datastore under ``<repo>/data/titus.ds`` and emits the
    findings directly to stdout in SARIF format (``--format sarif``). No secret
    validation or dynamic scoring is performed, so the scan stays fully local and
    never contacts external APIs. The function captures the output, handles common
    error scenarios (missing target, timeout, missing executable), and returns the
    results as structured text content.

    :param project_dir: The directory path that needs to be scanned for secrets using `titus`.
    :type project_dir: str
    :return: A list of structured text content containing the SARIF report or error
        details about the `titus` scan results.
    :rtype: List[types.TextContent]
    """
    try:
        project_dir = resolve_scan_dir(project_dir)
    except ScanTargetError as e:
        logger.error(f"titus target error: {e}")
        return [types.TextContent(type="text", text=f"titus target error: {e}")]

    logger.info(f"Starting titus scan for target: {project_dir}")

    # Datastore kept under <repo>/data; remove any stale one so the scan starts clean
    os.makedirs(DATA_DIR, exist_ok=True)
    datastore_path = os.path.join(DATA_DIR, "titus.ds")
    if os.path.isdir(datastore_path):
        shutil.rmtree(datastore_path)
    elif os.path.isfile(datastore_path):
        os.remove(datastore_path)

    # titus emits SARIF on stdout only via the `report` command when scanning into an
    # on-disk datastore, so run it in two steps: scan -> datastore, then report -> SARIF.
    # No validation / dynamic scoring, so the scan stays fully local (no external APIs).
    scan_cmd = [titus_path, "scan", "-q", "--output", datastore_path, "--", project_dir]
    report_cmd = [titus_path, "report", "--datastore", datastore_path, "--format", "sarif"]

    try:
        scan = subprocess.run(scan_cmd, capture_output=True, text=True, timeout=TIMEOUT, check=False)
        if not os.path.isdir(datastore_path):
            logger.error("titus scan did not create a datastore.")
            message = scan.stderr or scan.stdout or "titus scan did not create a datastore."
            return [types.TextContent(type="text", text=message)]

        result = subprocess.run(report_cmd, capture_output=True, text=True, timeout=TIMEOUT, check=False)

        logger.info("titus process finished.")
        logger.debug(f"titus stderr:\n{result.stderr}")

        if result.stdout.strip():
            return [types.TextContent(type="text", text=result.stdout)]

        message = result.stderr or "titus did not produce a SARIF report."
        return [types.TextContent(type="text", text=message)]

    except subprocess.TimeoutExpired:
        logger.error(f"titus scan timed out after {TIMEOUT} seconds.")
        return [types.TextContent(type="text", text=f"titus scan timed out after {TIMEOUT} seconds.")]
    except FileNotFoundError:
        logger.error("titus command not found. Is titus installed and in PATH?")
        return [types.TextContent(type="text", text="titus command not found. Is titus installed and in PATH?")]
    except Exception as e:
        logger.error(f"An unexpected error occurred while running titus: {e}")
        return [types.TextContent(type="text", text=f"An unexpected error occurred while running titus: {e}")]