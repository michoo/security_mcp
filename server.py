import functools
import logging
import sys
from pathlib import Path
import mcp.types as types
from typing import List
from mcp.server.fastmcp import FastMCP

from aggregate import run_and_persist
from config import scanner_enabled, env_var_for
from scanners import STATIC, DYNAMIC
from security.codeql import sast_codeql_scan_impl
from security.gitleaks import secret_gitleaks_scan_impl
from security.kingfisher import secret_kingfisher_scan_impl
from security.nosey_parker import secret_nosey_parker_scan_impl
from security.nuclei import dast_nuclei_scan_impl
from security.opengrep import sast_opengrep_scan_impl
from security.osv_scanner import sca_osv_scanner_scan_impl
from security.plumber import pipeline_plumber_scan_impl
from security.sca import sca_fix_vulnerability
from security.titus import secret_titus_scan_impl
from security.trufflehog import secret_trufflehog_scan_impl
from security.trivy import sca_trivy_scan_impl, iac_trivy_misconfig_scan_impl, license_trivy_scan_impl
from security.zap import dast_zaproxy_scan_impl

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    stream=sys.stdout
)
logger = logging.getLogger(__name__)

mcp = FastMCP("mcp-security-scanner")


def respects_toggle(scanner_name: str):
    """Decorator: short-circuit a per-scanner tool when it is disabled via its
    environment toggle (e.g. CODEQL=False), returning a SKIPPED message instead
    of running it. functools.wraps keeps the signature so FastMCP still builds
    the correct tool schema."""
    def decorator(fn):
        @functools.wraps(fn)
        async def wrapper(*args, **kwargs):
            if not scanner_enabled(scanner_name):
                msg = (f"SKIPPED: {scanner_name} is disabled via environment "
                       f"(unset {env_var_for(scanner_name)} or set it to true to enable).")
                return [types.TextContent(type="text", text=msg)]
            return await fn(*args, **kwargs)
        return wrapper
    return decorator


async def _run_aggregated_tool(mode: str, target: str) -> List[types.TextContent]:
    """Run every scanner for `mode`, persist report.md/json/html under ./reports,
    and return the Markdown report with a footer pointing at the written files."""
    result = await run_and_persist(mode, target)
    footer = "\n\n---\n_Reports written to `{}` ({})._\n".format(
        result["out_dir"], ", ".join(Path(p).name for p in result["written"])
    )
    return [types.TextContent(type="text", text=result["markdown"] + footer)]


# AGGREGATED SCANS
@mcp.tool()
async def static_scan(project_dir: str) -> List[types.TextContent]:
    """
    Run every static security scanner against a local directory and return a
    single consolidated, deduplicated report.

    This orchestrates all STATIC-mode scanners — SCA (trivy, osv-scanner),
    secret detection (gitleaks, nosey_parker, titus, kingfisher, trufflehog),
    SAST (opengrep, codeql) and CI/CD pipeline analysis (plumber) — collects
    every finding, then
    aggregates and deduplicates them. The CodeQL source language is
    auto-detected from the directory contents.

    Duplicate findings (the same issue reported by several scanners, or several
    times by one scanner) are collapsed by (location, message); the merged
    entry keeps the highest severity and unions the contributing tools and rule
    ids. Locations — and therefore distinct secret values, which live at
    distinct file:line locations — are always preserved.

    The full report is also written to disk under ./reports/scan_<timestamp>_static/
    as report.md, report.json and report.html. This tool returns the Markdown
    report (which includes the deduplicated findings section).

    :param project_dir: Path to the directory to scan.
    :type project_dir: str
    :return: A single TextContent holding the Markdown report.
    :rtype: List[types.TextContent]
    """
    return await _run_aggregated_tool(STATIC, project_dir)


@mcp.tool()
async def dynamic_scan(target_url: str) -> List[types.TextContent]:
    """
    Run every dynamic (DAST) security scanner against a target URL and return a
    single consolidated, deduplicated report.

    This orchestrates all DYNAMIC-mode scanners — nuclei and OWASP ZAP
    (zaproxy) — against the running target, collects every finding, then
    aggregates and deduplicates them. ZAP is skipped gracefully if its Docker
    image is not present locally.

    Duplicate findings (the same issue reported by both scanners) are collapsed
    by (location, message); the merged entry keeps the highest severity and
    unions the contributing tools and rule ids. The finding location/URI is
    always preserved.

    The full report is also written to disk under ./reports/scan_<timestamp>_dynamic/
    as report.md, report.json and report.html. This tool returns the Markdown
    report (which includes the deduplicated findings section).

    :param target_url: The http(s) URL of the running target to scan.
    :type target_url: str
    :return: A single TextContent holding the Markdown report.
    :rtype: List[types.TextContent]
    """
    return await _run_aggregated_tool(DYNAMIC, target_url)


# DAST
@mcp.tool()
@respects_toggle("zaproxy")
async def dast_zaproxy_scan(target_url:str) -> List[types.TextContent]:
    """
    Performs a DAST (Dynamic Application Security Testing) scan on the provided
    target URL using the OWASP ZAP proxy. It asynchronously initiates the scan
    process and retrieves the security test results.

    :param target_url: The URL of the target application to be scanned.
    :type target_url: str
    :return: A list of security findings in the form of TextContent objects.
    :rtype: List[types.TextContent]
    """
    return await dast_zaproxy_scan_impl(target_url)

