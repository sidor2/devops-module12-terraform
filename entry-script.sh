#!/bin/bash
#  install docker on ec2 instance

sudo yum update -y && sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo docker run -d -p 8080:80 nginx

