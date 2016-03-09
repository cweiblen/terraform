resource "aws_security_group" "jenkins" {
  name = "jenkins-sg"
  description = "Jenkins access rules"
  vpc_id = "${var.jenkins_vpc_id}"

  ingress {
      from_port = 8080
      to_port = 8080
      protocol = "tcp"
      security_groups = ["${var.vpn_sg}"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins" {
  ami = "${var.jenkins_ami}"
  instance_type = "${var.jenkins_instance_type}"
  key_name = "${var.jenkins_keyname}"
  vpc_security_group_ids = [
    "${aws_security_group.jenkins.id}",
    "${var.common_sg}"
  ]
  subnet_id = "${var.jenkins_subnet}"
  associate_public_ip_address = false
  iam_instance_profile = "${var.bootstrap_profile}"

  user_data = "${file("${path.module}/bootstrap.sh")}"
  tags {
        Name = "jenkins"
        Environment = "${var.jenkins_env}"
  }
}

resource "aws_route53_record" "jenkins" {
   zone_id = "${var.jenkins_zone_id}"
   name = "jenkins.weiblen.com"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.jenkins.private_ip}"]
}