@mcp.tool()
@respects_toggle("nuclei")
async def dast_nuclei_scan(target_url:str) -> List[types.TextContent]:
    """
    Performs a DAST (Dynamic Application Security Testing) scan using Nuclei
    on the given target URL and provides the scan results.

    :param target_url: The URL of the target application to be scanned.
    :type target_url: str
    :return: A list of scan findings represented as `TextContent` objects.
    :rtype: List[types.TextContent]
    """
    return await dast_nuclei_scan_impl(target_url)

# SCA
@mcp.tool()
@respects_toggle("trivy")
async def sca_trivy_scan(project_dir: str) -> List[types.TextContent]:
    """
    Perform a Software Composition Analysis (SCA) scan using Trivy.

    This function utilizes Trivy to analyze a specified project directory for
    any known vulnerabilities or license issues. It asynchronously invokes
    an implementation function to execute the scan and retrieve the results.

    :param project_dir: Path to the directory containing the project to be scanned.
    :type project_dir: str
    :return: A list of text content representing the scan results.
    :rtype: List[types.TextContent]
    """
    return await sca_trivy_scan_impl(project_dir)

@mcp.tool()
@respects_toggle("osv-scanner")
async def sca_osv_scanner_scan(project_dir: str) -> List[types.TextContent]:
    """
    Scans a given project directory for open source vulnerabilities (OSV) using the SCA OSV scanner.

    .. note::
        This function is designed to invoke the implementation of the
        SCA OSV scanning logic asynchronously and return the results.

    :param project_dir: The path to the project directory that needs to be scanned.
    :type project_dir: str
    :return: A list containing the results of the OSV scan in the form of text content.
    :rtype: List[types.TextContent]
    """
    return await sca_osv_scanner_scan_impl(project_dir)

# IaC MISCONFIGURATION
@mcp.tool()
@respects_toggle("trivy-misconfig")
async def iac_trivy_misconfig_scan(project_dir: str) -> List[types.TextContent]:
    """
    Scan a directory for Infrastructure-as-Code (IaC) misconfigurations using Trivy
    and return the findings as a SARIF 2.1.0 report.

    Trivy's misconfiguration scanner inspects IaC and configuration files —
    Terraform, CloudFormation, Kubernetes manifests, Dockerfiles, Helm charts and
    more — against built-in security policies, flagging issues such as overly
    permissive access, missing encryption, and privilege escalation. This scanner
    is disabled in Trivy's default filesystem scan and is enabled here explicitly
    (``--scanners misconfig``). Requires Trivy >= 0.40.

    :param project_dir: Path to the directory containing IaC/config to scan.
    :type project_dir: str
    :return: A list of text content containing the SARIF report of misconfigurations.
    :rtype: List[types.TextContent]
    """
    return await iac_trivy_misconfig_scan_impl(project_dir)

# LICENSE COMPLIANCE
@mcp.tool()
@respects_toggle("trivy-license")
async def license_trivy_scan(project_dir: str) -> List[types.TextContent]:
    """
    Scan a directory for software license findings using Trivy and return the
    results as a SARIF 2.1.0 report.

    Trivy's license scanner detects the licenses of dependencies and files and
    classifies them by risk, surfacing restricted or non-compliant licenses. This
    scanner is disabled in Trivy's default filesystem scan and is enabled here
    explicitly (``--scanners license``). Requires Trivy >= 0.40.

    :param project_dir: Path to the directory to scan for license findings.
    :type project_dir: str
    :return: A list of text content containing the SARIF report of license findings.
    :rtype: List[types.TextContent]
    """
    return await license_trivy_scan_impl(project_dir)


# SECRET
@mcp.tool()
@respects_toggle("nosey_parker")
async def secret_nosey_parker_scan(project_dir: str) -> List[types.TextContent]:
    """
    Scans a project directory for sensitive information and returns the results.

    This function performs a scan of the specified directory to detect and
    report any sensitive information identified during the assessment. It
    utilizes a secret scanning tool implementation to perform the detection
    and processes the scan results before returning them.

    :param project_dir: The path to the project directory to be scanned.
    :type project_dir: str
    :return: A list of text content representing the scan results of the
        project directory.
    :rtype: List[types.TextContent]
    """
    return await secret_nosey_parker_scan_impl(project_dir)

@mcp.tool()
@respects_toggle("gitleaks")
async def secret_gitleaks_scan(project_dir: str) -> List[types.TextContent]:
    """
    Scans the specified project directory for secrets using the gitleaks tool.

    This function performs a detailed scan of the given project's directory
    to identify and analyze potential secrets present in the codebase. It
    utilizes the gitleaks tool to execute the scan and returns a list of results
    which contain instances of sensitive information detected in the code.

    :param project_dir: Directory path of the project to scan
    :type project_dir: str
    :return: List of detected text content containing secrets
    :rtype: List[types.TextContent]
    """
    return await secret_gitleaks_scan_impl(project_dir)

