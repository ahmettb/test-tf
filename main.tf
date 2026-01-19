provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "bad_vpc" {
  cidr_block = "10.99.0.0/16"
  tags = { Name = "test" }
}

resource "aws_subnet" "bad_subnet" {
  vpc_id     = aws_vpc.bad_vpc.id
  cidr_block = "10.99.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "danger_sg" {
  name        = "open-to-world"
  description = "CRITICAL: Everything is open"
  vpc_id      = aws_vpc.bad_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.99.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "zombie_1" {
  ami           = "ami-0c101f26f147fa7fd"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.bad_subnet.id
  vpc_security_group_ids = [aws_security_group.danger_sg.id]
}

resource "aws_instance" "zombie_2" {
  ami           = "ami-0c101f26f147fa7fd"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.bad_subnet.id
  tags = {
    Name = "Dev-Server-Dont-Delete"
    Env  = "Dev"
  }
}

resource "aws_s3_bucket" "leaky_bucket" {
  bucket = "detox-leak-test-2026-x123"
}

resource "aws_s3_bucket_public_access_block" "allow_public" {
  bucket = aws_s3_bucket.leaky_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_iam_user" "bad_user" {
  name = "test-user-admin"
  tags = { Risk = "High" }
}

resource "aws_iam_user_policy_attachment" "admin_attach" {
  user       = aws_iam_user.bad_user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}