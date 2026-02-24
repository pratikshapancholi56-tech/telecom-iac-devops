terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC Configuration
resource "aws_vpc" "telecom_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "telecom-vpc"
  }
}

resource "aws_subnet" "telecom_subnet" {
  vpc_id                  = aws_vpc.telecom_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "telecom-subnet"
  }
}

resource "aws_internet_gateway" "telecom_igw" {
  vpc_id = aws_vpc.telecom_vpc.id

  tags = {
    Name = "telecom-igw"
  }
}

resource "aws_route_table" "telecom_rt" {
  vpc_id = aws_vpc.telecom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.telecom_igw.id
  }

  tags = {
    Name = "telecom-rt"
  }
}

resource "aws_route_table_association" "telecom_rta" {
  subnet_id      = aws_subnet.telecom_subnet.id
  route_table_id = aws_route_table.telecom_rt.id
}

# Security Group
resource "aws_security_group" "telecom_sg" {
  name        = "telecom-sg"
  description = "Security group for telecom application"
  vpc_id      = aws_vpc.telecom_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "telecom-sg"
  }
}

# EC2 Instance
resource "aws_instance" "telecom_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.telecom_subnet.id
  
  vpc_security_group_ids = [aws_security_group.telecom_sg.id]
  
  key_name = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker
              
              # Pull and run the application
              docker run -d -p 5000:5000 --name telecom-app --restart always telecom-app:latest
              EOF

  tags = {
    Name = "telecom-server"
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Outputs
output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.telecom_server.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.telecom_server.public_dns
}

output "application_url" {
  description = "URL to access the application"
  value       = "http://${aws_instance.telecom_server.public_ip}:5000"
}
