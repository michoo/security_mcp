import logging
import subprocess
import mcp.types as types
from typing import List

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
    if not project_dir:
        logger.error("opengrep target project_dir is required")
        return [types.TextContent(type="text", text="opengrep target project_dir is required")]

    logger.info(f"Starting opengrep scan for target: {project_dir}")

    # Configure opengrep command with common best practices
    command = [opengrep_path, "scan", project_dir]

    try:
        result = subprocess.run(command, capture_output=True, text=True, timeout=TIMEOUT, check=False)

        logger.info("opengrep process finished.")
        logger.debug(f"opengrep stdout:\n{result.stdout}")

        return [types.TextContent(type="text", text=result.stdout)]

    except subprocess.TimeoutExpired:
        logger.error(f"opengrep scan timed out after {TIMEOUT} seconds.")
        return [types.TextContent(type="text", text=f"opengrep scan timed out after {TIMEOUT} seconds.")]
    except FileNotFoundError:
        logger.error("opengrep command not found. Is opengrep installed and in PATH?")
        return [types.TextContent(type="text", text="opengrep command not found. Is opengrep installed and in PATH?")]
    except Exception as e:
        logger.error(f"An unexpected error occurred while running opengrep: {e}")
        return [types.TextContent(type="text", text=f"An unexpected error occurred while running opengrep: {e}")]