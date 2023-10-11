terraform {
  backend "s3" {
    key = "rds/state.tfstate" // 상태파일 저장 경로
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

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier                  = "demodb"
  vpc_security_group_ids      = [data.terraform_remote_state.data_re.outputs.db_se_gr]
  engine                      = "mysql"
  engine_version              = "5.7"
  instance_class              = "db.t3.micro"
  allocated_storage           = 5
  backup_retention_period     = 7
  db_name                     = "mydb"
  username                    = "hong"
  password                    = "pasword!"
  port                        = "3306"
  manage_master_user_password = false

  skip_final_snapshot = true
  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = [data.terraform_remote_state.data_re.outputs.private_subnet_2, data.terraform_remote_state.data_re.outputs.private_subnet_4]
  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"

  # Database Deletion Protection
  deletion_protection = false

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
  tags = {
    Name = "my-databasess"
  }
}
#인스턴스 식별자로 자동백업 활성화 후 진행

module "replica" {
  source                      = "terraform-aws-modules/rds/aws"
  identifier                  = "terraform-replica"
  replicate_source_db         = module.db.db_instance_identifier
  engine                      = "mysql"
  engine_version              = "5.7"
  major_engine_version        = "5.7"
  family                      = "mysql5.7"
  instance_class              = "db.t3.micro"
  allocated_storage           = 5
  port                        = 3306
  backup_retention_period     = 7
  username                    = "repleca-db"
  password                    = "password!"
  manage_master_user_password = false
  deletion_protection         = false
  skip_final_snapshot         = true
  multi_az                    = false
  subnet_ids                  = [data.terraform_remote_state.data_re.outputs.private_subnet_4]
  vpc_security_group_ids      = [data.terraform_remote_state.data_re.outputs.db_se_gr]
  tags = {
    Name = "terraform-replica-db"
  }
}
