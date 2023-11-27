output "aws_ami_id" {
  value = module.myapp-webserver.webserver-instance.ami
}

output "ec2-public-ip" {
  value = module.myapp-webserver.webserver-instance.public_ip
}