import logging
import os
import re
import subprocess
import tempfile
import mcp.types as types
from typing import List, Optional, Tuple


logger = logging.getLogger(__name__)
TIMEOUT = 900  # 15 minutes default
trivy_path = "./tools/sca/trivy/trivy"

# misconfig (IaC) and license scanning via `--scanners` need a modern trivy.
# The project's tools/sca/trivy/install.sh pins 0.71.0; 0.40 is the floor that
# supports both `--scanners misconfig` and `--scanners license`.
_MIN_SCANNERS_VERSION = (0, 40, 0)


def _trivy_version() -> Optional[Tuple[int, int, int]]:
    """Return the installed trivy version as a (major, minor, patch) tuple, or
    None if it cannot be determined."""
    try:
        out = subprocess.run([trivy_path, "--version"], capture_output=True, text=True,
                             timeout=30, check=False).stdout
    except Exception:  # noqa: BLE001
        return None
    m = re.search(r"Version:\s*v?(\d+)\.(\d+)\.(\d+)", out)
    if not m:
        return None
    return tuple(int(g) for g in m.groups())  # type: ignore[return-value]


async def _trivy_fs_scan(project_dir: str, scanners: str, label: str) -> List[types.TextContent]:
    """Run `trivy fs` for a given `--scanners` selection and return native SARIF.

    Used for misconfig (IaC) and license scanning, which the old bundled SARIF
    template cannot render — modern trivy emits SARIF natively for every scanner
    type. Falls back to a SKIPPED marker when the installed binary is too old."""
    if not project_dir:
        logger.error(f"{label} target project_dir is required")
        return [types.TextContent(type="text", text=f"{label} target project_dir is required")]

    version = _trivy_version()
    if version is not None and version < _MIN_SCANNERS_VERSION:
        ver = ".".join(map(str, version))
        need = ".".join(map(str, _MIN_SCANNERS_VERSION))
        msg = (f"SKIPPED: trivy {ver} is too old for '{scanners}' scanning "
               f"(>= {need} required); run tools/sca/trivy/install.sh to upgrade.")
        logger.warning(msg)
        return [types.TextContent(type="text", text=msg)]

    logger.info(f"Starting {label} scan for target: {project_dir}")
    try:
        with tempfile.TemporaryDirectory() as tmp_dir:
            sarif_path = os.path.join(tmp_dir, "trivy.sarif")
            command = [
                trivy_path, "--quiet", "fs",
                "--scanners", scanners,
                "--format", "sarif",
                "--output", sarif_path,
                project_dir,
            ]
            result = subprocess.run(command, capture_output=True, text=True, timeout=TIMEOUT, check=False)
            logger.info(f"{label} process finished.")
            logger.debug(f"{label} stderr:\n{result.stderr}")

            if os.path.isfile(sarif_path):
                with open(sarif_path, "r") as f:
                    return [types.TextContent(type="text", text=f.read())]

            message = result.stderr or result.stdout or f"{label} did not produce a SARIF report."
            return [types.TextContent(type="text", text=message)]

    except subprocess.TimeoutExpired:
        logger.error(f"{label} scan timed out after {TIMEOUT} seconds.")
        return [types.TextContent(type="text", text=f"{label} scan timed out after {TIMEOUT} seconds.")]
    except FileNotFoundError:
        logger.error("trivy command not found. Is trivy installed and in PATH?")
        return [types.TextContent(type="text", text="trivy command not found. Is trivy installed and in PATH?")]
    except Exception as e:
        logger.error(f"An unexpected error occurred while running {label}: {e}")
        return [types.TextContent(type="text", text=f"An unexpected error occurred while running {label}: {e}")]


async def iac_trivy_misconfig_scan_impl(project_dir: str) -> List[types.TextContent]:
    """Scan a directory for Infrastructure-as-Code misconfigurations with trivy
    (Terraform, CloudFormation, Kubernetes, Dockerfile, Helm, etc.)."""
    return await _trivy_fs_scan(project_dir, "misconfig", "trivy-misconfig")


async def license_trivy_scan_impl(project_dir: str) -> List[types.TextContent]:
    """Scan a directory for software license findings with trivy."""
    return await _trivy_fs_scan(project_dir, "license", "trivy-license")

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

    # This trivy build renders SARIF through the bundled SARIF template (no native sarif format)
    sarif_template = os.path.abspath("./tools/sca/trivy/contrib/sarif.tpl")

    try:
        with tempfile.TemporaryDirectory() as tmp_dir:
            sarif_path = os.path.join(tmp_dir, "trivy.sarif")
            # --quiet is a global flag and must precede the subcommand; write SARIF to a file
            command = [
                trivy_path, "--quiet", "fs",
                "--format", "template",
                "--template", "@" + sarif_template,
                "--output", sarif_path,
                project_dir,
            ]
            result = subprocess.run(command, capture_output=True, text=True, timeout=TIMEOUT, check=False)

            logger.info("trivy process finished.")
            logger.debug(f"trivy stderr:\n{result.stderr}")

            if os.path.isfile(sarif_path):
                with open(sarif_path, "r") as f:
                    return [types.TextContent(type="text", text=f.read())]

            message = result.stderr or result.stdout or "trivy did not produce a SARIF report."
            return [types.TextContent(type="text", text=message)]

    except subprocess.TimeoutExpired:
        logger.error(f"trivy scan timed out after {TIMEOUT} seconds.")
        return [types.TextContent(type="text", text=f"trivy scan timed out after {TIMEOUT} seconds.")]
    except FileNotFoundError:
        logger.error("trivy command not found. Is trivy installed and in PATH?")
        return [types.TextContent(type="text", text="trivy command not found. Is trivy installed and in PATH?")]
    except Exception as e:
        logger.error(f"An unexpected error occurred while running trivy: {e}")
        return [types.TextContent(type="text", text=f"An unexpected error occurred while running trivy: {e}")]