#!/bin/bash
# Prerequs: must have aws.tf, must have access and secret key in
#           terraform.tfvars
# TODO: Change instances of 'helloworld-key' to 'tor-key'

# Install openssl, ansible, and wget
apt-get install openssl ansible wget -y

# Grab terraform from their website
wget https://releases.hashicorp.com/terraform/0.11.3/terraform_0.11.3_linux_amd64.zip

# Extract it
unzip terraform_0.11.3_linux_amd64.zip
rm terraform_0.11.3_linux_amd64.zip

# Generate key pair
ssh-keygen -f tor-key -b 4092 -t rsa -q -N ""

# Add it to the terraform configuration file
sed -i -e 's/public_key = ""/public_key = "'$(cat tor-key)'"/g' aws.tf

# Download the terraform aws module
./terraform init
./terraform apply -auto-approve
