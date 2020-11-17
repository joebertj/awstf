terraform {
  backend "s3" {
    bucket         = "edo-tf-state"
    key            = "terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "edo-tf-locks"
    encrypt        = true
  }
}
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "edo-vpc"
  cidr = "172.10.64.0/20"

  azs             = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  private_subnets = ["172.10.64.0/24", "172.10.65.0/24", "172.10.66.0/24"]
  public_subnets  = ["172.10.68.0/24", "172.10.69.0/24", "172.10.70.0/24"]
  intra_subnets  = ["172.10.72.0/24", "172.10.73.0/24", "172.10.74.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
