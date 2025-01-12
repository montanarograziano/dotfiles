#!/usr/bin/env zsh

# Prompt user to install dependencies from Brewfile
read -r -p "Do you want to install dependencies from Brewfile? [y/N]: " response
if [[ "$response" =~ ^(y|yes|Y)$ ]]; then
    BREWFILE="$HOME/.config/Brewfile"
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

# Set XDG directories (persistent)
XDG_DATA_HOME="$HOME/.local/share"
XDG_STATE_HOME="$HOME/.local/state"
export XDG_DATA_HOME XDG_STATE_HOME

# Ensure these variables are persistent across sessions
if ! grep -q "XDG_DATA_HOME" "$HOME/.zshrc"; then
    echo "export XDG_DATA_HOME=\"$XDG_DATA_HOME\"" >> "$HOME/.zshrc"
fi
if ! grep -q "XDG_STATE_HOME" "$HOME/.zshrc"; then
    echo "export XDG_STATE_HOME=\"$XDG_STATE_HOME\"" >> "$HOME/.zshrc"
fi

echo "✔︎ Environment variables for XDG directories set."

echo "✔︎ Brew script completed successfully!"
