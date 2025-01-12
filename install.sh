#!/usr/bin/env zsh

# Exit immediately if a command exits with a non-zero status,
# error on undefined variables, and fail on pipe errors.
set -euo pipefail

echo "Setting macOS defaults..."
./scripts/macos.sh

# Run Homebrew script, needed to install git first
./scripts/brew.sh

# Variables
DOTFILES_REPO="https://github.com/montanarograziano/dotfiles"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config.bak"
FILES_TO_LINK=(".alias" ".zshrc" ".gitconfig")
COOKIECUTTER_SOURCE="./cookiecutter/"
COOKIECUTTER_DEST="$CONFIG_DIR/cookiecutter"

# Clone or update dotfiles repository
if [[ ! -d "$CONFIG_DIR" ]]; then
  echo "Cloning dotfiles repository into '$CONFIG_DIR'..."
  git clone "$DOTFILES_REPO" "$CONFIG_DIR"
else
  echo "⚠️ '$CONFIG_DIR' already exists."
  read -r -p "Replace dotfiles? (Contents of '$CONFIG_DIR' will not be deleted) [y/N]: " response
  if [[ "$response" =~ ^(y|yes|Y)$ ]]; then
    # Backup existing config directory
    if [[ -d "$BACKUP_DIR" ]]; then
      echo "⚠️ Backup directory '$BACKUP_DIR' already exists. Removing it first..."
      rm -rf "$BACKUP_DIR"
    fi
    mv "$CONFIG_DIR" "$BACKUP_DIR"
    echo "✔︎ Moved old configs to '$BACKUP_DIR'."

    # Clone the repository
    echo "Cloning dotfiles repository into '$CONFIG_DIR'..."
    git clone "$DOTFILES_REPO" "$CONFIG_DIR"
  else
    echo "⚠️ Skipped cloning dotfiles. Ensure all dependencies are manually installed."
  fi
fi

# Create symbolic links for specified files
echo "Creating symbolic links..."
for file in "${FILES_TO_LINK[@]}"; do
  if [[ -f "$PWD/$file" ]]; then
    ln -sfn "$PWD/$file" "$HOME/$file"
    echo "✔︎ Linked '$file' to '$HOME/$file'."
  else
    echo "⚠️ File '$PWD/$file' not found. Skipping..."
  fi
done

# Ensure Cookiecutter directory exists and copy files
if [[ -d "$COOKIECUTTER_SOURCE" ]]; then
  mkdir -p "$COOKIECUTTER_DEST"
  cp -r "$COOKIECUTTER_SOURCE"/* "$COOKIECUTTER_DEST"
  echo "✔︎ Copied Cookiecutter templates to '$COOKIECUTTER_DEST'."
else
  echo "⚠️ Cookiecutter source directory '$COOKIECUTTER_SOURCE' not found. Skipping..."
fi

echo "Installing desired tools (Uv, python, rust)..."
./scripts/tools.sh

echo "✔︎ Finished setup!"
