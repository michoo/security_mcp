import logging
import os
import subprocess
import tempfile
import mcp.types as types
from typing import List

from security.validation import ScanTargetError, resolve_scan_dir

logger = logging.getLogger(__name__)
TIMEOUT = 1800  # 30 minutes default (database build + analysis can be slow)
codeql_path = "./tools/sast/codeql/codeql/codeql"
# Scan caches/databases live under <repo>/data, independent of the current working directory.
DATA_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "data")

# Languages with a bundled extractor and a published codeql/<lang>-queries pack.
SUPPORTED_LANGUAGES = {
    "python", "javascript", "java", "csharp", "cpp", "go", "ruby", "swift", "rust", "actions",
}

# Common aliases mapped to the CodeQL language identifier.
LANGUAGE_ALIASES = {
    "typescript": "javascript", "ts": "javascript", "js": "javascript",
    "kotlin": "java", "c": "cpp", "c++": "cpp", "c#": "csharp", "golang": "go",
}


async def sast_codeql_scan_impl(project_dir: str, language: str) -> List[types.TextContent]:
    """
    Performs a SAST scan of the given project directory using GitHub CodeQL and
    returns a SARIF 2.1.0 report.

    CodeQL works in two steps: it first builds a CodeQL database from the source
    tree (for compiled languages this triggers autobuild), then runs the standard
    ``codeql/<language>-queries`` code-scanning suite against that database and
    interprets the results as SARIF. The database is kept under
    ``<repo>/data/codeql_db`` (overwritten on each run) and the SARIF report in a
    temporary file; the query pack is fetched on first use and cached under
    ``~/.codeql/packages`` for subsequent scans.

    :param project_dir: Path to the project directory to scan.
    :type project_dir: str
    :param language: Source language to analyze (e.g. python, javascript, java,
        csharp, cpp, go, ruby, swift, rust, actions). Common aliases such as
        typescript or kotlin are accepted.
    :type language: str
    :return: A list of text content containing the SARIF report or error details.
    :rtype: List[types.TextContent]
    """
    try:
        project_dir = resolve_scan_dir(project_dir)
    except ScanTargetError as e:
        logger.error(f"codeql target error: {e}")
        return [types.TextContent(type="text", text=f"codeql target error: {e}")]

    if not language:
        logger.error("codeql language is required")
        return [types.TextContent(type="text", text="codeql language is required (e.g. python, javascript, java, ...)")]

    language = LANGUAGE_ALIASES.get(language.strip().lower(), language.strip().lower())
    if language not in SUPPORTED_LANGUAGES:
        logger.error(f"codeql unsupported language: {language}")
        return [types.TextContent(
            type="text",
            text=f"codeql unsupported language '{language}'. Supported: {', '.join(sorted(SUPPORTED_LANGUAGES))}",
        )]

    logger.info(f"Starting codeql scan for target: {project_dir} (language: {language})")

    # Resolve the binary to an absolute path so it can be invoked regardless of cwd
    codeql_bin = os.path.abspath(codeql_path)

    # Database kept under <repo>/data (overwritten each run); SARIF stays in a temp file
    os.makedirs(DATA_DIR, exist_ok=True)
    db_path = os.path.join(DATA_DIR, "codeql_db")

    with tempfile.TemporaryDirectory() as tmp_dir:
        sarif_path = os.path.join(tmp_dir, "codeql.sarif")

        try:
            # 1. Build the CodeQL database from the source tree
            create_cmd = [
                codeql_bin, "database", "create", db_path,
                "--language=" + language,
                "--source-root", project_dir,
                "--overwrite",
            ]
            create = subprocess.run(create_cmd, capture_output=True, text=True, timeout=TIMEOUT, check=False)

            if not os.path.isdir(db_path):
                logger.error("codeql database create failed.")
                message = create.stderr or create.stdout or "codeql database create failed."
                return [types.TextContent(type="text", text=message)]

            # 2. Run the standard code-scanning suite and interpret results as SARIF
            analyze_cmd = [
                codeql_bin, "database", "analyze", db_path,
                "codeql/" + language + "-queries",
                "--format=sarif-latest",
                "--output", sarif_path,
                "--download",
                "--threads=0",
            ]
            result = subprocess.run(analyze_cmd, capture_output=True, text=True, timeout=TIMEOUT, check=False)

            logger.info("codeql process finished.")
            logger.debug(f"codeql stderr:\n{result.stderr}")

            if os.path.isfile(sarif_path):
                with open(sarif_path, "r") as f:
                    return [types.TextContent(type="text", text=f.read())]

            message = result.stderr or result.stdout or "codeql did not produce a SARIF report."
            return [types.TextContent(type="text", text=message)]

        except subprocess.TimeoutExpired:
            logger.error(f"codeql scan timed out after {TIMEOUT} seconds.")
            return [types.TextContent(type="text", text=f"codeql scan timed out after {TIMEOUT} seconds.")]
        except FileNotFoundError:
            logger.error("codeql command not found. Is codeql installed and in PATH?")
            return [types.TextContent(type="text", text="codeql command not found. Is codeql installed and in PATH?")]
        except Exception as e:
            logger.error(f"An unexpected error occurred while running codeql: {e}")
            return [types.TextContent(type="text", text=f"An unexpected error occurred while running codeql: {e}")]