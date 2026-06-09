import logging
import os
import shutil
import subprocess
import mcp.types as types
from typing import List

logger = logging.getLogger(__name__)
TIMEOUT = 900  # 15 minutes default
nosey_parker_path = "./tools/sd/nosey_parker/bin/noseyparker"
# Scan caches/datastores live under <repo>/data, independent of the current working directory.
DATA_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "data")


async def secret_nosey_parker_scan_impl(project_dir: str) -> List[types.TextContent]:
    """
    Executes a Nosey Parker scan for a given project directory and generates a report.

    The function removes the existing Nosey Parker data store, configures commands
    to perform the scan and generate a report, and captures their outputs. It also
    handles errors such as command timeouts, missing executable, and other unexpected
    exceptions.

    :param project_dir: Path to the project directory that will be scanned by the Nosey Parker tool.
    :type project_dir: str
    :return: List of TextContent instances, containing results or error messages from the scan process.
    :rtype: List[types.TextContent]
    """
    if not project_dir:
        logger.error("nosey_parker target URL/IP is required")
        return [types.TextContent(type="text", text="nosey_parker target project_dir is required")]

    logger.info(f"Starting nosey_parker scan for target: {project_dir}")
    # remove existing datastore.np folder (kept under <repo>/data)
    os.makedirs(DATA_DIR, exist_ok=True)
    folder_path = os.path.join(DATA_DIR, "datastore.np")
    shutil.rmtree(folder_path) if os.path.isdir(folder_path) else None

    # Configure nosey_parker command with common best practices


    try:
        command = [nosey_parker_path, "scan", project_dir, "-d", folder_path, "-v"]
        result = subprocess.run(command, capture_output=True, text=True, timeout=TIMEOUT, check=False)

        command = [nosey_parker_path, "report", "-d", folder_path, "--format", "sarif"]
        result = subprocess.run(command, capture_output=True, text=True, timeout=TIMEOUT, check=False)

        logger.info("nosey_parker process finished.")
        logger.debug(f"nosey_parker stdout:\n{result.stdout}")


        return [types.TextContent(type="text", text=result.stdout)]

    except subprocess.TimeoutExpired:
        logger.error(f"nosey_parker scan timed out after {TIMEOUT} seconds.")
        return [types.TextContent(type="text", text=f"nosey_parker scan timed out after {TIMEOUT} seconds.")]
    except FileNotFoundError:
        logger.error("nosey_parker command not found. Is nosey_parker installed and in PATH?")
        return [types.TextContent(type="text", text="nosey_parker command not found. Is nosey_parker installed and in PATH?")]
    except Exception as e:
        logger.error(f"An unexpected error occurred while running nosey_parker: {e}")
        return [types.TextContent(type="text", text=f"An unexpected error occurred while running nosey_parker: {e}")]