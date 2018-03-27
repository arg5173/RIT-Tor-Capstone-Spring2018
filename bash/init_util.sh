#!/bin/bash
#
# Private TOR Network Project
# Utility Server Initialization Script
#
# Prerequisites: None
#
# Dependencies: RIT-Tor-Capstone-Spring2018/bash/deploy.sh
#               RIT-Tor-Capstone-Spring2018/Tor/config/torc.da
#               RIT-Tor-Capstone-Spring2018/bash/update_torrc_DAs.sh
#########

# Update and install necessary programs
sudo apt-get -y update
sudo apt-get install -y openssh-server > /dev/null
sudo apt-get install -y apache2 > /dev/null
sudo apt-get install -y git > /dev/null

# Clone from repository and grab needed files
git clone https://github.com/arg5173/RIT-Tor-Capstone-Spring2018.git
sudo cp RIT-Tor-Capstone-Spring2018/bash/deploy.sh /var/www/html/
sudo cp RIT-Tor-Capstone-Spring2018/tor/config/torrc.da /var/www/html/
sudo cp RIT-Tor-Capstone-Spring2018/bash/update_torrc_DAs.sh /var/www/html/

sudo useradd -m -d /home/tor tor
sudo echo tor:wordpass | sudo chpasswd tor
sudo usermod -aG sudo tor
sudo touch /home/tor/DAs
sudo chown tor /home/tor/DAs
sudo chgrp tor /home/tor/DAs
sudo chmod a+rw /home/tor/DAs