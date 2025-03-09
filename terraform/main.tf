provider "aws" {
  region = var.aws_region
}

# Security Group
resource "aws_security_group" "webserver_access" {
  name        = "webserver_access"
  description = "Allow SSH & HTTP"

  ingress {
    from_port   = 80
    to_port     = 80
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
}

# EC2 Instance
resource "aws_instance" "webserver" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = [aws_security_group.webserver_access.name]

  user_data = filebase64("install_apache.sh")

  tags = {
    Name = "webserver"
  }
}

