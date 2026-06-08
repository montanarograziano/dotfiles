#!/usr/bin/env zsh

# Exit immediately on error, error on undefined variables, and fail on pipe errors.
set -euo pipefail

# Resolve paths from this script's own location so it works regardless of $PWD
# and without relying on env vars that the shell config has not loaded yet.
SCRIPT_DIR="${0:A:h}"      # absolute dir of this script (symlinks resolved)
REPO_DIR="${SCRIPT_DIR:h}" # repo root (parent of scripts/), normally ~/.config

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
run_script "$SCRIPT_DIR/settings.sh"

# Install Homebrew packages (Brewfile)
run_script "$SCRIPT_DIR/brew.sh"

# Symlink .gitconfig into $HOME. The zsh config is loaded via ZDOTDIR
# (set in tools.sh), so .zshrc needs no symlink.
GITCONFIG_SRC="$REPO_DIR/.gitconfig"
GITCONFIG_DST="$HOME/.gitconfig"
if [[ -f "$GITCONFIG_SRC" ]]; then
    if [[ -e "$GITCONFIG_DST" && ! -L "$GITCONFIG_DST" ]]; then
        mv "$GITCONFIG_DST" "$GITCONFIG_DST.bak"
        echo "✔︎ Backed up existing .gitconfig to '$GITCONFIG_DST.bak'."
    fi
    ln -sfn "$GITCONFIG_SRC" "$GITCONFIG_DST"
    echo "✔︎ Linked .gitconfig to '$GITCONFIG_DST'."
else
    echo "⚠️ '$GITCONFIG_SRC' not found. Skipping .gitconfig link."
fi

# Seed untracked local git config files from their templates if missing.
# Tracked: git/*.example. Local (gitignored): the same names without .example.
echo "Seeding local git config from templates..."
for example in "$REPO_DIR"/git/*.example(N); do
    target="${example%.example}"
    if [[ ! -f "$target" ]]; then
        cp "$example" "$target"
        echo "✔︎ Created '$target' (edit it with your details)."
    fi
done

echo "Installing dev tools (uv, Python, Rust) and configuring ZDOTDIR..."
run_script "$SCRIPT_DIR/tools.sh"

echo "✔︎ Finished setup! Open a new terminal, or run: exec zsh -l"
