#!/bin/bash

# Welcome! This script is used to deploy all of the roles tor can assume on an ubuntu machine, it supports:
# DA - Directory Authority
# RELAY - Relay node
# EXIT - Exit node
# CLIENT - A Client in the private network
# HS - A hidden service
#
# The script requires that a Utility server has been deployed using the launch_util.sh script
# It takes two arguments the first is the above role you would like to deploy and the second is the ip address of the utility server
# Example: bash deploy.sh DA 172.16.106.155 (Will deploy a directory authority with a utility ip of 172.16.106.155
# Example: bash deploy.sh RELAY 172.16.106.155 (Will deploy a relay node with a utility ip of 172.16.106.155)

# When run this script will install all of the necessary dependencies for tor including the binary itself and will scp the global DAs file from the utility server
# to obtain the current list of Directory Authorities within the network. If you are deploying a directory authority the script will automatically generate its DA line
# and store it in the global DAs file on the Util server.

# There are different sections to this script depending on what role you deploy, there are global configuration options that need to be included in the torrc file



# Incase you are running this on a machine that has already been deployed it will remove any files that could cause problems
# from previous deployments

# Delete existing tor on box
echo > /etc/tor/torrc		# echo > onto any file will empty it out effectivly clearing torrc
rm -r /var/lib/tor/keys		# Remove the keys directory incase it was a DA	


# Define Variables
ROLE=$1				# Role will either be DA, RELAY, CLIENT, EXIT, or HS passed in from the command line
UTIL_SERVER=$2			# The IP address of the Utility server passed in from the command line
TOR_DIR="/var/lib/tor"		# Defining the Tor directory
TOR_ORPORT=7000			# Defining the Tor OrPort  (port number is arbitrary)
TOR_DIRPORT=9898		# Defining the Tor DirPort (port number is arbitrary)


echo -e "\n========================================================"

	
##############################
# Install Build Dependencies #
##############################

#** Note the -y flag will auto install and not prompt if you are sure

echo "[!] Updating package manager"	
apt-get update > /dev/null		#Update the package manager to ensure up-to-date installiations
	
echo "[!] Installing tor"		
apt-get install -y tor	#Install Tor... I wonder why lol
service tor stop

echo "[!] Installing pwgen to generate hostnames"	
apt-get install -y pwgen > /dev/null	# We use a program called pwgen to randomly create names for the relays, this program will spit out a random string of chrs

echo "[!] Installing sshpass to auto login with sand ssh"
apt-get install -y sshpass > /dev/null	# sshpass is used to automatically scp into the util box without having to manually pass the password to the session
					# this is used so we dont have to manually type in the password to the util server



# In order to keep the torrc DA lines up to date we need to download the update_torrc_DAs.sh script which will automatically scp the DAs file from the Util box and add any
# New DA lines to its torrc. This file is being hosted on the UTIL servers web server so all we need to do is wget it from the UTIL box and we just store it in the tor directory

wget ${UTIL_SERVER}/torrc.da -P ${TOR_DIR}/
wget ${UTIL_SERVER}/update_torrc_DAs.sh -P ${TOR_DIR}/
chmod a+x ${TOR_DIR}/update_torrc_DAs.sh

# The intention is for the network to update automatically when new DAs are added therefore we create a cron job to run the update_torrc_DAs.sh file once a minute


echo "[!] Creating cron job to update DA entries regurarly"
# Adding update_torrc to cron job
(crontab -l 2>/dev/null; echo "* * * * * ${TOR_DIR}/update_torrc_DAs.sh ${UTIL_SERVER}") | crontab -






#################################
# Generate torrc common configs #
#################################

# This configs added to torrc in this section are global to all tor roles



# Generate Nickname
RPW=$(pwgen -0A 5)			#Here we generate a 5 character random string for the nodes name
					#Node names are in the following format [ROLE][pwgen string]
					# ex. DAmaoud (for a DA)
					# ex. RELAYumbad (for a RELAY)
					# ex. CLIENTqrage (for a CLIENT)

# Export TOR_NICKNAME environment variable
TOR_NICKNAME=${ROLE}${RPW}		# Setting the nickname equal to a variable
echo "[!] Setting random Nickname: ${TOR_NICKNAME}"	

