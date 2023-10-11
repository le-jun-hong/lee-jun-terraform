data "terraform_remote_state" "data_resource" {
  backend = "s3"
  config = {
    bucket  = "myterraform-bucket-state-leejunhong-1t"
    key     = "stage/terraform.tfstate"
    profile = "terraform_user"
    region  = "ap-northeast-2"
  }
}