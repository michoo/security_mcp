import logging
import subprocess
import mcp.types as types
from typing import List


logger = logging.getLogger(__name__)
TIMEOUT = 900  # 15 minutes default
trivy_path = "./tools/sca/trivy/trivy"

async def sca_trivy_scan_impl(project_dir: str) -> List[types.TextContent]:
    """
    Perform a trivy security scan on a specified project directory asynchronously.

    The function utilizes the trivy CLI to perform a file system ("fs") security
    scan in JSON format for the given project directory. It handles the execution
    of the trivy command, captures its output, and formats the result as a list
    of TextContent objects. The method logs various scan stages and provides error
    handling for specific situations such as missing targets, command timeouts,
    or missing executables.

    :param project_dir: Path of the project directory to scan
    :type project_dir: str
    :return: A list of TextContent objects containing the trivy CLI output or
        error messages in text
    :rtype: List[types.TextContent]
    """
    if not project_dir:
        logger.error("trivy target project_dir is required")
        return [types.TextContent(type="text", text="trivy target project_dir is required")]

    logger.info(f"Starting trivy scan for target: {project_dir}")

    # Configure trivy command with common best practices
    command = [trivy_path, "fs", "--format", "json", project_dir]

    try:
        result = subprocess.run(command, capture_output=True, text=True, timeout=TIMEOUT, check=False)

        logger.info("trivy process finished.")
        logger.debug(f"trivy stdout:\n{result.stdout}")

        return [types.TextContent(type="text", text=result.stdout)]

    except subprocess.TimeoutExpired:
        logger.error(f"trivy scan timed out after {TIMEOUT} seconds.")
        return [types.TextContent(type="text", text=f"trivy scan timed out after {TIMEOUT} seconds.")]
    except FileNotFoundError:
        logger.error("trivy command not found. Is trivy installed and in PATH?")
        return [types.TextContent(type="text", text="trivy command not found. Is trivy installed and in PATH?")]
    except Exception as e:
        logger.error(f"An unexpected error occurred while running trivy: {e}")
        return [types.TextContent(type="text", text=f"An unexpected error occurred while running trivy: {e}")]