import logging
import subprocess
import mcp.types as types
from typing import List


logger = logging.getLogger(__name__)
TIMEOUT = 900  # 15 minutes default


async def dast_zaproxy_scan_impl(target_url: str) -> List[types.TextContent]:
    """
    Performs a DAST scan on the specified target URL using OWASP ZAP. This function
    orchestrates the execution of the ZAP Docker image for a full scan, processes
    the results, and captures any errors or timeouts for logging and reporting.

    :param target_url: The target URL or IP address to scan
    :type target_url: str
    :return: A list of text content objects containing the scan results or any
             error messages during execution
    :rtype: List[types.TextContent]
    """
    if not target_url:
        logger.error("zap target URL/IP is required")
        return [types.TextContent(type="text", text="zap target URL/IP is required")]

    logger.info(f"Starting zap scan for target: {target_url}")

    # Configure zap command with common best practices
    command = [
        "docker",
        "run",
        "--network", "host",
        "-t", "ghcr.io/zaproxy/zaproxy:stable",
        "zap-full-scan.py",
        "-t", target_url
    ]

    try:
        result = subprocess.run(command, capture_output=True, text=True, timeout=TIMEOUT, check=False)

        logger.info("zap process finished.")
        logger.debug(f"zap stdout:\n{result.stdout}")

        return [types.TextContent(type="text", text=result.stdout)]

    except subprocess.TimeoutExpired:
        logger.error(f"zap scan timed out after {TIMEOUT} seconds.")
        return [types.TextContent(type="text", text=f"zap scan timed out after {TIMEOUT} seconds.")]
    except FileNotFoundError:
        logger.error("zap command not found. Is zap installed and in PATH?")
        return [types.TextContent(type="text", text="zap command not found. Is zap installed and in PATH?")]
    except Exception as e:
        logger.error(f"An unexpected error occurred while running zap: {e}")
        return [types.TextContent(type="text", text=f"An unexpected error occurred while running zap: {e}")]