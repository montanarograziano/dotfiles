#!/usr/bin/env zsh
set -euo pipefail
# Set the desired ZDOTDIR configuration
ZDOTDIR_LINE='export ZDOTDIR="$HOME/.config/zsh"'
ZSHENV_FILE="/etc/zshenv"

echo "Configuring ZDOTDIR in '/etc/zshenv'..."

if [[ -f "$ZSHENV_FILE" ]]; then
    if ! grep -qF "$ZDOTDIR_LINE" "$ZSHENV_FILE"; then
        echo "$ZDOTDIR_LINE" | sudo tee -a "$ZSHENV_FILE" >/dev/null
        echo "✔︎ Appended '$ZDOTDIR_LINE' to '$ZSHENV_FILE'."
    else
        echo "✔︎ '$ZDOTDIR_LINE' is already present in '$ZSHENV_FILE'."
    fi
else
    echo "$ZDOTDIR_LINE" | sudo tee "$ZSHENV_FILE" >/dev/null
    echo "✔︎ Created '$ZSHENV_FILE' and added '$ZDOTDIR_LINE'."
fi

# Install uv tool
echo "Installing uv (https://github.com/astral-sh/uv#uv)..."

if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    echo "✔︎ uv installed successfully."
else
    echo "✔︎ uv is already installed."
fi

# Define Python versions to install
PYTHON_VERSIONS=(
    "3.12"
    "3.11"
    "3.10"
    "3.9"
)

# Install specified Python versions using uv
echo "Installing Python versions with uv..."
for version in "${PYTHON_VERSIONS[@]}"; do
    if uv python install -- "$version"; then
        echo "✔︎ Python $version installed successfully."
    else
        echo "⚠️ Failed to install Python $version. Skipping..."
    fi
done

# Define Python libraries to install
PYTHON_LIBRARIES=(
    "commitizen"
    "cookiecutter"
    "mypy"
    "pytest"
    "ruff"
    "ipykernel"
    "pre-commit"
)

# Use the first Python version as the "safe" version
SAFE_VERSION="${PYTHON_VERSIONS[1]}"
echo "Installing Python libraries using uv (safe version: $SAFE_VERSION)..."

for lib in "${PYTHON_LIBRARIES[@]}"; do
    if uv tool install --force --upgrade --python="$SAFE_VERSION" -- "$lib"; then
        echo "✔︎ Installed '$lib' successfully."
    else
        echo "⚠️ Failed to install '$lib'. Skipping..."
    fi
done

# Set Rust environment variables
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export CARGO_HOME="$XDG_DATA_HOME/cargo"

# Install Rust if not already installed
echo "Checking for Rust installation..."
if ! command -v rustup &>/dev/null; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    echo "✔︎ Rust installed successfully."
else
    echo "✔︎ Rust is already installed."
fi

# Uncomment the lines below to include Rust stable version and rust-analyzer setup
echo "Setting up Rust stable version and rust-analyzer..."
rustup install stable
rustup component add rust-analyzer --toolchain=stable
echo "✔︎ Rust and rust-analyzer setup completed."

echo "✔︎ Script completed successfully!"
