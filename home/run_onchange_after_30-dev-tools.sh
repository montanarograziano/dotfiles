#!/usr/bin/env zsh
# run_onchange_after: install/upgrade dev tooling (uv, Python, global CLI
# tools, Rust). Re-runs automatically whenever this script's content
# changes (e.g. a Python version or tool is added/removed below).
#
# Based on the legacy scripts/tools.sh, minus its /etc/zshenv ZDOTDIR
# wiring (that system-wide, sudo-requiring step is being retired; see
# run_once_after_40-remove-legacy-zshenv-zdotdir.sh).
set -euo pipefail

# Default XDG dirs so a standalone run (before dot_config/zsh is sourced)
# doesn't trip `set -u` further down (e.g. the Rust setup).
: "${XDG_DATA_HOME:=$HOME/.local/share}"

# Homebrew and uv both need to be on PATH; a fresh chezmoi apply run may
# not have sourced any shell rc yet.
export PATH="/opt/homebrew/bin:$HOME/.local/bin:$PATH"

echo "Installing uv (https://github.com/astral-sh/uv#uv)..."
if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    echo "✔︎ uv installed successfully."
else
    echo "✔︎ uv is already installed."
fi

# uv installs to ~/.local/bin; make sure the rest of this script finds it.
export PATH="$HOME/.local/bin:$PATH"

# Supported (non end-of-life) Python versions. 3.9 reached EOL and was
# dropped; 3.13 is the current stable release.
PYTHON_VERSIONS=(
    "3.13"
    "3.12"
    "3.11"
    "3.10"
)

echo "Installing Python versions with uv..."
for version in "${PYTHON_VERSIONS[@]}"; do
    if uv python install -- "$version"; then
        echo "✔︎ Python $version installed successfully."
    else
        echo "⚠️ Failed to install Python $version. Skipping..."
    fi
done

# Python CLI tools installed globally with `uv tool`. Only packages that
# expose executables belong here. Libraries like ipykernel provide no
# entrypoint and must be added per-project (e.g. `uv add ipykernel`).
PYTHON_LIBRARIES=(
    "commitizen"
    "cookiecutter"
    "marimo"
    "mypy"
    "pytest"
    "ruff"
    "pre-commit"
)

# Use the first (newest) Python version as the "safe" version for tools.
SAFE_VERSION="${PYTHON_VERSIONS[1]}"
echo "Installing Python libraries using uv (safe version: $SAFE_VERSION)..."

for lib in "${PYTHON_LIBRARIES[@]}"; do
    if uv tool install --force --upgrade --python="$SAFE_VERSION" -- "$lib"; then
        echo "✔︎ Installed '$lib' successfully."
    else
        echo "⚠️ Failed to install '$lib'. Skipping..."
    fi
done

# Rust environment variables, derived from XDG_DATA_HOME so nothing here is
# hardcoded independently of dot_config/zsh (which sources the same paths).
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export CARGO_HOME="$XDG_DATA_HOME/cargo"

echo "Checking for Rust installation..."
if ! command -v rustup &>/dev/null; then
    echo "Installing Rust..."
    # --no-modify-path: don't let rustup append a hardcoded cargo-env line to
    # shell startup files; dot_config/zsh already sources it generically.
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    echo "✔︎ Rust installed successfully."
else
    echo "✔︎ Rust is already installed."
fi

# rustup/cargo install into $CARGO_HOME/bin, which isn't on PATH yet here.
export PATH="$CARGO_HOME/bin:$PATH"

echo "Setting up Rust stable version and rust-analyzer..."
rustup install stable
rustup component add rust-analyzer --toolchain=stable
echo "✔︎ Rust and rust-analyzer setup completed."

echo "✔︎ Dev tools setup completed successfully!"
