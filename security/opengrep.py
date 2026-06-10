import logging
import os
import subprocess
import tempfile
import mcp.types as types
from typing import List

from security.validation import ScanTargetError, resolve_scan_dir

logger = logging.getLogger(__name__)
TIMEOUT = 900  # 15 minutes default
opengrep_path = "./tools/sast/opengrep/opengrep"

async def sast_opengrep_scan_impl(project_dir: str) -> List[types.TextContent]:
    """
    Performs an async OpenGrep scan on the given project directory. Handles preparation
    and execution of OpenGrep commands while logging the process and returning output
    or error messages encapsulated in `types.TextContent`.

    :param project_dir: The target directory for the OpenGrep scan. Must be a non-empty string.
    :type project_dir: str
    :return: A list of `types.TextContent` representing the command's output, or error messages
        in case of failure during the scan.
    :rtype: List[types.TextContent]
    """
    try:
        project_dir = resolve_scan_dir(project_dir)
    except ScanTargetError as e:
        logger.error(f"opengrep target error: {e}")
        return [types.TextContent(type="text", text=f"opengrep target error: {e}")]

    logger.info(f"Starting opengrep scan for target: {project_dir}")

    try:
        with tempfile.TemporaryDirectory() as tmp_dir:
            sarif_path = os.path.join(tmp_dir, "opengrep.sarif")
            # Use the auto ruleset and emit a SARIF report to a file
            command = [opengrep_path, "scan", "--config", "auto", "--sarif-output", sarif_path, "--", project_dir]
            result = subprocess.run(command, capture_output=True, text=True, timeout=TIMEOUT, check=False)

            logger.info("opengrep process finished.")
            logger.debug(f"opengrep stderr:\n{result.stderr}")

            if os.path.isfile(sarif_path):
                with open(sarif_path, "r") as f:
                    return [types.TextContent(type="text", text=f.read())]

            message = result.stderr or result.stdout or "opengrep did not produce a SARIF report."
            return [types.TextContent(type="text", text=message)]

    except subprocess.TimeoutExpired:
        logger.error(f"opengrep scan timed out after {TIMEOUT} seconds.")
        return [types.TextContent(type="text", text=f"opengrep scan timed out after {TIMEOUT} seconds.")]
    except FileNotFoundError:
        logger.error("opengrep command not found. Is opengrep installed and in PATH?")
        return [types.TextContent(type="text", text="opengrep command not found. Is opengrep installed and in PATH?")]
    except Exception as e:
        logger.error(f"An unexpected error occurred while running opengrep: {e}")
        return [types.TextContent(type="text", text=f"An unexpected error occurred while running opengrep: {e}")]