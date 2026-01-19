provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "DemoVPC"
  }
}

resource "aws_subnet" "demo_subnet" {
  vpc_id            = aws_vpc.demo_vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "DemoSubnet"
  }
}

resource "aws_security_group" "demo_sg" {
  name        = "DemoSecurityGroup"
  description = "Demo SG with open SSH"
  vpc_id      = aws_vpc.demo_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "DemoSG"
  }
}

resource "aws_instance" "demo_instance" {
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.demo_subnet.id
  vpc_security_group_ids = [aws_security_group.demo_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "DemoInstance"
  }
}

resource "aws_s3_bucket" "demo_bucket" {
  bucket = "demo-cloud-detox-bucket-12345"
  acl    = "private"

  tags = {
    Name = "DemoBucket"
  }
}