# Add nickname to torrc
echo -e "\nNickname ${TOR_NICKNAME}" >> /etc/tor/torrc	#Adding the nickname line to the torrc with the previously generated nickname
	
# Add data directory to torrc
echo -e "DataDirectory ${TOR_DIR}" >> /etc/tor/torrc    # Adding DataDirectory line to torrc

# This line gets the IP address of the computer
# Consider get ip using ip command consider editing to use ifconfig if ip addr is not aviable Or other tool (kernel files?)
TOR_IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/')
	
# Add IP to torrc
echo "[!] Setting IP to ${TOR_IP}"
echo "Address ${TOR_IP}" >> /etc/tor/torrc	#Adding the Address line to the torrc file

# Add Control Port to torrc
echo -e "ControlPort 9051" >> /etc/tor/torrc	#Adding the control port line to the torrc file

# Add ContactInfo to torrc
echo -e "ContactInfo kar@bar.gov" >> /etc/tor/torrc	#Adding the contact info line to torrc

# Add TestingTorNetwork to torrc
echo -e "TestingTorNetwork 1" >> /etc/tor/torrc		#Adding the TestingTorNetwork line to torrc, see the TOR manual for mor information however this line will make the consensus process and the network creation faster

#Below we setup the logging, all logs will go in /var/lib/tor/ and we are logging both notice and info
#To view these when tor is running simply type 'tail -f /var/lib/tor/notice.log' for a live view into the file
echo -e "Log notice file /var/lib/tor/notice.log" >> /etc/tor/torrc
echo -e "Log info file /var/lib/tor/info.log" >> /etc/tor/torrc
echo -e "ProtocolWarnings 1" >> /etc/tor/torrc
echo -e "SafeLogging 0" >> /etc/tor/torrc   				# SafeLogging shows full ip address and info in logs


##############################
# DA Specific Configurations #
##############################
#These commands and configurations are specific to Directory authorirites
#DAs need to create keys and their DA config lines that go in the torrc and also need to upload these lines to the central DAs file on the Utility server



