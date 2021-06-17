#!/bin/bash

#Add minimize on click
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'

#Copying Wallpapers and Themes
sudo cp -r ./wallpapers/* /usr/share/backgrounds
cd tela && sudo ./install.sh -b
echo 'Themes and Backgrounds are installed!'
echo 'Background has changed!'
