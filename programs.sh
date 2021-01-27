#!/bin/sh

#Install Google Chrome
sudo apt update -y && sudo apt upgrade -y
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb
sudo rm ./google-chrome-stable_current_amd64.deb
echo ' Google Chrome is installed!'

#Install useful programs
sudo apt install -y vlc gnome-tweak-tool dconf-editor grub-customizer ubuntu-restricted-extras  ubuntu-restricted-addons libreoffice git vim neofetch obs-studio gnome-shell-extensions chrome-gnome-shell font-manager
sudo apt install -y tlp tlp-rdw
sudo snap install telegram-desktop
sudo snap install code --classic
sudo snap install phpstorm --classic
sudo snap install spotify
echo ' Basic programs are installed!'

#Install Microsoft Teams
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/ms-teams stable main" > /etc/apt/sources.list.d/teams.list'
sudo apt update -y
sudo apt install teams -y
echo 'Microsoft Teams is installed!'

#Install Github Desktop
wget -qO - https://packagecloud.io/shiftkey/desktop/gpgkey | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/shiftkey/desktop/any/ any main" > /etc/apt/sources.list.d/packagecloud-shiftky-desktop.list'
sudo apt update -y
sudo apt install -y github-desktop

#Add minimize on click
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'

#Copying Wallpapers and Themes
sudo cp -r /wallpapers /usr/share/backgrounds
sudo cp -r /Yaru-Blue-Dark /usr/share/themes
sudo cp -r /Yaru-Blue /usr/share/icons
sudo cp .Xresources-regolith /home/graziano/.Xresources-regolith
cd tela && sudo ./install.sh -b
echo 'Themes and Backgrounds are installed!'
gsettings set org.gnome.desktop.background picture-uri file:////usr/share/backgrounds/wallpaper2.jpeg
echo 'Background has changed!'

#Fixing CapsLock bug
sudo mkdir home/graziano/capslockfixer-master
sudo cp -r capslockfixer-master/* home/graziano/capslockfixer-master
echo 'Caps Lock fixer has been add to Home directory. Make sure to add it to Startup Application.'

