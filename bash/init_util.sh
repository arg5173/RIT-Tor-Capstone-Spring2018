#!/bin/bash
sudo apt-get -y update
sudo apt-get install -y openssh-server > /dev/null
sudo apt-get install -y apache2 > /dev/null
sudo apt-get install -y git > /dev/null
#git clone https://github.com/98Giraffe/RIT_Capstone_2016.git
git clone https://github.com/arg5173/RIT-Tor-Capstone-Spring2018.git
#sudo cp RIT_Capstone_2016/tor/deploy.sh /var/www/html/
#sudo cp RIT_Capstone_2016/tor/config/torrc.da /var/www/html/
#sudo cp RIT_Capstone_2016/tor/update_torrc_DAs.sh /var/www/html/
sudo cp RIT-Tor-Capstone-Spring2018/bash/deploy.sh /var/www/html/
sudo cp RIT-Tor-Capstone-Spring2018/Tor/config/torrc.da /var/www/html/
sudo cp RIT-Tor-Capstone-Spring2018/bash/update_torrc_DAs.sh /var/www/html/
sudo useradd -m -d /home/tor tor
sudo echo tor:wordpass | sudo chpasswd tor
sudo usermod -aG sudo tor
sudo touch /home/tor/DAs
sudo chown tor /home/tor/DAs
sudo chgrp tor /home/tor/DAs
sudo chmod a+rw /home/tor/DAs