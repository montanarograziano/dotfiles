#! /bin/zsh

# -e exit on error
# -u error on undefined variables
# -o option
# pipefail exits on command pipe failures
set -euo pipefail

echo "running macos defaults..."
# macos
./scripts/macos.sh

DOTFILES_REPO="https://github.com/montanarograziano/dotfiles"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config.bak"

# Check if the config directory exists
if ! [[ -d "$CONFIG_DIR" ]]; then
    echo "Cloning dotfiles repository into '$CONFIG_DIR'..."
    git clone "$DOTFILES_REPO" "$CONFIG_DIR"
else
    echo "⚠️ '$CONFIG_DIR' already exists."
    read -r -p "Replace dotfiles? (Contents of '$CONFIG_DIR' will not be deleted) [y/N] " response
    if [[ $response =~ ^(y|yes|Y)$ ]]; then
        # Move the existing directory to a backup location
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
        echo "⚠️ Did not clone dotfiles. This script might fail if a required binary is not found."
        echo "If necessary, you can manually clone the repository or ensure all dependencies are available."
    fi
fi

ln -s "$HOME/.config/.gitconfig" "$HOME/.gitconfig"

./scripts/brew.sh

# alias
ln -sfn "$PWD/.alias" "$HOME/.alias"

# zsh
ln -sfn "$PWD/.zshrc" "$HOME/.zshrc"

# Cookiecutter
cp -r "$PWD/cookiecutter/" "$HOME/.config/cookiecutter"

echo "Finished :)"
