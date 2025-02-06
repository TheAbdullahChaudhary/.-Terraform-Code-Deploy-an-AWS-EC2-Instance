terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.26.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.0"
    }
  }
}

# Configure AWS Provider
provider "aws" {
  region = "us-west-2"
}

# Create private key
resource "tls_private_key" "harsha_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}





resource "aws_key_pair" "harsha_key_pair" {
  key_name   = "harsha-key-pair"
  public_key = tls_private_key.harsha_key.public_key_openssh

  # Create keys directory in the root folder and save private key
  provisioner "local-exec" {
    interpreter = ["powershell", "-Command"]
    command     = <<-EOT
      # Get the current directory (where main.tf is)
      $rootPath = $PWD.Path
      
      # Create the keys directory if it doesn't exist
      $keysPath = Join-Path -Path $rootPath -ChildPath 'keys'
      if (-Not (Test-Path -Path $keysPath)) {
          New-Item -ItemType Directory -Path $keysPath
      }
      
      # Save the private key
      $keyContent = @'
      ${tls_private_key.harsha_key.private_key_pem}
      '@
      
      # Define the key file path
      $keyPath = Join-Path -Path $keysPath -ChildPath 'harsha-key.pem'
      
      # Save the key and set permissions
      $keyContent | Out-File -FilePath $keyPath -Encoding ascii -Force
      Set-ItemProperty -Path $keyPath -Name IsReadOnly -Value $true
      
      Write-Host "Private key saved to: $keyPath"
    EOT
  }
}



# VPC and Network Configuration
resource "aws_vpc" "harsha_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "harsha-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "harsha_igw" {
  vpc_id = aws_vpc.harsha_vpc.id

  tags = {
    Name = "harsha-igw"
  }
}

resource "aws_subnet" "harsha_public_subnet" {
  vpc_id                  = aws_vpc.harsha_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "harsha-public-subnet"
  }
}

# Route Table
resource "aws_route_table" "harsha_public_rt" {
  vpc_id = aws_vpc.harsha_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.harsha_igw.id
  }

  tags = {
    Name = "harsha-public-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "harsha_public_rta" {
  subnet_id      = aws_subnet.harsha_public_subnet.id
  route_table_id = aws_route_table.harsha_public_rt.id
}

# Security Group
resource "aws_security_group" "harsha_windows_sg" {
  name        = "harsha-windows-sg"
  description = "Security group for Harsha Windows EC2"
  vpc_id      = aws_vpc.harsha_vpc.id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "harsha-windows-sg"
  }
}

# EC2 Instance
resource "aws_instance" "harsha_windows_server" {
  ami           = "ami-00aba64d12d376282"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.harsha_public_subnet.id

  root_block_device {
    encrypted   = true
    volume_size = 50
  }

  vpc_security_group_ids = [aws_security_group.harsha_windows_sg.id]
  key_name               = aws_key_pair.harsha_key_pair.key_name

  tags = {
    Name = "harsha-windows-server"
  }
}

# EBS Volume
resource "aws_ebs_volume" "harsha_data_volume" {
  availability_zone = "us-west-2a"
  size              = 100
  encrypted         = true

  tags = {
    Name = "harsha-data-volume"
  }
}

resource "aws_volume_attachment" "harsha_volume_attach" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.harsha_data_volume.id
  instance_id = aws_instance.harsha_windows_server.id
}

# Output the instance public IP
output "instance_public_ip" {
  value = aws_instance.harsha_windows_server.public_ip
}

# Output instructions for key location
output "key_location" {
  value = "Private key has been saved to: ${path.module}/keys/harsha-key.pem"
}
