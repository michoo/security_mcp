"""Loads .env and resolves per-scanner enable/disable toggles.

Any scanner can be disabled with an environment variable named after it —
uppercased, with ``-`` replaced by ``_``. For example::

    CODEQL=False            # disable codeql
    OSV_SCANNER=false       # disable osv-scanner
    TRIVY_MISCONFIG=0       # disable the IaC misconfig scan
    NUCLEI=off              # disable nuclei

Values ``false`` / ``0`` / ``no`` / ``off`` / ``disable`` / ``disabled``
(case-insensitive) disable the scanner; anything else — or leaving the variable
unset — leaves it enabled. Real process environment variables take precedence
over values in the .env file.
"""
import os
from pathlib import Path

_REPO_ROOT = Path(__file__).resolve().parent
_ENV_FILE = _REPO_ROOT / ".env"
_FALSEY = {"false", "0", "no", "off", "disable", "disabled"}


def _load_dotenv(path: Path) -> None:
    """Load KEY=VALUE pairs from `path` into os.environ without overriding
    variables already set in the real environment."""
    try:
        from dotenv import load_dotenv  # python-dotenv, if available
        load_dotenv(path, override=False)
        return
    except Exception:  # noqa: BLE001 — fall back to a minimal parser
        pass
    if not path.is_file():
        return
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, value = line.partition("=")
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        if key:
            os.environ.setdefault(key, value)


_load_dotenv(_ENV_FILE)


def env_var_for(scanner_name: str) -> str:
    """The environment variable name that toggles a given scanner."""
    return scanner_name.upper().replace("-", "_")


def scanner_enabled(scanner_name: str) -> bool:
    """True unless the scanner's toggle variable is set to a falsey value."""
    value = os.environ.get(env_var_for(scanner_name))
    if value is None:
        return True
    return value.strip().lower() not in _FALSEY