if [ $ROLE == "DA" ]; then

	echo "[!] Setting Role to DA"
	

	echo "AssumeReachable 1" >> /etc/tor/torrc			#Adding AssumeReachable1 to torrc
	echo "AuthoritativeDirectory 1" >> /etc/tor/torrc		#Adding AuthoritativeDirectory1 and V3 to torrc
	echo "V3AuthoritativeDirectory 1" >> /etc/tor/torrc
	# Append DA template config file to the end of current torrc
	#echo "[!] appending DA config to torrc"
	#cat ${TOR_DIR}/torrc.da >> /etc/tor/torrc
	
	# Adding OrPort to torrc
	echo "[!] Opening OrPort ${TOR_ORPORT}"
	echo -e "OrPort ${TOR_ORPORT}" >> /etc/tor/torrc

	# Adding Dirport to torrc
	echo -e "Dirport ${TOR_DIRPORT}" >> /etc/tor/torrc

	# Adding ExitPolicy to torrc
	# check what exit policy shoudl be on dir authority
	echo -e "ExitPolicy accept *:*" >> /etc/tor/torrc

	# Adding V3AuthVotingInterval for lower consensus time from 5 minuets to two
	echo -e "V3AuthVotingInterval 5 minutes" >> /etc/tor/torrc
	
	# Generate Tor path for keys to be stored
	KEYPATH=${TOR_DIR}/keys
	echo "[!] Making Key Path ${KEYPATH}"

	# Make the directory for keys
	mkdir -p ${KEYPATH}

	# Generate Tor Certificates
	echo "[!] Generating Tor Certificates"
	chown root -R /var/lib/tor
	echo "password" | tor-gencert --create-identity-key -m 12 -a ${TOR_IP}:${TOR_DIRPORT} \
	-i ${KEYPATH}/authority_identity_key \
	-s ${KEYPATH}/authority_signing_key \
	-c ${KEYPATH}/authority_certificate \
        --passphrase-fd 0

	# Generate router fingerprint
	echo "[!] Generating Router Fingerprint"
	tor --list-fingerprint --orport 1 \
    	--dirserver "x 127.0.0.1:1 ffffffffffffffffffffffffffffffffffffffff" \
    	--datadirectory ${TOR_DIR}

	# Generate DirAuthority torrc line
	echo "[!] Generating DirAuthority Line"
	AUTH=$(grep fingerprint ${TOR_DIR}/keys/authority_certificate | awk -F " " '{print $2}')
	FING=$(cat $TOR_DIR/fingerprint | awk -F " " '{print $2}')
	SERVICE=$(grep "dir-address" $TOR_DIR/keys/* | awk -F " " '{print $2}')
	
	#echo AUTH ${AUTH}
	#echo FING ${FING}
	#echo SERVICE ${SERVICE}
	#echo IP ${TOR_IP}
	
	TORRC="DirAuthority $TOR_NICKNAME orport=${TOR_ORPORT} no-v2 v3ident=$AUTH $SERVICE $FING"
	
	echo [!] TORRC $TORRC
	echo $TORRC >> /etc/tor/torrc
	echo "[!] Uploading DirAuthoirty torrc config to util server"
	echo $TORRC >> tmp
	scp -i "/home/admin/tor-key" -o StrictHostKeyChecking=no tmp admin@${UTIL_SERVER}:/home/admin/tmp
	rm tmp
	ssh -i "/home/admin/tor-key" -o StrictHostKeyChecking=no tmp admin@${UTIL_SERVER} "cat /home/admin/tmp >> /home/tor/DAs && rm /home/admin/tmp"
	# echo $TORRC | sshpass -p "wordpass" ssh -oStrictHostKeyChecking=no tor@$UTIL_SERVER "cat >> ~/DAs"
	
	chown debian-tor -R /var/lib/tor
	
fi


#################################
# Relay Specific Configurations #
#################################

if [ $ROLE == "RELAY" ]; then

	echo "[!] Setting role to RELAY"
	
	# Set OrPort in torrc
	echo -e "OrPort ${TOR_ORPORT}" >> /etc/tor/torrc
	
	# Set Dirport in torrc
	echo -e "Dirport ${TOR_DIRPORT}" >> /etc/tor/torrc
	
	# Set ExitPolicy in torrc
	echo -e "ExitPolicy accept private:*" >> /etc/tor/torrc

fi

################################
# Exit Specific Configurations               #
################################

if [ $ROLE == "EXIT" ]; then
	
	echo "[!] Setting role to Exit"

	# Set OrPort in torrc
	echo -e "OrPort ${TOR_ORPORT}" >> /etc/tor/torrc
	
	# Set DirPort in torrc
	echo -e "Dirport ${TOR_DIRPORT}" >> /etc/tor/torrc
	
	# Set ExitPolicy in torrc
	echo -e "ExitPolicy accept *:*" >> /etc/tor/torrc
fi

##################################
# Client Specific Configurations #
##################################

if [ $ROLE == "CLIENT" ]; then

	echo "[!] Setting role to Client"
	
	# Set SOCKSPort in torrc
	echo -e "SOCKSPort 9050" >> /etc/tor/torrc

fi


################################
# Host Specific Configurations #
################################

if [ $ROLE == "HS" ]; then

	echo "[!] Setting role to Hidden Service"
	sudo apt-get install -y apache2 
	# Adding HiddenServiceDir to torrc will be located at /var/lib/tor/hs
	echo -e "HiddenServiceDir ${TOR_DIR}/hs" >> /etc/tor/torrc
	TOR_HS_PORT=80
	TOR_HS_ADDR=127.0.0.1
	echo -e "HiddenServicePort ${TOR_HS_PORT} ${TOR_HS_ADDR}:${TOR_HS_PORT}" >> /etc/tor/torrc
	
fi


echo "[!] Updating DAs list once before cron kicks in"
# Update DAs in torrc
${TOR_DIR}/update_torrc_DAs.sh ${UTIL_SERVER}

# Add update_torrc_DAs.sh as a cron job running every minute
#*/1 * * * * /tor/update_torrc_DAs.sh

echo -e "\n========================================================"
# display Tor version & torrc in log
tor --version
cat /etc/tor/torrc
echo -e "========================================================\n"


#tor --RunAsDaemon 1
sudo service tor restart
