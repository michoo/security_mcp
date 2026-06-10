#!/bin/bash
#
# Install every security tool by running each tool's own install.sh.
#
# Discovers every install.sh under this directory (one per tool), runs it from
# inside the tool's own directory (the per-tool scripts use relative paths so
# they must be run there), and prints a summary at the end. A tool that fails is
# reported but does not stop the others; the script exits non-zero if any failed.
#
# Counterpart to uninstall.sh.
#
# Usage:
#   ./install-all.sh                 # install every tool
#   ./install-all.sh trivy nuclei    # install only the named tools (directory names)
#   ./install-all.sh --list          # list the discovered tools and exit
#   ./install-all.sh --dry-run       # show what would run, install nothing
#   ./install-all.sh --help          # show this help
#
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() { sed -n '2,/^set -u/{/^set -u/d;s/^# \{0,1\}//;p}' "${BASH_SOURCE[0]}"; }

DRY_RUN=0
LIST_ONLY=0
declare -a WANTED=()
for arg in "$@"; do
  case "$arg" in
    -n|--dry-run) DRY_RUN=1 ;;
    -l|--list)    LIST_ONLY=1 ;;
    -h|--help)    usage; exit 0 ;;
    -*)           echo "unknown option: $arg" >&2; usage >&2; exit 2 ;;
    *)            WANTED+=("$arg") ;;
  esac
done

# Discover every per-tool install.sh (this orchestrator is install-all.sh, so it
# is not matched), sorted for a deterministic order.
declare -a INSTALL_SCRIPTS=()
while IFS= read -r line; do INSTALL_SCRIPTS+=("$line"); done \
  < <(find "$SCRIPT_DIR" -name install.sh -type f | sort)

if [ "${#INSTALL_SCRIPTS[@]}" -eq 0 ]; then
  echo "error: no install.sh scripts found under $SCRIPT_DIR" >&2
  exit 1
fi

# Names of every discovered tool (basename of its directory), used to validate
# requested names.
declare -a ALL_NAMES=()
for s in "${INSTALL_SCRIPTS[@]}"; do ALL_NAMES+=("$(basename "$(dirname "$s")")"); done

wanted() {  # 0 if the given tool name should be installed
  [ "${#WANTED[@]}" -eq 0 ] && return 0
  local w
  for w in "${WANTED[@]}"; do [ "$w" = "$1" ] && return 0; done
  return 1
}

# Warn about unknown requested names (typos shouldn't silently install nothing).
if [ "${#WANTED[@]}" -gt 0 ]; then
  for w in "${WANTED[@]}"; do
    found=0
    for n in "${ALL_NAMES[@]}"; do [ "$n" = "$w" ] && found=1 && break; done
    [ "$found" -eq 0 ] && echo "warning: requested tool not found: $w" >&2
  done
fi

if [ "$LIST_ONLY" -eq 1 ]; then
  echo "Tools discovered under $SCRIPT_DIR:"
  for s in "${INSTALL_SCRIPTS[@]}"; do
    name="$(basename "$(dirname "$s")")"
    wanted "$name" && echo "  ${name}  (${s#"$SCRIPT_DIR"/})"
  done
  exit 0
fi

# Preflight: warn about commonly required commands (installers fail clearly on
# their own, but a single up-front warning is friendlier).
for cmd in wget tar unzip sha256sum; do
  command -v "$cmd" >/dev/null 2>&1 || echo "warning: '$cmd' not found; some installers may fail" >&2
done
command -v docker >/dev/null 2>&1 || echo "warning: 'docker' not found; docker-based installers (zaproxy) will fail" >&2

declare -a OK=() FAILED=()
[ "$DRY_RUN" -eq 1 ] && echo "[dry-run] nothing will be downloaded or installed"

for script in "${INSTALL_SCRIPTS[@]}"; do
  tool_dir="$(dirname "$script")"
  name="$(basename "$tool_dir")"
  wanted "$name" || continue

  echo "==> ${name}  (${script#"$SCRIPT_DIR"/})"
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "    [dry-run] (cd $tool_dir && bash install.sh)"
    OK+=("$name")
    continue
  fi

  ( cd "$tool_dir" && bash install.sh )
  rc=$?
  if [ "$rc" -eq 0 ]; then
    echo "    ✓ ${name} installed"
    OK+=("$name")
  else
    echo "    ✗ ${name} FAILED (exit $rc)" >&2
    FAILED+=("$name")
  fi
done

echo
echo "=== Summary ==="
echo "  installed: ${#OK[@]}${OK[*]:+  (${OK[*]})}"
if [ "${#FAILED[@]}" -gt 0 ]; then
  echo "  failed:    ${#FAILED[@]}  (${FAILED[*]})" >&2
  exit 1
fi
echo "All requested tools installed."
