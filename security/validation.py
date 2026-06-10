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

It additionally enforces an optional *scan root* confinement: when the
``SECURITY_MCP_SCAN_ROOT`` environment variable is set, every scan target must
resolve (after following symlinks) to a path inside that root. This bounds what
an operator — or an agent driving the MCP tools that was steered by injected
instructions — can point the scanners at, preventing them from reading secrets
out of arbitrary locations such as ``/`` or ``~/.ssh`` (CWE-22 / CWE-552). The
control is opt-in: with the variable unset, behaviour is unchanged.
"""
import os

# When set, scan targets are confined to this directory tree (see module docstring).
SCAN_ROOT_ENV = "SECURITY_MCP_SCAN_ROOT"


class ScanTargetError(ValueError):
    """Raised when a scan target is missing, option-like, out of bounds, or not a directory."""


def _scan_root() -> str | None:
    """The configured scan-root confinement directory (realpath), or None when
    confinement is disabled (the variable is unset or empty)."""
    root = os.environ.get(SCAN_ROOT_ENV)
    if not root or not root.strip():
        return None
    return os.path.realpath(root.strip())


def _within(child: str, root: str) -> bool:
    """True if `child` is `root` itself or lives somewhere beneath it. Both are
    expected to be realpaths, so this comparison is not fooled by symlinks or
    ``..`` segments."""
    return child == root or child.startswith(root + os.sep)


def resolve_scan_dir(project_dir: str) -> str:
    """Canonicalize a user-supplied project directory to a safe absolute path.

    Returns the resolved absolute path. Raises :class:`ScanTargetError` when the
    value is empty, looks like a command-line option, does not point at an
    existing directory, or — when ``SECURITY_MCP_SCAN_ROOT`` is set — resolves
    outside the permitted scan root. Canonicalization is what defuses argument
    injection: the returned value can never reach a scanner as a leading-dash
    option.
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

    root = _scan_root()
    if root is not None:
        # Follow symlinks on both sides so a symlink *inside* the root that points
        # out of it cannot be used to escape the confinement.
        real = os.path.realpath(abs_path)
        if not _within(real, root):
            raise ScanTargetError(
                f"scan target {real!r} is outside the permitted scan root {root!r} "
                f"(set via {SCAN_ROOT_ENV})"
            )
        return real
    return abs_path
