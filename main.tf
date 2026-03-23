terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }


  backend "s3" {
    bucket = "2026-03-23-bs"
    key    = "app/terraform.tfstate" # Key könnt ihr selbst bestimmen, sollte nur über die deployments einheitlich sein
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "ssh" {
  name        = "allow-ssh"
  description = "Allow SSH inbound traffic"

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
}

resource "aws_instance" "demo" {
  ami                    = "ami-0b6c6ebed2801a5cb" # ubuntu
  instance_type          = "t2.micro"
  key_name               = "second-key-pair"
  vpc_security_group_ids = [aws_security_group.ssh.id]
  tags = {
    Name = "test-server-iac"
  }
}


output "instance_id" {
  value = aws_instance.demo.id
}

output "public_ip" {
  value = aws_instance.demo.public_ip
}
