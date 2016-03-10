resource "aws_security_group" "vpn" {
  name = "vpn-sg"
  description = "OpenVPN access rules"
  vpc_id = "${var.vpn_vpc_id}"
  
  ingress {
      from_port = 1194
      to_port = 1194
      protocol = "udp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
      from_port = 943
      to_port = 943
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "vpn" {
  ami = "${var.vpn_ami}"
  instance_type = "${var.vpn_instance_type}"
  key_name = "${var.vpn_keyname}"
  vpc_security_group_ids = ["${aws_security_group.vpn.id}"]
  subnet_id = "${var.vpn_subnet}"
  associate_public_ip_address = true
  source_dest_check = false
  tags {
        Name = "VPN"
        Environment = "${var.vpn_env}"
  }
}

resource "aws_eip" "vpn" {
    instance = "${aws_instance.vpn.id}"
    vpc = true
}

resource "aws_route53_record" "vpn" {
   zone_id = "${var.vpn_zone_id}"
   name = "vpn.weiblen.com"
   type = "A"
   ttl = "300"
   records = ["${aws_eip.vpn.public_ip}"]
}
