#!/bin/bash
# run_once_after: one-off cleanup for machines previously bootstrapped with
# the legacy scripts/tools.sh, which appended this exact line to the
# SYSTEM-WIDE /etc/zshenv (requiring sudo, and affecting every user on the
# machine). That mechanism is being retired, so the stale line is removed
# here, once regular targets (including the new dot_zshenv, which sets
# ZDOTDIR itself) have already been materialized.
#
# Only ever removes the exact legacy line, and only if present. Safe to
# re-run: a no-op once the line is gone.
set -euo pipefail

ZSHENV_FILE="/etc/zshenv"
ZDOTDIR_LINE='export ZDOTDIR="$HOME/.config/zsh"'

if [[ -f "$ZSHENV_FILE" ]] && grep -qxF "$ZDOTDIR_LINE" "$ZSHENV_FILE"; then
    echo "Removing legacy ZDOTDIR line from '$ZSHENV_FILE'..."
    tmp_file="$(mktemp)"
    # grep exits 1 when it selects zero lines, which is the normal outcome
    # here whenever the legacy line is the file's ONLY line (the common case:
    # the old tools.sh created /etc/zshenv just to hold it). Under `set -e`
    # that killed the script before the sudo cp below, leaving the line in
    # place. Tolerate exit 1, still fail on exit >1 (unreadable file, etc).
    grep -vxF "$ZDOTDIR_LINE" "$ZSHENV_FILE" >"$tmp_file" || [[ $? -eq 1 ]]
    sudo cp "$tmp_file" "$ZSHENV_FILE"
    rm -f "$tmp_file"
    echo "✔︎ Removed legacy ZDOTDIR line from '$ZSHENV_FILE'."
else
    echo "✔︎ No legacy ZDOTDIR line found in '$ZSHENV_FILE'. Nothing to do."
fi
