provider "aws" { region = "${var.aws_region}" }

module "vpc_dev" {
  source = "../modules/vpc"
  vpc_env = "dev"
  vpc_region = "${var.aws_region}"
  vpc_cidr_block = "${var.cidr_block}"
}

module "az" {
  source = "../modules/az"
  az_env = "dev"
  az = "${var.az1}"
  az_vpc_id = "${module.vpc_dev.vpc_id}"
  az_igw_id = "${module.vpc_dev.igw_id}"
  az_cidr_block_public = "${cidrsubnet(module.vpc_dev.cidr_block,8,0)}"
  az_cidr_block_web    = "${cidrsubnet(module.vpc_dev.cidr_block,8,8)}"
  az_cidr_block_app    = "${cidrsubnet(module.vpc_dev.cidr_block,8,16)}"
  az_cidr_block_data   = "${cidrsubnet(module.vpc_dev.cidr_block,8,32)}"
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
