#!/usr/bin/env zsh
# Entrypoint for a fresh Apple Silicon Mac. Installs Xcode Command Line
# Tools, Homebrew, and chezmoi, then lets chezmoi drive the rest of the
# provisioning (macOS defaults, Brewfile, dev tools: see home/run_once_*
# and home/run_onchange_* in the dotfiles repo).
#
# chezmoi only ever manages the specific entries tracked in its source
# state; it never deletes or wholesale-replaces ~/.config, so this script
# is safe to re-run on a machine that already has one.
#
# Usage:
#   curl -O https://raw.githubusercontent.com/montanarograziano/dotfiles/main/scripts/bootstrap.sh
#   chmod +x bootstrap.sh
#   ./bootstrap.sh          # NOT with sudo
#
# Override the source repo (e.g. a fork) with:
#   DOTFILES_REPO=someone/dotfiles ./bootstrap.sh

set -euo pipefail

echo "Starting bootstrap process for macOS (Apple Silicon)..."

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "✗ This bootstrap only supports macOS. Aborting." >&2
    exit 1
fi

if [[ "$(uname -m)" != "arm64" ]]; then
    echo "✗ This bootstrap only supports Apple Silicon (arm64) Macs. Aborting." >&2
    exit 1
fi

if [[ "$(id -u)" -eq 0 ]]; then
    echo "✗ Do not run this with sudo/as root. Re-run as your normal user." >&2
    exit 1
fi

# Install Xcode Command Line Tools (includes Git)
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

# Install Homebrew
if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "✔︎ Homebrew installed successfully!"
else
    echo "✔︎ Homebrew is already installed."
fi

eval "$(/opt/homebrew/bin/brew shellenv)"

# Install chezmoi via Homebrew if not already available
if ! command -v chezmoi &>/dev/null; then
    echo "Installing chezmoi via Homebrew..."
    brew install chezmoi
    echo "✔︎ chezmoi installed successfully!"
else
    echo "✔︎ chezmoi is already installed."
fi

# Source repo for the dotfiles. Override by exporting DOTFILES_REPO before
# running (e.g. when using a fork): DOTFILES_REPO=someone/dotfiles ./bootstrap.sh
DOTFILES_REPO="${DOTFILES_REPO:-montanarograziano/dotfiles}"

# `chezmoi init` clones $DOTFILES_REPO into chezmoi's own source directory
# (~/.local/share/chezmoi by default) -- it does not touch ~/.config here.
# If a source directory already exists, chezmoi leaves it as-is instead of
# re-cloning, which is what makes this safe to re-run.
echo "Initializing chezmoi from '$DOTFILES_REPO'..."
chezmoi init "$DOTFILES_REPO"
echo "✔︎ chezmoi source ready."

# Preview what chezmoi would change before touching anything. `chezmoi
# diff` is read-only, and `chezmoi apply` below only ever creates/updates
# the specific files and runs the specific scripts tracked in the source
# state -- it never deletes or replaces ~/.config wholesale.
echo
echo "The following changes would be applied to your home directory:"
chezmoi diff || true
echo

read -r "response?Apply these changes now? [y/N]: "
if [[ "$response" =~ ^(y|yes|Y)$ ]]; then
    chezmoi apply
    echo "✔︎ chezmoi apply completed!"
else
    echo "⚠️ Skipped 'chezmoi apply'. Review the diff above, then run 'chezmoi apply' yourself when ready."
fi

echo "✔︎ Bootstrap process completed!"
echo "Open a new terminal, or run: exec zsh -l"
