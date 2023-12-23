/*


resource "aws_instance" "my_Ubuntu" {
  ami           = "ami-090f10efc254eaf55"
  instance_type = "t3.micro"

  tags = {
    Name    = "My Ubuntu Server"
    Owner   = "Denis Astahov"
    Project = "Terraform Lessons"
  }
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}



resource "aws_eip" "hashicat" {
  instance = aws_instance.hashicat.id
  vpc      = true
}

resource "aws_instance" "my_Amazon" {
  ami           = "ami-03a71cec707bfc3d7"
  instance_type = "t3.small"

tags = var.common_tags

  tags = {
    Name    = "My Amazon Server"
    Owner   = "dim@"
    Project = "Terraform Lessons"
  }
  
}
*/