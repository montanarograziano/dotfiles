#!/usr/bin/env zsh

set -euo pipefail

# XDG environment variables are defined in zsh/.zshenv and applied once ZDOTDIR
# is set (see tools.sh). They are intentionally NOT persisted here.
BREWFILE="$HOME/.config/Brewfile"

echo "Starting Brew setup..."

read -r "response?Do you want to install dependencies from Brewfile? [y/N]: "
if [[ "$response" =~ ^(y|yes|Y)$ ]]; then
    if [[ -f "$BREWFILE" ]]; then
        echo "Installing dependencies from Brewfile..."
        # A single failing entry (e.g. a cask that needs a reboot or an
        # interactive installer) should not abort the whole setup.
        if brew bundle --file="$BREWFILE"; then
            echo "✔︎ All Brewfile dependencies installed."
        else
            echo "⚠️ Some Brewfile dependencies failed. Review the output above and re-run 'brew bundle' later."
        fi
    else
        echo "⚠️ Brewfile not found at '$BREWFILE'. Skipping dependency installation."
    fi
else
    echo "Skipping Brewfile installation."
fi

echo "✔︎ Brew setup completed!"
