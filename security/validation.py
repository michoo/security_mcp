"""Input validation shared by the scanner implementations.

User-controlled scan targets (a project directory) are handed straight to
external scanner binaries. Several scanners take the directory as a *positional*
argument (e.g. ``trivy fs <dir>``, ``kingfisher scan <dir>``), so a value that
begins with a dash — ``--output=/etc/cron.d/x``, ``--config=https://evil/...`` —
is parsed by the tool as an *option* instead of a path. That is classic
argument injection (CWE-88): the caller controls scanner flags, which for these
tools can write files to arbitrary paths or pull remote configuration.

``resolve_scan_dir`` neutralizes this by canonicalizing the value to an absolute
path before it ever reaches a subprocess. An absolute path always starts with
``/`` (or a drive letter on Windows), so it can never be mistaken for an option.
Option-like input is rejected outright so the caller gets a clear error rather
than a confusing tool-side parse failure.
"""
import os


class ScanTargetError(ValueError):
    """Raised when a scan target is missing, option-like, or not a directory."""


def resolve_scan_dir(project_dir: str) -> str:
    """Canonicalize a user-supplied project directory to a safe absolute path.

    Returns the resolved absolute path. Raises :class:`ScanTargetError` when the
    value is empty, looks like a command-line option, or does not point at an
    existing directory. Canonicalization is what defuses argument injection: the
    returned value can never reach a scanner as a leading-dash option.
    """
    if not project_dir or not project_dir.strip():
        raise ScanTargetError("project_dir is required")
    raw = project_dir.strip()
    # Reject explicit option-like input up front for a clear, actionable error.
    if raw.startswith("-"):
        raise ScanTargetError(
            f"refusing option-like scan target {raw!r}: a directory path must not start with '-'"
        )
    abs_path = os.path.abspath(raw)
    if not os.path.isdir(abs_path):
        raise ScanTargetError(f"scan target is not an existing directory: {abs_path}")
    return abs_path
