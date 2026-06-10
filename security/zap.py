import logging
import os
import subprocess
import tempfile
import mcp.types as types
from typing import List


logger = logging.getLogger(__name__)
TIMEOUT = 900  # 15 minutes default
ZAP_IMAGE = "ghcr.io/zaproxy/zaproxy:stable"


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

    try:
        # ZAP writes its JSON report into /zap/wrk; mount a host temp dir to read
        # it back. tempfile.mkdtemp() creates that directory mode 0o700 — keep it
        # that way. Widening it to 0o777 (the previous approach) would let any
        # local user read the scan report or swap it out for attacker content
        # before we read it back (CWE-732 incorrect permissions / CWE-377 insecure
        # temp file). Instead, run the container as the host UID/GID so it can
        # write into the private directory, and point HOME there so ZAP's Java
        # process has a writable home even when that UID has no /etc/passwd entry.
        with tempfile.TemporaryDirectory() as tmp_dir:
            report_name = "zap-report.json"
            command = [
                "docker", "run", "--rm",
                "--user", f"{os.getuid()}:{os.getgid()}",
                "--network", "host",
                "-e", "HOME=/zap/wrk",
                "-v", f"{tmp_dir}:/zap/wrk/:rw",
                "-t", ZAP_IMAGE,
                "zap-full-scan.py",
                "-t", target_url,
                "-J", report_name,
            ]
            result = subprocess.run(command, capture_output=True, text=True, timeout=TIMEOUT, check=False)

            logger.info("zap process finished.")
            logger.debug(f"zap stdout:\n{result.stdout}")

            report_path = os.path.join(tmp_dir, report_name)
            if os.path.isfile(report_path):
                with open(report_path, "r") as f:
                    return [types.TextContent(type="text", text=f.read())]

            message = result.stdout or result.stderr or "zap did not produce a JSON report."
            return [types.TextContent(type="text", text=message)]

    except subprocess.TimeoutExpired:
        logger.error(f"zap scan timed out after {TIMEOUT} seconds.")
        return [types.TextContent(type="text", text=f"zap scan timed out after {TIMEOUT} seconds.")]
    except FileNotFoundError:
        logger.error("zap command not found. Is zap installed and in PATH?")
        return [types.TextContent(type="text", text="zap command not found. Is zap installed and in PATH?")]
    except Exception as e:
        logger.error(f"An unexpected error occurred while running zap: {e}")
        return [types.TextContent(type="text", text=f"An unexpected error occurred while running zap: {e}")]