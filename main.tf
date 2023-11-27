provider "aws" {
  region = "us-west-2"
  profile = "default"
}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

module "myapp-subnet-1" {
  source = "./modules/subnet"
  vpc_id = aws_vpc.myapp-vpc.id
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  env_prefix = var.env_prefix
  subnet_cidr_block = var.subnet_cidr_block
  subnet_az = var.subnet_az
}

module "myapp-webserver" {
  source = "./modules/webserver"
  vpc_id = aws_vpc.myapp-vpc.id
  my_ip = var.my_ip
  env_prefix = var.env_prefix
  instance_type = var.instance_type
  subnet_id = module.myapp-subnet-1.subnet.id
  subnet_az = var.subnet_az
  subnet_cidr_block = var.vpc_cidr_block
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
}
