resource "aws_security_group" "myapp-sg" {
    name = "${var.env_prefix}-sg"
    vpc_id = var.vpc_id
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
  availability_zone = var.subnet_az

  associate_public_ip_address = true
  subnet_id = var.subnet_id
  
  user_data = file("${path.module}/userdata.sh")

  tags = {
    Name = "${var.env_prefix}-server"
  }
}