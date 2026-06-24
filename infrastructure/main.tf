terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1" # Stockholm region
}

# Dynamically fetch the latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Programmatically generate an SSH key pair for automated cluster configuration
resource "tls_private_key" "k3s_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "k3s-automation-key"
  public_key = tls_private_key.k3s_key.public_key_openssh
}

# Security Group to allow inbound traffic for SSH, K3s API, and Nginx NodePort
resource "aws_security_group" "k3s_sg" {
  name        = "k3s-sg"
  description = "Allow inbound traffic for K3s and Nginx"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "K3s Kubernetes API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Nginx NodePort"
    from_port   = 30080
    to_port     = 30080
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

# The EC2 Instance
resource "aws_instance" "k3s_node" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "m7i-flex.large"
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]
  key_name               = aws_key_pair.generated_key.key_name

  # User data to install K3s automatically on boot
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y curl ca-certificates software-properties-common
              
              export INSTALL_K3S_CHANNEL="stable"
              curl -sfL https://get.k3s.io | sh -
              
              # Wait for cluster setup and make kubeconfig securely readable by the ubuntu user
              sleep 15
              chmod 644 /etc/rancher/k3s/k3s.yaml
              EOF

  tags = {
    Name = "K3s-Node"
  }
}

output "k3s_public_ip" {
  value       = aws_instance.k3s_node.public_ip
  description = "The public IP of the K3s node"
}

output "private_key_pem" {
  value       = tls_private_key.k3s_key.private_key_pem
  description = "The private key data used to connect to the node"
  sensitive   = true
}

