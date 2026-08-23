#!/bin/bash
# run_once_before: verify Apple Silicon macOS, then install Xcode Command
# Line Tools (for git) and Homebrew. Runs once; chezmoi re-runs it if this
# script's content ever changes.
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "✗ This dotfiles setup only supports macOS. Aborting." >&2
    exit 1
fi

if [[ "$(uname -m)" != "arm64" ]]; then
    echo "✗ This dotfiles setup only supports Apple Silicon (arm64) Macs. Aborting." >&2
    exit 1
fi

echo "Verified macOS on Apple Silicon."

if ! xcode-select --print-path &>/dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install &>/dev/null || true

    echo "Waiting for Xcode Command Line Tools installation to complete..."
    until xcode-select --print-path &>/dev/null; do
        sleep 10
    done

    echo "✔︎ Xcode Command Line Tools installed successfully!"
else
    echo "✔︎ Xcode Command Line Tools are already installed."
fi

if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "✔︎ Homebrew installed successfully!"
else
    echo "✔︎ Homebrew is already installed."
fi
