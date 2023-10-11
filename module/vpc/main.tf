resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true      
  enable_dns_hostnames = true      
  instance_tenancy     = "default"

  tags = {
    Name = "terraform-my-vpc"
  }
}

// public subnets 정의 
resource "aws_subnet" "my_vpc_public_subnet1" {
  vpc_id                  = aws_vpc.my_vpc.id       
  cidr_block              = var.public-1_cidr 
  map_public_ip_on_launch = true              
  availability_zone       = "ap-northeast-2a" 
  tags = {
    Name = "terraform-public-subnet-1"
  }
}

resource "aws_subnet" "my_vpc_public_subnet2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public-2_cidr
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-2c"
  tags = {
    Name = "terraform-public-subnet-2"
  }
}

// private subnets 정의 
resource "aws_subnet" "my_vpc_private_subnet1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private-1_cidr
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "terraform-private-subnet-1"
  }
}

resource "aws_subnet" "my_vpc_private_subnet2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private-2_cidr
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "terraform-private-subnet-2"
  }
}
resource "aws_subnet" "my_vpc_private_subnet3" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private-3_cidr
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "terraform-private-subnet-3"
  }
}
resource "aws_subnet" "my_vpc_private_subnet4" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private-4_cidr
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "terraform-private-subnet-4"
  }
}
 
resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.my_vpc.id 
  tags = {
    Name = "terraform-my_vpc_IG"
  }
}


resource "aws_default_route_table" "my_vpc_public_routing_table" {
  default_route_table_id = aws_vpc.my_vpc.default_route_table_id
  tags = {
    Name = "terraform-my_vpc_public_RT"
  }
}


resource "aws_route" "my_vpc_internet" {
  route_table_id         = aws_vpc.my_vpc.main_route_table_id // 규칙을 추가 할 Routing Table 지정
  destination_cidr_block = "0.0.0.0/0"                        // 목적지 CIDR Block
  gateway_id             = aws_internet_gateway.my_vpc_igw.id // 위에서 정의한 목적지의 GW
}




resource "aws_eip" "my_vpc_eip" {
  tags = {
    Name = "terraform-NAT_GW_ip"
  }
}

resource "aws_nat_gateway" "my_vpc_nat_gw" {
  allocation_id = aws_eip.my_vpc_eip.id
  subnet_id     = aws_subnet.my_vpc_public_subnet1.id
}



resource "aws_route_table" "my_vpc_private_routing_table" {
  vpc_id = aws_vpc.my_vpc.id 
  tags = {
    Name = "terraform-private_RT"
  }
}


resource "aws_route" "my_vpc_private_route" {
  route_table_id         = aws_route_table.my_vpc_private_routing_table.id // 규칙을 추가 할 Routing Table 지정
  destination_cidr_block = "0.0.0.0/0"                                     // 목적지 CIDR Block
  nat_gateway_id         = aws_nat_gateway.my_vpc_nat_gw.id                // 위에서 정의한 목적지의 GW
}



resource "aws_route_table_association" "my_vpc_public_subnet1_association" {
  subnet_id      = aws_subnet.my_vpc_public_subnet1.id
  route_table_id = aws_vpc.my_vpc.main_route_table_id
}

resource "aws_route_table_association" "my_vpc_public_subnet2_association" {
  subnet_id      = aws_subnet.my_vpc_public_subnet2.id
  route_table_id = aws_vpc.my_vpc.main_route_table_id
}


resource "aws_route_table_association" "my_vpc_private_subnet1_association" {
  subnet_id      = aws_subnet.my_vpc_private_subnet1.id
  route_table_id = aws_route_table.my_vpc_private_routing_table.id
}

resource "aws_route_table_association" "my_vpc_private_subnet2_association" {
  subnet_id      = aws_subnet.my_vpc_private_subnet2.id
  route_table_id = aws_route_table.my_vpc_private_routing_table.id
}


data "aws_key_pair" "EC2-Key" {
  key_name = "key-pair"
}

 
resource "aws_security_group" "BastionHost_sg" {
  name        = "terraform-Bastiongost"
  description = "SSH open"
  vpc_id      = aws_vpc.my_vpc.id
  ingress {                      
    from_port   = var.ssh_port  
    to_port     = var.ssh_port  
    protocol    = "tcp"         
    cidr_blocks = ["0.0.0.0/0"] 
  }
  egress {                      
    from_port   = 0             
    to_port     = 0             
    protocol    = "-1"          
    cidr_blocks = ["0.0.0.0/0"] 
  }
}



resource "aws_instance" "BastionHost" {
  ami                         = "ami-0ea4d4b8dc1e46212"
  instance_type               = "t2.micro"
  key_name                    = data.aws_key_pair.EC2-Key.key_name
  availability_zone           = aws_subnet.my_vpc_public_subnet2.availability_zone
  subnet_id                   = aws_subnet.my_vpc_public_subnet2.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.BastionHost_sg.id]
    tags = {
    Name = "bastionhost"
  }
}


resource "aws_eip" "BastionHost_eip" {
  instance = aws_instance.BastionHost.id
  tags = {
    Name = "terraform-Bastion-ip"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "terraform-db_se_gr"
  description = "3306 open"
  vpc_id      = aws_vpc.my_vpc.id
  ingress {                      
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"         
    cidr_blocks = ["192.168.10.0/24", "192.168.30.0/24", "192.168.40.0/24"]
  }
  egress {                      
    from_port   = 0             
    to_port     = 0             
    protocol    = "-1"          
    cidr_blocks = ["0.0.0.0/0"]
  }
}