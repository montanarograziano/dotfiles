#! /bin/zsh

echo "Checking xcode tools are installed..."

if ! xcode-select --print-path &>/dev/null; then

	print "Installing xcode command line tools..."
	xcode-select --install &>/dev/null

	# Wait until the XCode Command Line Tools are installed
	until xcode-select --print-path &>/dev/null; do
		sleep 10
	done

	print "Xcode command line tools installed!"

	print "Agree with the xcode command line tools licence:"
	sudo xcodebuild -license
fi

echo "Checking if homebrew is installed"
local brew_bin
brew_bin=$(which brew) 2>&1 >/dev/null

if [[ $? != 0 ]]; then
	/bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
fi

brew install docker git-delta wget gh nvim ripgrep libpq pipx just zsh-syntax-highlighting zsh-autosuggestions
brew tap homebrew/cask-fonts
brew install --cask font-fira-code-nerd-font
brew install --cask font-meslo-lg-nerd-font
brew install --cask font-iosevka
brew install --cask whatsapp
brew install --cask monitorcontrol
brew install --cask ngrok
brew install --cask maccy
brew install --cask visual-studio-code
brew install --cask keka
brew install --cask rectangle
brew install --cask jetbrains-toolbox
brew install --cask discord
brew install --cask spotify

brew cleanup

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
    "asitop"
    "commitizen"
    "cookiecutter"
    "huggingface-hub[cli]"
    "jupytext"
    "mypy"
    "posting"
    "pytest"
    "ruff"
)

for lib in "${libs[@]}"; do
	uv tool install --upgrade --python="$safe_version" -- "$lib"
done

uv tool install --upgrade --python="$safe_version" --with pre-commit-uv -- pre-commit
