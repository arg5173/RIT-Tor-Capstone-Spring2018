# Terraform Script
# Deploy DAs

resource "aws_instance" "da1" {
	ami                     = "ami-628ad918"  # debian-stretch-hvm-x86_64-gp2-2018-02-22-67467
    instance_type           = "t2.micro"
	key_name				= "${aws_key_pair.TOR-key.key_name}"
	tags {
		Name = "DA1"
	}
	#user_data = "${file("../bash/init_da.sh")}"
}