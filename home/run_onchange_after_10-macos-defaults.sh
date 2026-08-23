#!/bin/bash
# run_onchange_after: apply macOS user defaults. Re-runs automatically
# whenever this script's content changes (chezmoi hashes the script).
#
# Corrected vs the legacy scripts/settings.sh:
# - No sudo: every write below targets the CURRENT USER's defaults domain
#   (NSGlobalDomain / com.apple.*), so none of it needs root.
# - Dark mode uses the correct per-user key (AppleInterfaceStyle in
#   NSGlobalDomain) instead of writing to the system-wide
#   /Library/Preferences/.GlobalPreferences, which needed sudo for no reason.
# - killall calls are best-effort (`|| true`) so a process that isn't
#   currently running never fails the whole script.
set -euo pipefail

echo "Setting macOS defaults..."

# Disable smart quotes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable autocorrect
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Finder: show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: use column view by default
# View codes: icnv = icon, Nlsv = list, clmv = column, Flwv = gallery
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Finder: display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Save screenshots to the desktop
defaults write com.apple.screencapture location -string "${HOME}/Desktop"

# Dark theme, per-user (no sudo needed for this key)
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# Enable tap-to-click. Two SEPARATE domains, both required:
#   com.apple.AppleMultitouchTrackpad ................ built-in (MacBook) trackpad
#   com.apple.driver.AppleBluetoothMultitouch.trackpad  external Magic Trackpad
# Only the Bluetooth one was set here originally, so tap-to-click silently
# never worked on a laptop's own trackpad (verified: the built-in domain read
# Clicking = 0 on a machine where this script had already run). The
# NSGlobalDomain tapBehavior writes make the setting stick across logins;
# -currentHost and plain are both needed, they are different scopes.
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Dock: show instantly on hover.
#   autohide-delay         = pause before the Dock slides in (0 = no pause)
#   autohide-time-modifier = slide animation speed (0.15 = fast, 0 = instant)
# Revert with:
#   defaults delete com.apple.dock autohide-delay
#   defaults delete com.apple.dock autohide-time-modifier
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.15

# Restart the user-space processes that read these defaults so changes take
# effect immediately. None of these need sudo: they only affect the current
# user's session, and a process that isn't running is not an error.
killall Finder &>/dev/null || true
killall Dock &>/dev/null || true
killall cfprefsd &>/dev/null || true

echo "✔︎ macOS defaults applied."
