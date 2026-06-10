import logging
import subprocess
import mcp.types as types
from typing import List

from security.validation import ScanTargetError, resolve_scan_dir

logger = logging.getLogger(__name__)
TIMEOUT = 900  # 15 minutes default
betterleaks_path = "./tools/sd/betterleaks/betterleaks"


async def secret_betterleaks_scan_impl(project_dir: str) -> List[types.TextContent]:
    """
    Scans the provided project directory for secrets using Betterleaks (the
    successor to Gitleaks, by the same authors) and returns a SARIF 2.1.0 report.

    Betterleaks emits SARIF directly on stdout (``--report-format sarif
    --report-path -``). The scan uses the ``dir`` source (plain filesystem, no
    git history) and live credential validation stays disabled (it is opt-in
    via ``--validation``), so the scan never contacts external services and
    runs fully locally. The function captures the output, handles common error
    scenarios (missing target, timeout, missing executable), and returns the
    results as structured text content.

    :param project_dir: The directory path that needs to be scanned for secrets using `betterleaks`.
    :type project_dir: str
    :return: A list of structured text content containing the SARIF report or error
        details about the `betterleaks` scan results.
    :rtype: List[types.TextContent]
    """
    try:
        project_dir = resolve_scan_dir(project_dir)
    except ScanTargetError as e:
        logger.error(f"betterleaks target error: {e}")
        return [types.TextContent(type="text", text=f"betterleaks target error: {e}")]

    logger.info(f"Starting betterleaks scan for target: {project_dir}")

    # Single-step scan: emit SARIF to stdout; live validation is opt-in and
    # deliberately not enabled (fully local).
    command = [betterleaks_path, "dir", "--report-format", "sarif", "--report-path", "-", project_dir]

    try:
        result = subprocess.run(command, capture_output=True, text=True, timeout=TIMEOUT, check=False)

        logger.info("betterleaks process finished.")
        logger.debug(f"betterleaks stderr:\n{result.stderr}")

        if result.stdout.strip():
            return [types.TextContent(type="text", text=result.stdout)]

        message = result.stderr or "betterleaks did not produce a SARIF report."
        return [types.TextContent(type="text", text=message)]

    except subprocess.TimeoutExpired:
        logger.error(f"betterleaks scan timed out after {TIMEOUT} seconds.")
        return [types.TextContent(type="text", text=f"betterleaks scan timed out after {TIMEOUT} seconds.")]
    except FileNotFoundError:
        logger.error("betterleaks command not found. Is betterleaks installed and in PATH?")
        return [types.TextContent(type="text", text="betterleaks command not found. Is betterleaks installed and in PATH?")]
    except Exception as e:
        logger.error(f"An unexpected error occurred while running betterleaks: {e}")
        return [types.TextContent(type="text", text=f"An unexpected error occurred while running betterleaks: {e}")]
