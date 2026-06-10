"""Central registry of the security scanners exposed by this project.

Both the CLI (cli.py) and, potentially, other entrypoints use this registry so
the list of tools, their family, the mode they run in (static = scans a
directory, dynamic = scans a URL) and the report format they emit live in one
place.
"""
import shutil
import subprocess
from dataclasses import dataclass
from typing import Callable, List

import mcp.types as types

from config import scanner_enabled, env_var_for
from security.trivy import sca_trivy_scan_impl, iac_trivy_misconfig_scan_impl, license_trivy_scan_impl
from security.osv_scanner import sca_osv_scanner_scan_impl
from security.gitleaks import secret_gitleaks_scan_impl
from security.nosey_parker import secret_nosey_parker_scan_impl
from security.titus import secret_titus_scan_impl
from security.kingfisher import secret_kingfisher_scan_impl
from security.trufflehog import secret_trufflehog_scan_impl
from security.betterleaks import secret_betterleaks_scan_impl
from security.opengrep import sast_opengrep_scan_impl
from security.codeql import sast_codeql_scan_impl
from security.plumber import pipeline_plumber_scan_impl
from security.nuclei import dast_nuclei_scan_impl
from security.zap import dast_zaproxy_scan_impl

STATIC = "static"   # scans a local directory
DYNAMIC = "dynamic"  # scans a running target URL


@dataclass(frozen=True)
class Scanner:
    name: str
    family: str          # SCA, Secret, SAST, Pipeline, DAST
    mode: str            # STATIC or DYNAMIC
    fmt: str             # "sarif" or "json"
    impl: Callable       # async implementation returning List[types.TextContent]
    needs_language: bool = False

    async def run(self, target: str, language: str = "python") -> List[types.TextContent]:
        """Invoke the underlying impl with the right signature for this scanner."""
        if self.needs_language:
            return await self.impl(target, language)
        return await self.impl(target)


SCANNERS: List[Scanner] = [
    # --- SCA (static) ---
    Scanner("trivy", "SCA", STATIC, "sarif", sca_trivy_scan_impl),
    Scanner("osv-scanner", "SCA", STATIC, "sarif", sca_osv_scanner_scan_impl),
    # --- IaC misconfiguration (static) ---
    Scanner("trivy-misconfig", "IaC", STATIC, "sarif", iac_trivy_misconfig_scan_impl),
    # --- License compliance (static) ---
    Scanner("trivy-license", "License", STATIC, "sarif", license_trivy_scan_impl),
    # --- Secret detection (static) ---
    Scanner("gitleaks", "Secret", STATIC, "sarif", secret_gitleaks_scan_impl),
    Scanner("nosey_parker", "Secret", STATIC, "sarif", secret_nosey_parker_scan_impl),
    Scanner("titus", "Secret", STATIC, "sarif", secret_titus_scan_impl),
    Scanner("kingfisher", "Secret", STATIC, "sarif", secret_kingfisher_scan_impl),
    Scanner("trufflehog", "Secret", STATIC, "sarif", secret_trufflehog_scan_impl),
    Scanner("betterleaks", "Secret", STATIC, "sarif", secret_betterleaks_scan_impl),
    # --- SAST (static) ---
    Scanner("opengrep", "SAST", STATIC, "sarif", sast_opengrep_scan_impl),
    Scanner("codeql", "SAST", STATIC, "sarif", sast_codeql_scan_impl, needs_language=True),
    # --- Pipeline / CI-CD (static) ---
    Scanner("plumber", "Pipeline", STATIC, "sarif", pipeline_plumber_scan_impl),
    # --- DAST (dynamic) ---
    Scanner("nuclei", "DAST", DYNAMIC, "sarif", dast_nuclei_scan_impl),
    Scanner("zaproxy", "DAST", DYNAMIC, "json", dast_zaproxy_scan_impl),
]

BY_NAME = {s.name: s for s in SCANNERS}

ZAP_IMAGE = "ghcr.io/zaproxy/zaproxy:stable"


def scanners_for_mode(mode: str, include_disabled: bool = False) -> List[Scanner]:
    """Scanners for a mode. By default, scanners disabled via their environment
    toggle (e.g. CODEQL=False) are excluded; pass include_disabled=True to keep
    them (used by --list to show their status)."""
    return [s for s in SCANNERS
            if s.mode == mode and (include_disabled or scanner_enabled(s.name))]


def docker_image_present(image: str = ZAP_IMAGE) -> bool:
    """True if Docker is installed and the given image is already pulled locally.
    Used to skip zaproxy fast instead of triggering a multi-GB pull mid-scan."""
    if not shutil.which("docker"):
        return False
    try:
        r = subprocess.run(["docker", "image", "inspect", image], capture_output=True, timeout=15)
        return r.returncode == 0
    except Exception:  # noqa: BLE001
        return False