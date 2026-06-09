import logging
import os
import subprocess
import tempfile
import mcp.types as types
from typing import List

logger = logging.getLogger(__name__)
TIMEOUT = 900  # 15 minutes default
nuclei_path = "./tools/dast/nuclei/nuclei"

# nuclei only writes the SARIF export file when there is at least one finding; this
# minimal valid SARIF 2.1.0 document is returned for a clean scan with no findings.
_EMPTY_SARIF = (
    '{\n  "$schema": "https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json",\n'
    '  "version": "2.1.0",\n'
    '  "runs": [{"tool": {"driver": {"name": "nuclei", "rules": []}}, "results": []}]\n}'
)


async def dast_nuclei_scan_impl(target_url: str) -> List[types.TextContent]:
    """
    Performs an asynchronous scan using the Nuclei tool for the given target URL.
    This function executes a configured Nuclei command line tool to perform
    dynamic application security testing (DAST) and returns any results produced
    by Nuclei in a structured textual format. The scan is configured to filter
    results by severity levels (medium, high, critical) and run in silent mode.

    :param target_url: The target URL or IP address to be scanned by Nuclei.
    :type target_url: str
    :return: A list containing TextContent objects, which encapsulate the textual
        output or error messages from the Nuclei scan execution.
    :rtype: List[types.TextContent]
    """
    if not target_url:
        logger.error("Nuclei target URL/IP is required")
        return [types.TextContent(type="text", text="Nuclei target URL/IP is required")]

    logger.info(f"Starting Nuclei scan for target: {target_url}")

    try:
        with tempfile.TemporaryDirectory() as tmp_dir:
            sarif_path = os.path.join(tmp_dir, "nuclei.sarif")
            # Configure nuclei command: filter by severity, export findings as SARIF
            command = [
                nuclei_path,
                "-target", target_url,
                "-severity", "medium,high,critical",
                "-sarif-export", sarif_path,
                "-silent",
            ]
            result = subprocess.run(command, capture_output=True, text=True, timeout=TIMEOUT, check=False)

            logger.info("Nuclei process finished.")
            logger.debug(f"Nuclei stderr:\n{result.stderr}")

            if os.path.isfile(sarif_path):
                with open(sarif_path, "r") as f:
                    return [types.TextContent(type="text", text=f.read())]

            # No export file: a clean scan with no findings -> return an empty SARIF
            if result.returncode == 0:
                return [types.TextContent(type="text", text=_EMPTY_SARIF)]

            message = result.stderr or result.stdout or "Nuclei did not produce a SARIF report."
            return [types.TextContent(type="text", text=message)]

    except subprocess.TimeoutExpired:
        logger.error(f"Nuclei scan timed out after {TIMEOUT} seconds.")
        return [types.TextContent(type="text", text=f"Nuclei scan timed out after {TIMEOUT} seconds.")]
    except FileNotFoundError:
        logger.error("Nuclei command not found. Is Nuclei installed and in PATH?")
        return [types.TextContent(type="text", text="Nuclei command not found. Is Nuclei installed and in PATH?")]
    except Exception as e:
        logger.error(f"An unexpected error occurred while running Nuclei: {e}")
        return [types.TextContent(type="text", text=f"An unexpected error occurred while running Nuclei: {e}")]