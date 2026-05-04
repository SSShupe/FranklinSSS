#!/bin/bash
# One-time setup: installs the WordPress post-commit hook.
# Run once after cloning on any machine:
#   bash setup_wp_hook.sh

set -e

REPO_ROOT=$(git rev-parse --show-toplevel)
HOOK_SRC="$REPO_ROOT/Franklin/SSSfinal/hooks/post-commit"
HOOK_DST="$REPO_ROOT/.git/hooks/post-commit"
SCRIPT_PATH="$REPO_ROOT/Franklin/SSSfinal/publish_to_wp.py"

cp "$HOOK_SRC" "$HOOK_DST"
chmod +x "$HOOK_DST"
echo "Hook installed."

if [ ! -f "$SCRIPT_PATH" ]; then
    echo ""
    echo "IMPORTANT: publish_to_wp.py is missing."
    echo "This file contains your WordPress credentials and is intentionally"
    echo "not stored in git. Copy it from your other machine to:"
    echo "  $SCRIPT_PATH"
fi
