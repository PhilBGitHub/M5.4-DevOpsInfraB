## PROVIDERS

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-2"
}


## VPC INITIALISATION

resource "aws_vpc" "lab5-vpc" {
  cidr_block = "172.1.0.0/16"

  tags = {
    Name    = "lab5-vpc"
    Project = "lab-5"
  }
}


## SECURITY GROUP

resource "aws_security_group" "allow_lab5_traffic" {
  name        = "allow_lab5_traffic"
  description = "Allow inbound traffic from TLS, SSH, HTTP & SQL"
  vpc_id      = aws_vpc.lab5-vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "inbound HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "inbound connections for SQL"
    from_port        = 1433
    to_port          = 1433
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name    = "lab5_vpc_security-group"
    Project = "lab-5"
  }
}


## INTERNET GATEWAY

resource "aws_internet_gateway" "lab5-vpc-gateway" {
  vpc_id = aws_vpc.lab5-vpc.id

  tags = {
    Name    = "lab5_vpc_ig"
    Project = "lab-5"
  }
}


## ROUTE TABLE

# Creation
resource "aws_route_table" "lab5_vpc_route-table" {
  vpc_id = aws_vpc.lab5-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab5-vpc-gateway.id
  }


## SUBNETS

# Subnet Alpha
resource "aws_subnet" "subnet-alpha" {
  vpc_id     = aws_vpc.lab5-vpc.id
  cidr_block = "172.1.1.0/24"

  tags = {
    Name    = "lab5_subnet-alpha"
    Project = "lab-5"
  }
}

# Subnet Bravo
resource "aws_subnet" "subnet-bravo" {
  vpc_id     = aws_vpc.lab5-vpc.id
  cidr_block = "172.1.2.0/24"

  tags = {
    Name    = "lab5_subnet-bravo"
    Project = "lab-5"
  }
}


## ROUTE TABLE (again)

# Association - Alpha
resource "aws_route_table_association" "lab5_rta-alpha" {
  subnet_id      = aws_subnet.subnet-alpha.id
  route_table_id = aws_route_table.lab5_vpc_route-table.id
}
# Association - Bravo
resource "aws_route_table_association" "lab5_rta-bravo" {
  subnet_id      = aws_subnet.subnet-bravo.id
  route_table_id = aws_route_table.lab5_vpc_route-table.id
}


## EC2 INSTANCES

# Instance Alpha
resource "aws_instance" "ec2-alpha" {
  ami                         = "ami-0aaa5410833273cfe"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet-alpha.id
  vpc_security_group_ids      = [aws_security_group.allow_lab5_traffic.id]
  associate_public_ip_address = true

  tags = {
    Name    = "lab5_instance-alpha"
    Project = "lab-5"
  }
}

# Instance Bravo
resource "aws_instance" "ec2-bravo" {
  ami                         = "ami-0aaa5410833273cfe"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet-bravo.id
  vpc_security_group_ids      = [aws_security_group.allow_lab5_traffic.id]
  associate_public_ip_address = true

  tags = {
    Name    = "lab5_instance-bravo"
    Project = "lab-5"
  }
}


## OUTPUTS

output "vpc_id" {
  description = "id of the created vpc"
  value       = aws_vpc.lab5-vpc.id
}
output "subnet_alpha_id" {
  description = "id of subnet a"
  value       = aws_subnet.subnet-alpha.id
}
output "subnet_bravo_id" {
  description = "id of subnet b"
  value       = aws_subnet.subnet-bravo.id
}
output "aws_instance-alpha_public-ip" {
  description = "public-IPv4 of aws instance alpha"
  value       = aws_instance.ec2-alpha.public_ip
}
output "aws_instance-bravo_public-ip" {
  description = "public-IPv4 of aws instance bravo"
  value       = aws_instance.ec2-bravo.public_ip
}

