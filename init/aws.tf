# Terraform script

# Get the keys from the terraform.tfvars file
variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}

# Get the number of instances to create
variable "relay_count" {}
variable "exit_count" {}
variable "client_count" {}
variable "da_count" {}
variable "hidden_count" {}

# Set up the login information
provider "aws" {
    region = "us-east-1"
    access_key = "${var.AWS_ACCESS_KEY}"
    secret_key = "${var.AWS_SECRET_KEY}"
}

# Create the utility server
resource "aws_instance" "utility" {
    ami = "ami-628ad918"  # Debain strech - 64 bit
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.tor-key.key_name}"
    
    tags {
        Name = "Tor Utility Server"
    }

    # Set up the utility server
    provisioner "remote-exec" {
        inline = [
          "sudo apt-get install wget -y",
          "wget https://raw.githubusercontent.com/arg5173/RIT-Tor-Capstone-Spring2018/master/bash/init_util.sh",
          "chmod +x init_util.sh",
          "sudo ./init_util.sh"
        ]
    }

	timeouts {
		create = "60m"
		delete = "30m"
	}
	
    # Connect to the instance to set it up using our private key
    connection {
        type = "ssh"
        user = "admin"
        private_key = "${file("tor-key")}"
    }
}

# Create the relay nodes
resource "aws_instance" "relay" {
    ami = "ami-628ad918"  # Debain strech - 64 bit
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.tor-key.key_name}"
	count = "${var.relay_count}"
    tags {
        Name = "Tor Relay Node"
    }

    # Upload the key
    provisioner "file" {
        source = "tor-key"
        destination = "/home/admin/tor-key"
    }

    # COnfigure the relay node
    provisioner "remote-exec" {
        inline = [
          "sudo apt-get install wget -y",
          "wget https://raw.githubusercontent.com/arg5173/RIT-Tor-Capstone-Spring2018/master/bash/deploy.sh",
          "chmod +x deploy.sh",
          "chmod 400 tor-key",
          "sudo ./deploy.sh RELAY ${aws_instance.utility.public_ip}"
        ]
    }
	
	timeouts {
		create = "60m"
		delete = "30m"
	}

    connection {
        type = "ssh"
        user = "admin"
        private_key = "${file("tor-key")}"
    }
}

# Create the clients
resource "aws_instance" "client" {
    ami = "ami-628ad918"  # Debain strech - 64 bit
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.tor-key.key_name}"
	count = "${var.client_count}"
    tags {
        Name = "Tor Client"
    }

    provisioner "file" {
        source = "tor-key"
        destination = "/home/admin/tor-key"
    }

    provisioner "remote-exec" {
        inline = [
          "sudo apt-get install wget -y",
          "wget https://raw.githubusercontent.com/arg5173/RIT-Tor-Capstone-Spring2018/master/bash/deploy.sh",
          "chmod +x deploy.sh",
          "chmod 400 tor-key",
          "sudo ./deploy.sh CLIENT ${aws_instance.utility.public_ip}"
        ]
    }
	
	timeouts {
		create = "60m"
		delete = "30m"
	}

    connection {
        type = "ssh"
        user = "admin"
        private_key = "${file("tor-key")}"
    }
}

# Create the hidden services
resource "aws_instance" "hiddenservice" {
    ami = "ami-628ad918"  # Debain strech - 64 bit
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.tor-key.key_name}"
    count = "${var.hidden_count}"
    tags {
        Name = "Hidden Service"
    }

    provisioner "file" {
        source = "tor-key"
        destination = "/home/admin/tor-key"
    }

    provisioner "remote-exec" {
        inline = [
          "sudo apt-get install wget -y",
          "wget https://raw.githubusercontent.com/arg5173/RIT-Tor-Capstone-Spring2018/master/bash/deploy.sh",
          "chmod +x deploy.sh",
          "chmod 400 tor-key",
          "sudo ./deploy.sh HS ${aws_instance.utility.public_ip}"
        ]
    }
	
	timeouts {
		create = "60m"
		delete = "30m"
	}

    connection {
        type = "ssh"
        user = "admin"
        private_key = "${file("tor-key")}"
    }
}

# Create the exit nodes
resource "aws_instance" "exit" {
    ami = "ami-628ad918"  # Debain strech - 64 bit
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.tor-key.key_name}"
    count = "${var.exit_count}"
    tags {
        Name = "Tor Exit Node"
    }

    provisioner "file" {
        source = "tor-key"
        destination = "/home/admin/tor-key"
    }

    provisioner "remote-exec" {
        inline = [
          "sudo apt-get install wget -y",
          "wget https://raw.githubusercontent.com/arg5173/RIT-Tor-Capstone-Spring2018/master/bash/deploy.sh",
          "chmod +x deploy.sh",
          "chmod 400 tor-key",
          "sudo ./deploy.sh EXIT ${aws_instance.utility.public_ip}"
        ]
    }
	
	timeouts {
		create = "60m"
		delete = "30m"
	}

    connection {
        type = "ssh"
        user = "admin"
        private_key = "${file("tor-key")}"
    }
}

resource "aws_instance" "da" {
    ami = "ami-628ad918"  # Debain strech - 64 bit
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.tor-key.key_name}"
    count = "${var.da_count}"
    tags {
        Name = "Tor Directory Authority"
    }

    provisioner "file" {
        source = "tor-key"
        destination = "/home/admin/tor-key"
    }

    provisioner "remote-exec" {
        inline = [
          "sudo apt-get install wget -y",
          "wget https://raw.githubusercontent.com/arg5173/RIT-Tor-Capstone-Spring2018/master/bash/deploy.sh",
          "chmod +x deploy.sh",
          "chmod 400 tor-key",
          "sudo ./deploy.sh DA ${aws_instance.utility.public_ip}"
        ]
    }
	
	timeouts {
		create = "60m"
		delete = "30m"
	}

    connection {
        type = "ssh"
        user = "admin"
        private_key = "${file("tor-key")}"
    }
}

resource "aws_key_pair" "tor-key" {
    key_name = "tor-key"
    public_key = ""
}
