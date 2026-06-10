import logging
import os
import subprocess
import tempfile
import mcp.types as types
from typing import List

from security.validation import ScanTargetError, resolve_scan_dir

logger = logging.getLogger(__name__)
TIMEOUT = 900  # 15 minutes default
osv_scanner_path = "./tools/sca/osv-scanner/osv-scanner"

async def sca_osv_scanner_scan_impl(project_dir: str) -> List[types.TextContent]:
    """
    Scan a target project directory with the osv_scanner tool and return the results
    as a list of TextContent objects. The function handles error scenarios such as
    missing target directory, subprocess execution issues, and command not found.

    :param project_dir: The target project directory to be scanned using the
        osv_scanner.
    :type project_dir: str
    :return: A list of TextContent objects containing the scan results. The results
        include the scanner's standard output on success or descriptive error messages
        in case of failure.
    :rtype: List[types.TextContent]
    """
    try:
        project_dir = resolve_scan_dir(project_dir)
    except ScanTargetError as e:
        logger.error(f"osv_scanner target error: {e}")
        return [types.TextContent(type="text", text=f"osv_scanner target error: {e}")]

    logger.info(f"Starting osv_scanner scan for target: {project_dir}")

    try:
        with tempfile.TemporaryDirectory() as tmp_dir:
            sarif_path = os.path.join(tmp_dir, "osv.sarif")
            # Recurse into subdirectories (-r); SARIF to a file (osv exits non-zero on vulns)
            command = [osv_scanner_path, "scan", "-r", "--format", "sarif", "--output", sarif_path, "--", project_dir]
            result = subprocess.run(command, capture_output=True, text=True, timeout=TIMEOUT, check=False)

            logger.info("osv_scanner process finished.")
            logger.debug(f"osv_scanner stderr:\n{result.stderr}")

            if os.path.isfile(sarif_path):
                with open(sarif_path, "r") as f:
                    return [types.TextContent(type="text", text=f.read())]

            message = result.stderr or result.stdout or "osv_scanner did not produce a SARIF report."
            return [types.TextContent(type="text", text=message)]

    except subprocess.TimeoutExpired:
        logger.error(f"osv_scanner scan timed out after {TIMEOUT} seconds.")
        return [types.TextContent(type="text", text=f"osv_scanner scan timed out after {TIMEOUT} seconds.")]
    except FileNotFoundError:
        logger.error("osv_scanner command not found. Is osv_scanner installed and in PATH?")
        return [types.TextContent(type="text", text="osv_scanner command not found. Is osv_scanner installed and in PATH?")]
    except Exception as e:
        logger.error(f"An unexpected error occurred while running osv_scanner: {e}")
        return [types.TextContent(type="text", text=f"An unexpected error occurred while running osv_scanner: {e}")]