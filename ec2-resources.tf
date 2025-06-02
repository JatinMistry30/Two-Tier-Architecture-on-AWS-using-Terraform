# Create ec2 instances
resource "aws_instance" "web1" {
  ami           = "ami-0287a05f0ef0e9d9a"
  instance_type = "t2.micro"
  key_name        = "twotier-key-pair"
  availability_zone = "ap-south-1a"
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  subnet_id                   = aws_subnet.public_1.id
  associate_public_ip_address = true
  tags = {
    Name = "web1_instance"
  }
}

resource "aws_instance" "web2" {
  ami           = "ami-0287a05f0ef0e9d9a"
  instance_type = "t2.micro"
  key_name        = "twotier-key-pair"
  availability_zone = "ap-south-1b"
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  subnet_id                   = aws_subnet.public_2.id
  associate_public_ip_address = true
  tags = {
    Name = "web2_instance"
  }
}