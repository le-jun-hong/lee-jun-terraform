terraform {
  backend "s3" {
    key = "stage/terraform.tfstate"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-2"
  profile = "terraform_user"
}

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */


module "vpc" {
  source         = "../../module/vpc"
  vpc_cidr       = "192.168.0.0/16"
  public-1_cidr  = "192.168.1.0/24"
  public-2_cidr  = "192.168.2.0/24"
  private-1_cidr = "192.168.10.0/24"
  private-2_cidr = "192.168.20.0/24"
  private-3_cidr = "192.168.30.0/24"
  private-4_cidr = "192.168.40.0/24"
  ssh_port       = 22
}
output "vpc_ip" {
  value       = module.vpc.vpc_id
  description = "vpc_ip"
}

output "public_subnet_1" {
  value       = module.vpc.public_subnet_1
  description = "public_subnet1"
}
output "public_subnet_2" {
  value       = module.vpc.public_subnet_2
  description = "public_subnet2"
}
output "private_subnet_1" {
  value       = module.vpc.private_subnet_1
  description = "private_subnet1"
}
output "private_subnet_2" {
  value       = module.vpc.private_subnet_2
  description = "private_subnet2"
}
output "private_subnet_3" {
  value       = module.vpc.private_subnet_3
  description = "private_subnet3"
}
output "private_subnet_4" {
  value       = module.vpc.private_subnet_4
  description = "private_subnet4"
}
output "EC2_Pub_IP" {
  value       = module.vpc.EC2_Pub_IP
  description = "Stage BastionHost Public IP"
}
output "db_se_gr" {
  value       = module.vpc.se_gr
  description = "db_segr"
}

module "web-cluster" {
  source          = "../../module/webcluster"
  instance_type   = "t2.micro"
  min_size        = "1"
  max_size        = "1"
  http_port       = 80
  vpc_id          = data.terraform_remote_state.data_resource.outputs.vpc_ip
  public_subnet1  = data.terraform_remote_state.data_resource.outputs.public_subnet_1
  public_subnet2  = data.terraform_remote_state.data_resource.outputs.public_subnet_2
  private_subnet1 = data.terraform_remote_state.data_resource.outputs.private_subnet_1
  private_subnet3 = data.terraform_remote_state.data_resource.outputs.private_subnet_3
}