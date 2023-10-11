variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
}

variable "min_size" {
  description = "ASG Min Size"
  type        = string
}

variable "max_size" {
  description = "ASG Max Size"
  type        = string
}

variable "http_port" {
  description = "HTTP Service"
  type        = number
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
}

variable "public_subnet1" {
  description = "public-1 "
  type        = string
}

variable "public_subnet2" {
  description = "public-2 "
  type        = string
}

variable "private_subnet1" {
  description = "Private-1 "
  type        = string
}

variable "private_subnet3" {
  description = "Private-3 "
  type        = string
}
