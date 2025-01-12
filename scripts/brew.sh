#!/usr/bin/env zsh

set -euo pipefail

# Define constants
BREWFILE="$HOME/.config/Brewfile"
XDG_DATA_HOME="$HOME/.local/share"
XDG_STATE_HOME="$HOME/.local/state"
ZSHRC_FILE="$HOME/.zshrc"

echo "Starting Brew setup..."

# Prompt to install dependencies from Brewfile
read -r "response?Do you want to install dependencies from Brewfile? [y/N]: "
if [[ "$response" =~ ^(y|yes|Y)$ ]]; then
    if [[ -f "$BREWFILE" ]]; then
        echo "Installing dependencies from Brewfile..."
        brew bundle --file="$BREWFILE"
        echo "✔︎ Dependencies installed successfully!"
    else
        echo "⚠️ Brewfile not found at '$BREWFILE'. Skipping dependency installation."
    fi
else
    echo "Skipping Brewfile installation."
fi

# Set XDG directories
echo "Setting XDG environment variables..."

export XDG_DATA_HOME XDG_STATE_HOME

# Persist XDG directories in .zshrc
persist_env_var() {
    local var_name="$1"
    local var_value="$2"
    if ! grep -qF "export $var_name=" "$ZSHRC_FILE"; then
        echo "export $var_name=\"$var_value\"" >> "$ZSHRC_FILE"
        echo "✔︎ Added $var_name to $ZSHRC_FILE."
    else
        echo "✔︎ $var_name already set in $ZSHRC_FILE."
    fi
}

persist_env_var "XDG_DATA_HOME" "$XDG_DATA_HOME"
persist_env_var "XDG_STATE_HOME" "$XDG_STATE_HOME"

echo "✔︎ Environment variables for XDG directories set."
echo "✔︎ Brew setup completed successfully!"
