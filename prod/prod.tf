provider "aws" { region = "${var.aws_region}" }

module "vpc" {
  source = "../modules/vpc/"
  vpc_env = "${var.env}"
  vpc_region = "${var.aws_region}"
  vpc_cidr_block = "${var.cidr_block}"
}

module "az1" {
  source = "../modules/az"
  az_env = "${var.env}"
  az = "${var.az1}"
  az_vpc_id = "${module.vpc.vpc_id}"
  az_igw_id = "${module.vpc.igw_id}"
  az_cidr_block_public = "${cidrsubnet(module.vpc.cidr_block,8,0)}"
  az_cidr_block_web    = "${cidrsubnet(module.vpc.cidr_block,8,32)}"
  az_cidr_block_app    = "${cidrsubnet(module.vpc.cidr_block,8,64)}"
  az_cidr_block_data   = "${cidrsubnet(module.vpc.cidr_block,8,96)}"
}

module "az2" {
  source = "../modules/az"
  az_env = "${var.env}"
  az = "${var.az2}"
  az_vpc_id = "${module.vpc.vpc_id}"
  az_igw_id = "${module.vpc.igw_id}"
  az_cidr_block_public = "${cidrsubnet(module.vpc.cidr_block,8,1)}"
  az_cidr_block_web    = "${cidrsubnet(module.vpc.cidr_block,8,33)}"
  az_cidr_block_app    = "${cidrsubnet(module.vpc.cidr_block,8,65)}"
  az_cidr_block_data   = "${cidrsubnet(module.vpc.cidr_block,8,97)}"
}

module "az3" {
  source = "../modules/az"
  az_env = "${var.env}"
  az = "${var.az3}"
  az_vpc_id = "${module.vpc.vpc_id}"
  az_igw_id = "${module.vpc.igw_id}"
  az_cidr_block_public = "${cidrsubnet(module.vpc.cidr_block,8,2)}"
  az_cidr_block_web    = "${cidrsubnet(module.vpc.cidr_block,8,34)}"
  az_cidr_block_app    = "${cidrsubnet(module.vpc.cidr_block,8,66)}"
  az_cidr_block_data   = "${cidrsubnet(module.vpc.cidr_block,8,98)}"
}

module "vpn" {
  source = "../modules/vpn"
  vpn_ami = "${var.vpn_ami}"
  vpn_instance_type = "${var.vpn_instance_type}"
  vpn_subnet = "${module.az1.public_subnet_id}"
  vpn_zone_id = "${var.zone_id}"
  vpn_vpc_id = "${module.vpc.vpc_id}"
  vpn_env = "${var.env}"
  vpn_keyname = "${var.default_keyname}"
}

module "common" {
  source = "../modules/common"
  common_env = "${var.env}"
  common_vpc_id = "${module.vpc.vpc_id}"
  common_vpn_sg = "${module.vpn.vpn_sg}"
  common_bootstrap_bucket = "${var.bootstrap_bucket}"
  vpn_sg = "${module.vpn.vpn_sg}"
}
