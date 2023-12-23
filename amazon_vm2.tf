

resource "aws_instance" "my_Ubuntu" {
# ami           = "ami-090f10efc254eaf55"
  ami           = data.aws_ami.ubuntu.id
  #instance_type = "t3.micro"
  tags = var.common_tags
  instance_type = "t3.small"
}

/*

output "AMI_Nummer" {
  value = data.aws_ami.ubuntu.id
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


data "aws_instance" "publIP" {
  instance_id = aws_instance.my_Ubuntu.id
}

output "public_ip" {
  value = data.aws_instance.publIP.public_ip
}


output "private_ip" {
  value = data.aws_instance.publIP.private_ip
}

*/

/*


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