# IAM role and instance profile for tomcat instance to access SQS and DynamoDB
resource "aws_iam_role" "bootstrap_role" {
    name = "bootstrap_role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "bootstrap_profile" {
    name = "bootstrap_profile"
    roles = ["${aws_iam_role.bootstrap_role.name}"]
}

resource "template_file" "policy_doc" {
  template = "${file("${path.module}/bootstrap_policy.tpl")}"
  vars {
    bucket = "${var.common_bootstrap_bucket}"
  }
}

resource "aws_iam_policy" "bootstrap_policy" {
    name = "bootstrap_policy"
    description = "policy for s3 access during server startup"
    policy = "${template_file.policy_doc.rendered}"
}

resource "aws_iam_policy_attachment" "bootstrap" {
  name = "boostrap-attachment"
  roles = ["${aws_iam_role.bootstrap_role.name}"]
  policy_arn = "${aws_iam_policy.bootstrap_policy.arn}"
}

resource "aws_security_group" "common" {
  name = "common-sg"
  description = "Common access rules"
  vpc_id = "${var.common_vpc_id}"

  ingress {
      from_port = 22
      to_port = 22
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