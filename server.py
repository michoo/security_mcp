import logging
import sys
import mcp.types as types
from typing import List
from mcp.server.fastmcp import FastMCP

from security.gitleaks import secret_gitleaks_scan_impl
from security.nosey_parker import secret_nosey_parker_scan_impl
from security.nuclei import dast_nuclei_scan_impl
from security.opengrep import sast_opengrep_scan_impl
from security.osv_scanner import sca_osv_scanner_scan_impl
from security.sca import sca_fix_vulnerability
from security.trivy import sca_trivy_scan_impl
from security.zap import dast_zaproxy_scan_impl

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    stream=sys.stdout
)
logger = logging.getLogger(__name__)

mcp = FastMCP("mcp-security-scanner")



# DAST
@mcp.tool()
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


@mcp.tool()
async def sca_fix_vul(pkg_name: str, target_version: str, project_dir: str) -> List[types.TextContent]:
    """
    Fixes vulnerabilities in a specified package by upgrading to the target version.

    This function automates the process of addressing package vulnerabilities by
    upgrading the given package to the provided target version in the specified
    project directory.

    :param pkg_name: Name of the package with the vulnerability.
    :type pkg_name: str
    :param target_version: The version to which the package should be upgraded.
    :type target_version: str
    :param project_dir: Directory of the project where the package exists.
    :type project_dir: str
    :return: A list of text content detailing the results of the vulnerability fix.
    :rtype: List[types.TextContent]
    """
    return await sca_fix_vulnerability(pkg_name, target_version, project_dir)

# SECRET
@mcp.tool()
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

# SAST
@mcp.tool()
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

if __name__ == "__main__":
    mcp.run("streamable-http")
