#!/bin/sh
sudo apt update -y && sudo apt upgrade -y
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb
sudo rm ./google-chrome-stable_current_amd64.deb

sudo apt install -y vlc gnome-tweak-tool dconf-editor grub-customizer ubuntu-restricted-extras  ubuntu-restricted-addons libreoffice git vim neofetch obs-studio  
sudo apt install -y tlp tlp-rdw
sudo snap install telegram-desktop
sudo snap install code --classic
sudo snap install phpstorm --classic
sudo snap install spotify

curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/ms-teams stable main" > /etc/apt/sources.list.d/teams.list'
sudo apt update -y
sudo apt install teams -y

