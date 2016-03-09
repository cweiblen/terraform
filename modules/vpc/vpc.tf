# Specify the provider and access details
provider "aws" {
  region = "${var.vpc_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr_block}"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
}
