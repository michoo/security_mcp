#!/bin/bash
#
# Remove all installed security-tool binaries (and extracted artifacts), keeping
# the per-tool install.sh scripts so everything can be reinstalled later.
#
# For every tool directory (any directory containing an install.sh) this deletes
# all of its contents except install.sh itself. Docker images pulled by
# docker-based installers (e.g. zaproxy) are removed best-effort.
#
# Usage:
#   ./uninstall.sh            # remove the binaries
#   ./uninstall.sh --dry-run  # show what would be removed, delete nothing

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DRY_RUN=0
if [ "${1:-}" = "--dry-run" ] || [ "${1:-}" = "-n" ]; then
  DRY_RUN=1
  echo "[dry-run] no files will be deleted"
fi

echo "Removing installed tool binaries under: $SCRIPT_DIR"

# Delete every immediate child of each tool directory except its install.sh.
while IFS= read -r -d '' install_script; do
  tool_dir="$(dirname "$install_script")"
  while IFS= read -r -d '' artifact; do
    echo "  - rm ${artifact#"$SCRIPT_DIR"/}"
    [ "$DRY_RUN" -eq 0 ] && rm -rf "$artifact"
  done < <(find "$tool_dir" -mindepth 1 -maxdepth 1 ! -name install.sh -print0)
done < <(find "$SCRIPT_DIR" -name install.sh -print0)

# Best-effort removal of docker images pulled by docker-based installers.
if command -v docker >/dev/null 2>&1; then
  while IFS= read -r -d '' install_script; do
    while IFS= read -r image; do
      [ -z "$image" ] && continue
      echo "  - docker rmi $image"
      [ "$DRY_RUN" -eq 0 ] && docker rmi "$image" >/dev/null 2>&1 || true
    done < <(grep -oP 'docker pull \K\S+' "$install_script" 2>/dev/null)
  done < <(find "$SCRIPT_DIR" -name install.sh -print0)
fi

echo "Done."