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

module "kubernetes" {
  source = "scholzj/kubernetes/aws"

  aws_region           = "ap-southeast-1"
  cluster_name         = "edo-k8s"
  master_instance_type = "t2.medium"
  worker_instance_type = "t2.medium"
  ssh_public_key       = "~/.ssh/id_rsa.pub"
  ssh_access_cidr      = ["0.0.0.0/0"]
  api_access_cidr      = ["0.0.0.0/0"]
  min_worker_count     = 3
  max_worker_count     = 6
  hosted_zone          = "kenchlightyear.com"
  hosted_zone_private  = false

  master_subnet_id = module.vpc.public_subnets[0]
  worker_subnet_ids = module.vpc.private_subnets

  tags = {
    Application = "AWS-Kubernetes"
  }

  tags2 = [
    {
      key                 = "Application"
      value               = "AWS-Kubernetes"
      propagate_at_launch = true
    },
  ]

  addons = [
    "https://raw.githubusercontent.com/scholzj/terraform-aws-kubernetes/master/addons/storage-class.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-kubernetes/master/addons/metrics-server.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-kubernetes/master/addons/dashboard.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-kubernetes/master/addons/external-dns.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-kubernetes/master/addons/autoscaler.yaml",
  ]
}