@mcp.tool()
@respects_toggle("titus")
async def secret_titus_scan(project_dir: str) -> List[types.TextContent]:
    """
    Scans the specified project directory for secrets using Praetorian's Titus tool
    and returns the findings as a SARIF 2.1.0 report.

    Titus is a high-performance secrets scanner that detects credentials, API keys,
    and tokens across source code and files. This scan runs fully locally (in-memory
    datastore, no credential validation or dynamic scoring) and emits a SARIF report
    suitable for CI/CD integration and GitHub Advanced Security.

    :param project_dir: Directory path of the project to scan.
    :type project_dir: str
    :return: A list of text content containing the SARIF report of detected secrets.
    :rtype: List[types.TextContent]
    """
    return await secret_titus_scan_impl(project_dir)

@mcp.tool()
@respects_toggle("kingfisher")
async def secret_kingfisher_scan(project_dir: str) -> List[types.TextContent]:
    """
    Scans the specified project directory for secrets using MongoDB's Kingfisher
    tool and returns the findings as a SARIF 2.1.0 report.

    Kingfisher detects credentials, API keys and tokens across source code and
    files using a large built-in ruleset. This scan runs fully locally with
    ``--no-validate`` (no external credential validation) and emits a SARIF
    report suitable for CI/CD integration and GitHub Advanced Security.

    :param project_dir: Directory path of the project to scan.
    :type project_dir: str
    :return: A list of text content containing the SARIF report of detected secrets.
    :rtype: List[types.TextContent]
    """
    return await secret_kingfisher_scan_impl(project_dir)

@mcp.tool()
@respects_toggle("trufflehog")
async def secret_trufflehog_scan(project_dir: str) -> List[types.TextContent]:
    """
    Scans the specified project directory for secrets using Truffle Security's
    TruffleHog tool and returns the findings as a SARIF 2.1.0 report.

    TruffleHog detects credentials, API keys and tokens across source code and
    files using a large built-in detector set. This scan runs fully locally with
    ``--no-verification`` (no external credential validation) and
    ``--no-update`` (no update check); its native JSON output is converted to a
    SARIF report suitable for CI/CD integration and GitHub Advanced Security.

    :param project_dir: Directory path of the project to scan.
    :type project_dir: str
    :return: A list of text content containing the SARIF report of detected secrets.
    :rtype: List[types.TextContent]
    """
    return await secret_trufflehog_scan_impl(project_dir)

# PIPELINE (CI/CD)
@mcp.tool()
@respects_toggle("plumber")
async def pipeline_plumber_scan(project_dir: str) -> List[types.TextContent]:
    """
    Analyzes the CI/CD pipeline configuration of the specified project directory using
    Plumber and returns the findings as a SARIF 2.1.0 report.

    Plumber inspects CI/CD configuration (local GitHub Actions workflows, or GitLab CI)
    for risky patterns and compliance gaps such as unverified script execution, unpinned
    container images and actions, unsafe variable expansion, and missing branch
    protection. The analysis runs locally without provider tokens and produces a SARIF
    report suitable for GitHub Code Scanning / GitLab Security Dashboard integration.

    :param project_dir: Directory path of the project whose pipeline should be analyzed.
    :type project_dir: str
    :return: A list of text content containing the SARIF report of pipeline findings.
    :rtype: List[types.TextContent]
    """
    return await pipeline_plumber_scan_impl(project_dir)

# SAST
@mcp.tool()
@respects_toggle("opengrep")
async def sast_opengrep_scan(project_dir: str) -> List[types.TextContent]:
    """
    Performs a SAST (Static Application Security Testing) scan using OpenGrep on the
    specified project directory. This function executes the underlying implementation
    of the scan asynchronously and returns the findings as a list of textual content.

    :param project_dir: The directory of the project to scan.
    :type project_dir: str
    :return: A list of text content representing the scan findings.
    :rtype: List[types.TextContent]
    """
    return await sast_opengrep_scan_impl(project_dir)

@mcp.tool()
@respects_toggle("codeql")
async def sast_codeql_scan(project_dir: str, language: str) -> List[types.TextContent]:
    """
    Performs a SAST (Static Application Security Testing) scan using GitHub CodeQL on
    the specified project directory and returns the findings as a SARIF 2.1.0 report.

    CodeQL builds a database from the source tree and runs the standard
    ``codeql/<language>-queries`` code-scanning suite against it, producing a SARIF
    report suitable for GitHub Code Scanning integration. A source language must be
    provided because CodeQL analyzes one language per invocation.

    :param project_dir: The directory of the project to scan.
    :type project_dir: str
    :param language: Source language to analyze (e.g. python, javascript, java,
        csharp, cpp, go, ruby, swift, rust, actions). Common aliases such as
        typescript or kotlin are accepted.
    :type language: str
    :return: A list of text content representing the SARIF scan findings.
    :rtype: List[types.TextContent]
    """
    return await sast_codeql_scan_impl(project_dir, language)

if __name__ == "__main__":
    mcp.run("streamable-http")
