provider "aws" {
  region = "us-east-1"
}

variable "developer_name" {
  description = "List of developer names to create resources for"
  type        = string
}

variable "tech_stack" {
  description = "Technology stack for the provisioned resources (php or nodejs)"
  type        = string
}


resource "aws_vpc" "tf-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "tf-vpc"
  }
}

resource "aws_subnet" "tf-subnet" {
  vpc_id     = aws_vpc.tf-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "tf-subnet"
  }
}

resource "aws_internet_gateway" "tf-ig" {
  vpc_id = aws_vpc.tf-vpc.id
  tags = {
    Name = "tf-ig"
  }
}

resource "aws_route_table" "tf-r" {
  vpc_id = aws_vpc.tf-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-ig.id
  }

  tags = {
    Name = "tf-r"
  }
}

resource "aws_route_table_association" "tf-r-assoc" {
  subnet_id      = aws_subnet.tf-subnet.id
  route_table_id = aws_route_table.tf-r.id
}

resource "aws_security_group" "tf-sg" {
  vpc_id = aws_vpc.tf-vpc.id

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

  ingress {
    from_port   = 8080
    to_port     = 8080
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
    Name = "tf-sg"
  }
}

variable "public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCmyiLkXovkHLW19uWuK0KJJQajNbQLX0M3FuM8/raCXOv65A+Oi06EASS05em/TuzeHD5VwRc6IuVBESGgkYtNcKMJHAB31Htq/71t1TpjkAI3AhhXehxGUSDIJVjbqmUxtPh08tyQzLkQza46PLZooKn5SvDDf2bLOJL4arH/c54IGTJ+yJaTYPI8rGynbFYFIGGIlifsm0y7SvAmHZp5TJWWlyLZ9GrEvFMZNRG8LhQSzbWE7JV8UQEXMPOQEqr0enOyzvgLtkPCgQjl2QNmeBoysKHZ2ijmtrgNY2f2GEsQIwRWCyT6qAxYzIhdiJUB7Es87qn264KUk2P93Sl d00345455@desdemona"
}

resource "aws_key_pair" "tf-key" {
  key_name   = "tf-key-2"
  public_key = var.public_key
}

resource "aws_instance" "user_instance" {
  for_each = toset([format("%s-%s", var.developer_name, var.tech_stack)])

  ami                          = "ami-080e1f13689e07408"
  instance_type                = "t2.micro"
  associate_public_ip_address  = true
  key_name                     = aws_key_pair.tf-key.key_name
  subnet_id                    = aws_subnet.tf-subnet.id
  vpc_security_group_ids       = [aws_security_group.tf-sg.id]
  tags = {
    Name = each.value
  }
}


output "instance_ips" {
  value = {for instance in aws_instance.user_instance : instance.tags.Name => instance.public_ip}
  description = "Public IP addresses for each instance."
}
