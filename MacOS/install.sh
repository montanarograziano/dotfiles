#! /bin/zsh

# -e exit on error
# -u error on undefined variables
# -o option
# pipefail exits on command pipe failures
set -euo pipefail

echo "running macos defaults..."
# macos
./macos.sh

echo "installing with brew"
./brew.sh

# alias
ln -sfn "$PWD/.alias" "$HOME/.alias"

# zsh
ln -sfn "$PWD/.zshrc" "$HOME/.zshrc"

echo "Finished :)"
