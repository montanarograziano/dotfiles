# What is it?
A repository containing dotfiles for my machines.

Note that it's based on MacOS and therefore it would not work on other OS.

## How to use the dotfiles

The `bootstrap.sh` scripts inside `scripts` folder is the source of everything: it installs Homebrew and git, and clone this repository so that other tools can be installed. To use this script, you either donwload and run manually or run the following commands:

```sh
curl -O https://raw.githubusercontent.com/montanarograziano/dotfiles/main/scripts/bootstrap.sh
chmod +x bootstrap.sh
sudo ./bootstrap.sh # Required to install some brew packages
```

The script will attempt at:
- Install XCode Command Line Tools
- Install Homebrew
- Install git through Homebrew
- Clone this repository, eventually move in `.config.bak/` an existing one before overwriting it
- Run `install.sh` script


The `install.sh` script calls the following scripts:
- `settings.sh` -> Actives some OS configurations (tap to click, default screenshots folder, show hidden files etc.)
- `brew.sh` -> Install relevant packages, all listed in `Brewfile`
- `tools.sh` -> Installs **Uv**, python versions from **3.9** to **3.12** and some tools like **mypy**, **pytest**, **pre-commit**, and also installs **Rust**.

Setup SSH keys for GitHub:

```sh
# Generate a new SSH key
ssh-keygen -f ~/.ssh/github -t ed25519 -C "<email>"

# Start the ssh-agent in the background
eval "$(ssh-agent -s)"

# Add your SSH private key to the ssh-agent
ssh-add --apple-use-keychain ~/.ssh/github

# Copy the SSH public key to the clipboard
pbcopy < ~/.ssh/github.pub

# Add the SSH public key to your GitHub account
open "https://github.com/settings/ssh"

# Verify that the SSH key is added successfully
ssh -T git@github.com
```
