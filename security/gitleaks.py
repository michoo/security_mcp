import logging
import subprocess
import mcp.types as types
from typing import List

logger = logging.getLogger(__name__)
TIMEOUT = 900  # 15 minutes default
gitleaks_path = "./tools/sd/gitleaks/gitleaks"


async def secret_gitleaks_scan_impl(project_dir: str) -> List[types.TextContent]:
    """
    Scans the provided project directory using the `gitleaks` tool for secrets and sensitive
    information leaks. The function captures any output or error messages, processes the
    results, and returns them as structured text content.

    :param project_dir: The directory path that needs to be scanned for secrets using `gitleaks`.
    :type project_dir: str

    :return: A list of structured text content containing information or error details
        about the `gitleaks` scan results.
    :rtype: List[types.TextContent]
    """
    if not project_dir:
        logger.error("gitleaks target URL/IP is required")
        return [types.TextContent(type="text", text="gitleaks target project_dir is required")]

    logger.info(f"Starting gitleaks scan for target: {project_dir}")

    # Configure gitleaks command with common best practices
    command = [gitleaks_path, "detect", "--source", project_dir, "--no-git", "--report-format", "sarif", "--report-path", "-"]

    try:
        result = subprocess.run(command, capture_output=True, text=True, timeout=TIMEOUT, check=False)

        logger.info("gitleaks process finished.")
        logger.debug(f"gitleaks stdout:\n{result.stdout}")


        return [types.TextContent(type="text", text=result.stdout)]

    except subprocess.TimeoutExpired:
        logger.error(f"gitleaks scan timed out after {TIMEOUT} seconds.")
        return [types.TextContent(type="text", text=f"gitleaks scan timed out after {TIMEOUT} seconds.")]
    except FileNotFoundError:
        logger.error("gitleaks command not found. Is gitleaks installed and in PATH?")
        return [types.TextContent(type="text", text="gitleaks command not found. Is gitleaks installed and in PATH?")]
    except Exception as e:
        logger.error(f"An unexpected error occurred while running gitleaks: {e}")
        return [types.TextContent(type="text", text=f"An unexpected error occurred while running gitleaks: {e}")]