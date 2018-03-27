#!/bin/bash
#
# Main executible for setting up private Tor network on AWS
#
# Prerequisites: openssl for keygen
# 				terraform.exe in local directory 
#				AWS Access and Secret Key need to be in terraform.tfvars
#	
#########

# Generate key pair
read -p "Generate new key pair? :" yn
case $yn in
	[Yy]* ) ssh-keygen -f tor-key -b 4092 -t rsa -q -N ""; PUB_KEY=$(cat tor-key.pub);;
	[Nn]* ) echo "No key generated";;
esac

if [ ! -f 'terraform' ]
then
    wget https://releases.hashicorp.com/terraform/0.11.3/terraform_0.11.3_linux_amd64.zip
    # Extract it
    unzip terraform_0.11.3_linux_amd64.zip
    rm terraform_0.11.3_linux_amd64.zip
fi

# Add our key to the main Terraform configuration file
sed -i -e 's|public_key = \"\"|public_key = '\""$PUB_KEY"\"'|' aws.tf

# Add the private ssh key to the authorized keys
echo "$PUB_KEY" >> ~/.ssh/authorized_keys

# Download the terraform aws module
./terraform init

# Plan and prepare to apply
# User must enter "yes" for apply to go through
./terraform apply