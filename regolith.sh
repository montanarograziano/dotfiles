#!/bin/sh
#Install Regolith
sudo add-apt-repository ppa:regolith-linux/release
sudo apt install regolith-desktop i3xrocks-net-traffic i3xrocks-cpu-usage i3xrocks-time
sudo apt install regolith-look-ubuntu

#Installing i3xrocks items
sudo apt install i3xrocks-memory
sudo apt install i3xrocks-battery
sudo apt install i3xrocks-cpu-usage
sudo apt install i3xrocks-disk-capacity
sudo apt install i3xrocks-net-traffic
sudo apt install i3xrocks-time
sudo apt install i3xrocks-volume
sudo apt install i3xrocks-wifi

#Copying the config files
sudo -r /etc-regolith/ /etc/
sudo rm -r /etc/regolith
sudo mv /etc/etc-regolith/ /etc/regolith

rsync -a --delete /regolith/ /home/graziano/regolith

sudo regolith-look refresh
