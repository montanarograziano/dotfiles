#!/bin/zsh

# Set the desired configuration line
zdotdir_line='export ZDOTDIR="$HOME/.config/zsh"'

# Check if /etc/zshenv exists and update it
if [[ -f "/etc/zshenv" ]]; then
    if ! grep -qF "$zdotdir_line" "/etc/zshenv"; then
        echo "$zdotdir_line" | sudo tee -a "/etc/zshenv" >/dev/null
        echo "✔︎ Appended '$zdotdir_line' to '/etc/zshenv'."
    else
        echo "✔︎ '$zdotdir_line' is already present in '/etc/zshenv'."
    fi
else
    echo "$zdotdir_line" | sudo tee "/etc/zshenv" >/dev/null
    echo "✔︎ Created '/etc/zshenv' and added '$zdotdir_line'."
fi

# Install Python and uv
echo "Installing uv (https://github.com/astral-sh/uv#uv)..."
if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    echo "✔︎ uv installed successfully."
else
    echo "✔︎ uv is already installed."
fi

# Define Python versions to install
python_versions=(
    "3.12"
    "3.11"
    "3.10"
    "3.9"
)

# Install specified Python versions
echo "Installing Python versions with uv..."
for version in "${python_versions[@]}"; do
    uv python install -- "$version"
done

# Define libraries to install
python_libraries=(
    "commitizen"
    "cookiecutter"
    "mypy"
    "pytest"
    "ruff"
    "ipykernel"
	"pre-commit"
)

# Use the first Python version as the "safe" version
safe_version="${python_versions[1]}"
echo "Installing Python libraries using uv (safe version: $safe_version)..."

for lib in "${python_libraries[@]}"; do
    uv tool install --force --upgrade --python="$safe_version" -- "$lib"
done

# Install Rust
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export CARGO_HOME="$XDG_DATA_HOME/cargo"

if ! command -v rustup &>/dev/null; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    echo "✔︎ Rust installed successfully."
else
    echo "✔︎ Rust is already installed."
fi

# Install Rust stable version and rust-analyzer
# echo "Installing Rust stable version and rust-analyzer..."
# rustup install stable
# rustup component add rust-analyzer --toolchain=stable
# echo "✔︎ Rust and rust-analyzer setup completed."
