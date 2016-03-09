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
  az_cidr_block_web    = "${cidrsubnet(module.vpc.cidr_block,8,8)}"
  az_cidr_block_app    = "${cidrsubnet(module.vpc.cidr_block,8,16)}"
  az_cidr_block_data   = "${cidrsubnet(module.vpc.cidr_block,8,32)}"
}

module "az2" {
  source = "../modules/az"
  az_env = "${var.env}"
  az = "${var.az2}"
  az_vpc_id = "${module.vpc.vpc_id}"
  az_igw_id = "${module.vpc.igw_id}"
  az_cidr_block_public = "${cidrsubnet(module.vpc.cidr_block,8,1)}"
  az_cidr_block_web    = "${cidrsubnet(module.vpc.cidr_block,8,9)}"
  az_cidr_block_app    = "${cidrsubnet(module.vpc.cidr_block,8,17)}"
  az_cidr_block_data   = "${cidrsubnet(module.vpc.cidr_block,8,33)}"
}

module "az3" {
  source = "../modules/az"
  az_env = "${var.env}"
  az = "${var.az3}"
  az_vpc_id = "${module.vpc.vpc_id}"
  az_igw_id = "${module.vpc.igw_id}"
  az_cidr_block_public = "${cidrsubnet(module.vpc.cidr_block,8,2)}"
  az_cidr_block_web    = "${cidrsubnet(module.vpc.cidr_block,8,10)}"
  az_cidr_block_app    = "${cidrsubnet(module.vpc.cidr_block,8,18)}"
  az_cidr_block_data   = "${cidrsubnet(module.vpc.cidr_block,8,34)}"
}
