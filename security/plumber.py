import logging
import os
import subprocess
import tempfile
import mcp.types as types
from typing import List

logger = logging.getLogger(__name__)
TIMEOUT = 900  # 15 minutes default
plumber_path = "./tools/pipeline/plumber/plumber"


async def pipeline_plumber_scan_impl(project_dir: str) -> List[types.TextContent]:
    """
    Analyzes the CI/CD pipeline configuration of the provided project directory
    using `plumber` and returns a SARIF 2.1.0 report.

    Plumber inspects CI/CD configuration (local GitHub Actions workflows under
    ``.github/workflows`` when the git origin is GitHub, or GitLab CI via the API)
    for risky patterns and compliance gaps. This integration runs the analysis
    locally: it generates the default configuration in a temporary location, runs
    ``plumber analyze`` with the project directory as the working directory, and
    writes the SARIF results to a temporary file that is read back and returned.
    No tokens are supplied, so plumber runs in its degraded, workflow-content-only
    mode and never authenticates against a remote provider.

    A non-zero exit code is expected and not treated as a failure: plumber exits 1
    when the compliance score is below the threshold (i.e. findings exist).

    :param project_dir: The path to the project directory whose pipeline should be analyzed.
    :type project_dir: str
    :return: A list of structured text content containing the SARIF report or error
        details about the `plumber` analysis.
    :rtype: List[types.TextContent]
    """
    if not project_dir:
        logger.error("plumber target project_dir is required")
        return [types.TextContent(type="text", text="plumber target project_dir is required")]

    logger.info(f"Starting plumber analysis for target: {project_dir}")

    # Resolve the binary to an absolute path so it can be invoked with cwd=project_dir
    plumber_bin = os.path.abspath(plumber_path)

    with tempfile.TemporaryDirectory() as tmp_dir:
        config_path = os.path.join(tmp_dir, ".plumber.yaml")
        sarif_path = os.path.join(tmp_dir, "plumber.sarif")

        try:
            # Generate the default configuration plumber requires (kept out of the project tree)
            subprocess.run(
                [plumber_bin, "config", "generate", "--output", config_path],
                capture_output=True, text=True, timeout=TIMEOUT, check=False,
            )

            # Configure plumber command: local SARIF analysis, no stdout noise
            command = [
                plumber_bin, "analyze",
                "--print=false",
                "--config", config_path,
                "--sarif", sarif_path,
            ]
            result = subprocess.run(
                command, capture_output=True, text=True, timeout=TIMEOUT, check=False, cwd=project_dir,
            )

            logger.info("plumber process finished.")
            logger.debug(f"plumber stdout:\n{result.stdout}\nplumber stderr:\n{result.stderr}")

            if os.path.isfile(sarif_path):
                with open(sarif_path, "r") as f:
                    return [types.TextContent(type="text", text=f.read())]

            # No SARIF produced. Distinguish "not applicable to this target" (skip) from a real error.
            diag = (result.stderr or result.stdout or "").strip()
            low = diag.lower()
            not_applicable = (
                "could not determine the provider" in low
                or "not in a git repository" in low
                or "no workflows" in low
                or "no ci" in low
                or "configuration file not found" in low
            )
            if not_applicable:
                return [types.TextContent(
                    type="text",
                    text="SKIPPED: no CI/CD pipeline to analyze (not a git repo with a GitHub/GitLab "
                         "remote, or no workflow/.gitlab-ci configuration found).",
                )]
            message = diag or "plumber did not produce a SARIF report."
            return [types.TextContent(type="text", text=message)]

        except subprocess.TimeoutExpired:
            logger.error(f"plumber analysis timed out after {TIMEOUT} seconds.")
            return [types.TextContent(type="text", text=f"plumber analysis timed out after {TIMEOUT} seconds.")]
        except FileNotFoundError:
            logger.error("plumber command not found. Is plumber installed and in PATH?")
            return [types.TextContent(type="text", text="SKIPPED: plumber is not installed (run tools/pipeline/plumber/install.sh).")]
        except Exception as e:
            logger.error(f"An unexpected error occurred while running plumber: {e}")
            return [types.TextContent(type="text", text=f"An unexpected error occurred while running plumber: {e}")]