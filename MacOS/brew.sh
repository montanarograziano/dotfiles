#! usr/bin/env zsh

echo "Checking if Xcode Command Line Tools are installed..."

# Check if Xcode Command Line Tools are installed
if ! xcode-select --print-path &>/dev/null; then
    echo "Installing Xcode Command Line Tools..."

    # Trigger the installation
    xcode-select --install &>/dev/null

    # Wait until the tools are installed
    echo "Waiting for Xcode Command Line Tools installation to complete..."
    until xcode-select --print-path &>/dev/null; do
        sleep 10
    done

    echo "✔︎ Xcode Command Line Tools installed successfully!"

    # Agree to the license agreement
    echo "Agreeing to the Xcode Command Line Tools license..."
    sudo xcodebuild -license accept
else
    echo "✔︎ Xcode Command Line Tools are already installed."
fi

echo "Checking if Homebrew is installed"
if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew is already installed."
fi

read -r -p "Install dependencies from Brewfile? [y/N] " response
if [[ $response =~ ^(y|yes|Y)$ ]]; then
    if [[ -f "$HOME/.config/Brewfile" ]]; then
        echo "Installing dependencies from Brewfile..."
        brew bundle --file="$HOME/.config/Brewfile"
    else
        echo "Brewfile not found at $HOME/.config/Brewfile"
    fi
else
    echo "Skipping Brewfile installation"
fi

# set XDG directories
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"