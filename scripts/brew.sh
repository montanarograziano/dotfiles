#!/usr/bin/env zsh

echo "Checking if Xcode Command Line Tools are installed..."

# Check if Xcode Command Line Tools are installed
if ! xcode-select --print-path &>/dev/null; then
    echo "Xcode Command Line Tools not found. Installing..."
    xcode-select --install &>/dev/null

    echo "Waiting for Xcode Command Line Tools installation to complete..."
    until xcode-select --print-path &>/dev/null; do
        sleep 10
    done

    echo "✔︎ Xcode Command Line Tools installed successfully!"

    # Agree to the Xcode license
    echo "Agreeing to the Xcode Command Line Tools license..."
    sudo xcodebuild -license accept
else
    echo "✔︎ Xcode Command Line Tools are already installed."
fi

echo "Checking if Homebrew is installed..."

# Check if Homebrew is installed
if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to the shell environment
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo "✔︎ Homebrew installed successfully!"
else
    echo "✔︎ Homebrew is already installed."
fi

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

echo "✔︎ Script completed successfully!"
