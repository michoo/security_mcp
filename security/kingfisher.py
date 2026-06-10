import logging
import subprocess
import mcp.types as types
from typing import List

from security.validation import ScanTargetError, resolve_scan_dir

logger = logging.getLogger(__name__)
TIMEOUT = 900  # 15 minutes default
kingfisher_path = "./tools/sd/kingfisher/kingfisher"


async def secret_kingfisher_scan_impl(project_dir: str) -> List[types.TextContent]:
    """
    Scans the provided project directory for secrets using MongoDB's `kingfisher`
    tool and returns a SARIF 2.1.0 report.

    Kingfisher emits SARIF directly on stdout (``--format sarif``). The scan runs
    with ``--no-validate`` so it never contacts external services to validate
    candidate credentials, keeping it fully local. The function captures the
    output, handles common error scenarios (missing target, timeout, missing
    executable), and returns the results as structured text content.

    :param project_dir: The directory path that needs to be scanned for secrets using `kingfisher`.
    :type project_dir: str
    :return: A list of structured text content containing the SARIF report or error
        details about the `kingfisher` scan results.
    :rtype: List[types.TextContent]
    """
    try:
        project_dir = resolve_scan_dir(project_dir)
    except ScanTargetError as e:
        logger.error(f"kingfisher target error: {e}")
        return [types.TextContent(type="text", text=f"kingfisher target error: {e}")]

    logger.info(f"Starting kingfisher scan for target: {project_dir}")

    # Single-step scan: emit SARIF to stdout, no external credential validation (fully local).
    command = [kingfisher_path, "scan", "--format", "sarif", "--no-validate", "--", project_dir]

    try:
        result = subprocess.run(command, capture_output=True, text=True, timeout=TIMEOUT, check=False)

        logger.info("kingfisher process finished.")
        logger.debug(f"kingfisher stderr:\n{result.stderr}")

        if result.stdout.strip():
            return [types.TextContent(type="text", text=result.stdout)]

        message = result.stderr or "kingfisher did not produce a SARIF report."
        return [types.TextContent(type="text", text=message)]

    except subprocess.TimeoutExpired:
        logger.error(f"kingfisher scan timed out after {TIMEOUT} seconds.")
        return [types.TextContent(type="text", text=f"kingfisher scan timed out after {TIMEOUT} seconds.")]
    except FileNotFoundError:
        logger.error("kingfisher command not found. Is kingfisher installed and in PATH?")
        return [types.TextContent(type="text", text="kingfisher command not found. Is kingfisher installed and in PATH?")]
    except Exception as e:
        logger.error(f"An unexpected error occurred while running kingfisher: {e}")
        return [types.TextContent(type="text", text=f"An unexpected error occurred while running kingfisher: {e}")]
