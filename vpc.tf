
provider "aws" {
  region     = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_vpc" "equalexperts" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name"        = "ee_vpc"
    "Owner"       = "equal_experts"
    "TTL"         = ""
    "Description" = ""
  }
}