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

#TODO -- Install Microsoft Teams
# wget "link"
#sudo apt install -y -/teams_1.3.00.30857_amd64.deb

