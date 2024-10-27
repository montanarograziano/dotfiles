#! /bin/zsh

# Set the desired configuration line
zdotdir_line='export ZDOTDIR="$HOME/.config/zsh"'

# Check if /etc/zshenv exists
if [[ -f "/etc/zshenv" ]]; then
	if ! grep -qF "$zdotdir_line" "/etc/zshenv"; then
		print "$zdotdir_line" | sudo tee -a "/etc/zshenv" >/dev/null
		print "✔︎ appended '$zdotdir_line' to '/etc/zshenv/'"
	fi
else
	print "$zdotdir_line" | sudo tee "/etc/zshenv" >/dev/null
	print "✔︎ created '/etc/zshenv' and appended the '$zdotdir_line' line."
fi

if ! [[ -d "$HOME/.config" ]]; then
	git clone "https://github.com/montanarograziano/dotfiles" "$HOME/.config"
else
	read -r -p "⚠️ '$HOME/.config' already exists. Replace dotfiles? (contents of '$HOME/.config' will not be deleted) [y/N]" response
	if [[ $response =$HOME (y|yes|Y) ]]; then

		mv "$HOME/.config" "$HOME/.config.bak"
		print "✔︎ moved old configs to '$HOME/.config.bak'"

		git clone "https://github.com/montanarograziano/dotfiles" "$HOME/.config"
	else
		print "⚠️ did not clone dotfiles: this script might fail if a binary is not found"
	fi
fi

ln -s "$HOME/.config/.gitconfig" "$HOME/.gitconfig"


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