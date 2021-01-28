#!/bin/sh
#Install Regolith
sudo add-apt-repository ppa:regolith-linux/release
sudo apt install regolith-desktop i3xrocks-net-traffic i3xrocks-cpu-usage i3xrocks-time

#Installing i3xrocks items
sudo apt install -y i3xrocks-memory
sudo apt install -y i3xrocks-battery
sudo apt install -y i3xrocks-disk-capacity
sudo apt install -y i3xrocks-net-traffic
sudo apt install -y i3xrocks-volume
sudo apt install -y i3xrocks-wifi
sudo apt install -y regolith-look-ubuntu
#Copying the config files
#sudo -r /etc-regolith/ /etc/
#sudo rm -r /etc/regolith
#sudo mv /etc/etc-regolith/ /etc/regolith

#rsync -a --delete /regolith/ /home/graziano/regolith

sudo regolith-look refresh
