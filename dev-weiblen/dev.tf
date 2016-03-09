provider "aws" { region = "${var.aws_region}" }

module "vpc" {
  source = "../modules/vpc"
  vpc_env = "${var.env}"
  vpc_region = "${var.aws_region}"
  vpc_cidr_block = "${var.cidr_block}"
}

module "az" {
  source = "../modules/az-ec2-nat"
  az_env = "${var.env}"
  az = "${var.az1}"
  az_vpc_id = "${module.vpc.vpc_id}"
  az_igw_id = "${module.vpc.igw_id}"
  az_cidr_block_public = "${cidrsubnet(module.vpc.cidr_block,8,0)}"
  az_cidr_block_web    = "${cidrsubnet(module.vpc.cidr_block,8,8)}"
  az_cidr_block_app    = "${cidrsubnet(module.vpc.cidr_block,8,16)}"
  az_cidr_block_data   = "${cidrsubnet(module.vpc.cidr_block,8,32)}"
  az_nat_ami = "${var.nat_ami}"
  az_nat_instance_type = "${var.nat_instance_type}"
  az_nat_keyname = "${var.nat_keyname}"
}

module "vpn" {
  source = "../modules/vpn"
  vpn_ami = "${var.vpn_ami}"
  vpn_instance_type = "${var.vpn_instance_type}"
  vpn_subnet = "${module.az.public_subnet_id}"
  vpn_zone_id = "${var.zone_id}"
  vpn_vpc_id = "${module.vpc.vpc_id}"
  vpn_env = "${var.env}"
  vpn_keyname = "${var.default_keyname}"
}

module "common" {
  source = "../modules/common"
  common_vpc_id = "${module.vpc.vpc_id}"
  common_vpn_sg = "${module.vpn.vpn_sg}"
  common_bootstrap_bucket = "${var.bootstrap_bucket}"
  vpn_sg = "${module.vpn.vpn_sg}"
}

module "jenkins" {
  source = "../modules/jenkins"
  jenkins_ami = "${var.jenkins_ami}"
  jenkins_instance_type = "${var.jenkins_instance_type}"
  jenkins_subnet = "${module.az.app_subnet_id}"
  jenkins_zone_id = "${var.zone_id}"
  jenkins_vpc_id = "${module.vpc.vpc_id}"
  jenkins_env = "${var.env}"
  jenkins_keyname = "${var.default_keyname}"
  common_sg = "${module.common.common_sg}"
  vpn_sg = "${module.vpn.vpn_sg}"
  bootstrap_profile = "${module.common.bootstrap_profile}"
}
