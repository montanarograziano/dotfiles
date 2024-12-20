# Setup

This is a document that describes how things should be installed to setup a working machine.

## Install script
The `install.sh` script calls the following scripts:

- `macos.sh` -> Actives some OS configurations (tap to click, default screenshots folder, show hidden files etc.)
- `brew.sh` -> Installs **Homebrew** and relevant packages
- `tools.sh` -> Installs **Uv**, **Rust**

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