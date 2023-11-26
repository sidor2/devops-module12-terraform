provider "aws" {
  region = "us-west-2"
  profile = "default"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable subnet_az {}
variable env_prefix {}
variable my_ip {}
variable instance_type {}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "myapp-subnet-1" {
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.subnet_az
  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

resource "aws_default_route_table" "main-route-table" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name = "${var.env_prefix}-main-route-table"
  }
}


resource "aws_security_group" "myapp-sg" {
    name = "${var.env_prefix}-sg"
    vpc_id = aws_vpc.myapp-vpc.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"] 
    }

    tags = {
        Name = "${var.env_prefix}-sg"
    }
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.amazon-linux-2.id
  instance_type = var.instance_type
  key_name = "ec2devops"
  vpc_security_group_ids = [aws_security_group.myapp-sg.id]
  subnet_id = aws_subnet.myapp-subnet-1.id
  associate_public_ip_address = true
  availability_zone = var.subnet_az
  tags = {
    Name = "${var.env_prefix}-server"
  }
  user_data = file("entry-script.sh")
}

output "ec2-piblic-ip" {
  value = aws_instance.myapp-server.public_ip
}