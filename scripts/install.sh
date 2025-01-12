#!/usr/bin/env zsh

# Exit immediately if a command exits with a non-zero status,
# error on undefined variables, and fail on pipe errors.
set -euo pipefail

# Function to safely run scripts
run_script() {
    local script_path="$1"

    if [[ -f "$script_path" ]]; then
        echo "Running $script_path..."
        "$script_path"
        echo "✔︎ Successfully executed $script_path."
    else
        echo "⚠️ Error: Script '$script_path' not found. Skipping."
    fi
}

echo "Setting macOS defaults..."
run_script "$XDG_CONFIG_HOME/scripts/settings.sh"

# Run Homebrew script, needed to install git first
run_script "$XDG_CONFIG_HOME/scripts/brew.sh"

# Variables
FILES_TO_LINK=(".alias" ".zshrc" ".gitconfig")
COOKIECUTTER_SOURCE="./cookiecutter/"
COOKIECUTTER_DEST="$CONFIG_DIR/cookiecutter"

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
run_script "$XDG_CONFIG_HOME/scripts/tools.sh"

echo "✔︎ Finished setup!"
