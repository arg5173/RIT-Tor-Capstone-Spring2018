# Terraform script

variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}

# Set up the login information
provider "aws" {
    region = "us-east-1"
    access_key = "${var.AWS_ACCESS_KEY}"
    secret_key = "${var.AWS_SECRET_KEY}"
}

# Set up the kind of EC2 instance we want
resource "aws_instance" "utility" {
    ami = "ami-628ad918"  # Debain strech - 64 bit
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.tor-key.key_name}"
    
    tags {
        Name = "Tor Utility Server"
    }

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
	
    connection {
        type = "ssh"
        user = "admin"
        private_key = "${file("tor-key")}"
    }
}

resource "aws_instance" "relay" {
    ami = "ami-628ad918"  # Debain strech - 64 bit
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.tor-key.key_name}"
    
    tags {
        Name = "Tor Relay Node"
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

resource "aws_instance" "client" {
    ami = "ami-628ad918"  # Debain strech - 64 bit
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.tor-key.key_name}"
    
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

resource "aws_instance" "hiddenservice" {
    ami = "ami-628ad918"  # Debain strech - 64 bit
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.tor-key.key_name}"
    
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

resource "aws_instance" "exit" {
    ami = "ami-628ad918"  # Debain strech - 64 bit
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.tor-key.key_name}"
    
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