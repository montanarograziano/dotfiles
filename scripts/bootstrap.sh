#!/bin/zsh

# Exit on error
set -e

echo "Starting bootstrap process for macOS..."

# Install Xcode Command Line Tools (includes Git)
if ! xcode-select --print-path &>/dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install &>/dev/null

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
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to the shell environment
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo "✔︎ Homebrew installed successfully!"
else
    echo "✔︎ Homebrew is already installed."
fi

# Install Git via Homebrew if not already available
if ! command -v git &>/dev/null; then
    echo "Installing Git via Homebrew..."
    brew install git
    echo "✔︎ Git installed successfully!"
else
    echo "✔︎ Git is already installed."
fi

# Clone your repository
DOTFILES_REPO="https://github.com/montanarograziano/dotfiles"
TARGET_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config.bak"

if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Cloning dotfiles repository into '$TARGET_DIR'..."
    git clone "$DOTFILES_REPO" "$TARGET_DIR"
    echo "✔︎ Repository cloned successfully!"
else
    read -r -p "⚠️ Repository already exists at '$TARGET_DIR'. Replace dotfiles? (Contents of '$TARGET_DIR' will not be deleted) [y/N]: " response
    if [[ "$response" =~ ^(y|yes|Y)$ ]]; then
    # Backup existing config directory
    if [[ -d "$BACKUP_DIR" ]]; then
      echo "⚠️ Backup directory '$BACKUP_DIR' already exists. Removing it first..."
      rm -rf "$BACKUP_DIR"
    fi
    mv "$CONFIG_DIR" "$BACKUP_DIR"
    echo "✔︎ Moved old configs to '$BACKUP_DIR'."
    # Clone the repository
    echo "Cloning dotfiles repository into '$TARGET_DIR'..."
    git clone "$DOTFILES_REPO" "$TARGET_DIR"
  else
    echo "⚠️ Skipped cloning dotfiles. Ensure all dependencies are manually installed."
fi

# Run the main installation script
echo "Running the main installation script..."
cd "$TARGET_DIR" || exit
./scripts/install.sh

echo "✔︎ Bootstrap process completed!"