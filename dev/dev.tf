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

