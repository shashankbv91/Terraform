terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
    region = "us-east-1" 
}

# Configure VPC
resource "aws_vpc" "my-cloud" {
    cidr_block = "10.10.0.0/24"
    tags = {
        Name = "custom-network"
    }
}

# Configure the public subnet
resource "aws_subnet" "PublicSubnet" {
    vpc_id = aws_vpc.my-cloud.id
    cidr_block = "10.10.0.0/25"
    map_public_ip_on_launch = true

    tags = {
      "Name" = "PublicSubnet"
    }    
}

# Configure the private subnet
resource "aws_subnet" "PrivateSubnet" {
    vpc_id = aws_vpc.my-cloud.id
    cidr_block = "10.10.0.128/25"
    map_public_ip_on_launch = false

    tags = {
      "Name" = "PrivateSubnet"
    }
}

resource "aws_instance" "instance01" {
    ami           = "ami-0557a15b87f6559cf"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.PublicSubnet.id

    tags = {
    Name = "Public-Instance"
  }
}

resource "aws_instance" "instance02" {
    ami           = "ami-0557a15b87f6559cf"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.PrivateSubnet.id

    tags = {
    Name = "Private-Instance"
  }
}


resource "aws_security_group" "public-sg" {
  name        = "public-sg"
  description = "Allow HTTP and HTTPS inbound and outbound traffic"
  vpc_id      = aws_vpc.my-cloud.id

  ingress {
    description      = "Allow HTTP inbound"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.my-cloud.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow HTTP inbound"
  }
}