provider "aws" {
  region = "us-east-1"
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
  tags = {
    Name = "tf-subnet"
  }
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

resource "aws_key_pair" "tf-key" {
 
 key_name   = "tf-key-2"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCkLDkAzb9JfjiVFOPb4RSq0S5kYUZOBAD2LDEcJ5/pTgyVwYwSrc+E+AOufysQdO0IiDXsjG233Rsn6InRQfNPWDwOUgrMfegJujFV8ZrWYfMFzEoWKOgcBcQPi2m+R/O/IQawSIxKo1ZC6FY+TwEgAg2zW7ikxrAlvAhlgYWlMMtcFKk/3El182lSCO5nSZ0isJbghCHt6kQKLEn2rWth+GqrkBj6x1hBYJP1AJd1bJH+zrCRBBJ+RozcxHqj8t48AHKCao718KE97rUGZkHSnFTutKxiQPOvL6yMF5CNy4bdQlyeZ386rhHWVdy53mBjRpPeh+vleEKpSSkXzmIwrF8gIIj3/McXTzSPI3WOZAPm9+5jnWIVAapmlZ5ZERyl49swGRGK9w4IWdKgxDUBA42brXky1sT6TE5FfYup7bJQ0N1tvna/GxSsEJresRNbWzcJFhYYtyH7DF/zIhJ0O77AQ486+/OQej945bnDDor7YR3hh472hos6lEc2bKE= student@dhcp"
}

resource "aws_instance" "php_instance" {
  ami                         = "ami-080e1f13689e07408"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.tf-key.key_name
  subnet_id                   = aws_subnet.tf-subnet.id
  vpc_security_group_ids      = [aws_security_group.tf-sg.id]
  tags = {
    Name = "PHP-Instance"
  }
}

resource "aws_instance" "python_instance" {
  ami                         = "ami-080e1f13689e07408"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.tf-key.key_name
  subnet_id                   = aws_subnet.tf-subnet.id
  vpc_security_group_ids      = [aws_security_group.tf-sg.id]
  tags = {
    Name = "Python-Instance"
  }
}

output "php_instance_ip" {
  value = aws_instance.php_instance.public_ip
}

output "python_instance_ip" {
  value = aws_instance.python_instance.public_ip
}
