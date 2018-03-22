# Terraform Script
# Deploy Utility Server

# Set up the login information
provider "aws" {
	region = "us-east-1"
	access_key = "${var.access_key}"
	secret_key = "${var.secret_key}"
}

# Set up our util instance
resource "aws_instance" "util" {
	ami                     = "ami-628ad918"  # debian-stretch-hvm-x86_64-gp2-2018-02-22-67467
    instance_type           = "t2.micro"
	key_name				= "${aws_key_pair.TOR-key.key_name}"
	tags {
		Name = "Utility Server"
	}
	user_data = "${file("../bash/init_util.sh")}"
}

resource "aws_key_pair" "TOR-key" {
    key_name = "TOR-key"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAihRRNPYSoLlfYqcy3XhmNVW0aXhVBSJn9hoHTOnTbeOI5+7zlwSP5u0k4XCaJUw1S/h0+kf3uVbj7YC3i0mXLcpFA04nf3ZQu5zgvSJb3C4SB/SXWIl5444+3n5nrI/3xkeHjNPtUdEupqpltarHtl/Dv1HdBStLGzNAsqFbgTXlTWDW+I2A5V3rXfHZZeQbKhvQ2i3qFoswBd7oHyQsu2npTCopxOk9ztzUKiCJtiGh+1SCoYe6buEchBIrOx07dGRnP+bCrNZJv8dyp9rA7GFBwogga/nIJKxQcqPRTaJK+MhuR2amTpY+FERkotkDVjPCtp8+zaw8SkXruopIjQ== rsa-key-20180320"
}
