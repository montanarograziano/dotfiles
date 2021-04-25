#!/bin/sh

#Install Google Chrome
sudo apt update -y && sudo apt upgrade -y
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb
sudo rm ./google-chrome-stable_current_amd64.deb
echo ' Google Chrome is installed!'

#Install useful programs
sudo apt install -y vlc gnome-tweak-tool dconf-editor grub-customizer ubuntu-restricted-extras  ubuntu-restricted-addons libreoffice git vim neofetch obs-studio gnome-shell-extensions chrome-gnome-shell font-manager pavucontrol htop gimp
sudo apt install -y tlp tlp-rdw
sudo add-apt-repository ppa:sicklylife/filezilla
sudo apt update &&  sudo apt install filezilla
echo ' Basic programs are installed!'

#Install Github Desktop
wget -qO - https://packagecloud.io/shiftkey/desktop/gpgkey | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/shiftkey/desktop/any/ any main" > /etc/apt/sources.list.d/packagecloud-shiftky-desktop.list'
sudo apt update -y
sudo apt install -y github-desktop


