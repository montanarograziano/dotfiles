#! /bin/zsh

echo "Checking XCode tools are installed..."

if ! xcode-select --print-path &>/dev/null; then

	print "Installing XCode command line tools..."
	xcode-select --install &>/dev/null

	# Wait until the XCode Command Line Tools are installed
	until xcode-select --print-path &>/dev/null; do
		sleep 10
	done

	print "XCode command line tools installed!"

	print "Agree with the xcode command line tools licence:"
	sudo xcodebuild -license
fi

echo "Checking if Homebrew is installed"
local brew_bin
brew_bin=$(which brew) 2>&1 >/dev/null

if [[ $? != 0 ]]; then
	/bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
fi

read -r -p "Install dependencies from Brewfile? [y/N]" response
if [[ $response =$HOME (y|yes|Y) ]]; then

	brew bundle --file="$HOME/.config/Brewfile"
else
	print "Skipping Brewfile installation"
fi

# set XDG directories
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"