#!/bin/bash
# Prerequs: must have aws.tf, must have access and secret key in
#           terraform.tfvars

# Install openssl and wget
apt-get install -y openssl wget

# Grab terraform from their website
if [ ! -f 'terraform' ]
then
    wget https://releases.hashicorp.com/terraform/0.11.3/terraform_0.11.3_linux_amd64.zip
    # Extract it
    unzip terraform_0.11.3_linux_amd64.zip
    rm terraform_0.11.3_linux_amd64.zip

fi

# Generate key pair
ssh-keygen -f tor-key -b 4092 -t rsa -q -N ""
PUB_KEY=$(cat tor-key.pub)

# Add it to the terraform configuration file
sed -i -e 's|public_key = \"\"|public_key = '\""$PUB_KEY"\"'|' aws.tf

# Add the private ssh key to the authorized keys
echo "$PUB_KEY" >> ~/.ssh/authorized_keys

# Download the terraform aws module
./terraform init
./terraform apply -auto-approve
