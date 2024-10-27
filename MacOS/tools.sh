#! /bin/zsh
# Install Python and Uv
print "Install uv (https://github.com/astral-sh/uv#uv)"

curl -LsSf https://astral.sh/uv/install.sh | sh

versions=(
    "3.12"
    "3.11"
    "3.10"
    "3.9"
)

safe_version="${versions[1]}"

for version in "${versions[@]}"; do
    uv python install -- "$version"
done

libs=(
    "argcomplete"
    "commitizen"
    "cookiecutter"
    "huggingface-hub[cli]"
    "jupytext"
    "mypy"
    "posting"
    "pytest"
    "ruff"
    "ipykernel"
)

for lib in "${libs[@]}"; do
	uv tool install --upgrade --python="$safe_version" -- "$lib"
done

uv tool install --upgrade --python="$safe_version" --with pre-commit-uv -- pre-commit

# | install rust

export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export CARGO_HOME="$XDG_DATA_HOME/cargo"

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

for version in "stable"; do
	rustup install "$version"
	rustup component add rust-analyzer --toolchain="$version"
done