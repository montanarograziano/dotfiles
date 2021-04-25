#!/bin/sh

#Install Google Chrome
sudo apt update -y && sudo apt upgrade -y
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb
sudo rm ./google-chrome-stable_current_amd64.deb
echo ' Google Chrome is installed!'

#Install useful programs
sudo apt install -y vlc gnome-tweak-tool dconf-editor ubuntu-restricted-extras  ubuntu-restricted-addons libreoffice git vim neofetch obs-studio gnome-shell-extensions chrome-gnome-shell font-manager pavucontrol htop gimp
sudo apt install -y tlp tlp-rdw
wget https://packages.microsoft.com/repos/ms-teams/pool/main/t/teams/teams_1.3.00.16851_amd64.deb
sudo dpkg -i teams_1.3.00.16851_amd64.deb
sudo apt update -y && sudo apt upgrade -y
echo ' Basic programs are installed!'


#Copying Wallpapers and Themes
sudo cp -r ./wallpapers/* /usr/share/backgrounds/pop
echo "Background copied."

