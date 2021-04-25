#!/bin/bash

#Add minimize on click
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'

#Copying Wallpapers and Themes
sudo cp -r ./wallpapers/* /usr/share/backgrounds
sudo cp -r ./Yaru-Blue-dark/* /usr/share/themes
sudo cp -r ./Yaru-Blue/* /usr/share/icons
sudo cp .Xresources-regolith ~/.Xresources-regolith
gsettings set org.gnome.desktop.background picture-uri file:////usr/share/backgrounds/wallpaper2.jpeg
cd tela && sudo ./install.sh -b
echo 'Themes and Backgrounds are installed!' 
echo 'Background has changed!'
#Fixing CapsLock bug
sudo mkdir ~/capslockfixer-master
sudo cp -r ./capslockfixer-master/* ~/capslockfixer-master
sudo sh ~/capslockfixer-master/fixer.sh
echo 'Caps Lock fixer has been add to Home directory. Make sure to add it to Startup Application.'