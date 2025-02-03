# -------------------
# AWS Provider
# -------------------
provider "aws" {
  region = "us-east-1"
}

# -------------------
# Security Group (Allow Web, MySQL, and SSH)
# -------------------
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow web, SSH, and MySQL access"

  # Allow HTTP (8080-8083 for different applications)
  ingress {
    from_port   = 8080
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH (22) for manual EC2 access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow MySQL (3306) for database communication
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------
# Amazon EC2 Instance
# -------------------
resource "aws_instance" "web_server" {
  ami                    = "ami-01bf2bec1a52ce0e1" # Amazon Linux 2 AMI
  instance_type          = "t2.micro"
  key_name               = "vockey"  # Make sure this key exists in AWS
  security_groups        = [aws_security_group.web_sg.name]

  tags = {
    Name = "WebServer"
  }
}

# -------------------
# Amazon ECR Repositories (No IAM Role Needed)
# -------------------
resource "aws_ecr_repository" "app_repo" {
  name = "myapp-repo"
}

resource "aws_ecr_repository" "mysql_repo" {
  name = "mysql-repo"
}

# -------------------
# Outputs
# -------------------
output "ec2_public_ip" {
  value = aws_instance.web_server.public_ip
  description = "Public IP of the EC2 instance"
}

output "ecr_app_repo_url" {
  value = aws_ecr_repository.app_repo.repository_url
  description = "ECR URL for the application image"
}

output "ecr_mysql_repo_url" {
  value = aws_ecr_repository.mysql_repo.repository_url
  description = "ECR URL for the MySQL image"
}
