# Добавьте в свой код блок типа aws_ami, назовите его ubuntu; 
# 3. Установите переменную most_recent = true, это позволит получить последний образ из всех; 
# 4. Установите переменную owners = ["099720109477"], это ID владельца образа - Canonical; 
# 5. Создайте блоки со следующими фильтрами: 1. name: ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-* 2. virtualization-type: hvm 1. 
# В ресурсе виртуальной машины замените параметр ami, заданный строкой, ссылкой на ресурс: data.aws_ami.ubuntu.id. Важно: кавычки ставить не нужно!

####################################
### Suchen ein Ubuntu image AMI ####
####################################

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


resource "aws_eip" "linux_vm" {
  instance = aws_instance.linux_vm.id
  vpc      = true
}

resource "aws_eip_association" "linux_vm" {
  instance_id   = aws_instance.linux_vm.id
  allocation_id = aws_eip.linux_vm.id
}

####################################
### erstellen instanc eС2 ##########
####################################


resource "aws_instance" "linux_vm" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.linux_vm.key_name
  associate_public_ip_address = false
  #subnet_id                   = aws_subnet.linux_vm.id
  subnet_id = aws_subnet.public-subnet.id
  #vpc_security_group_ids      = [aws_security_group.linux_vm.id]
  vpc_security_group_ids = [aws_security_group.aws-windows-sg.id]

  tags = {
    Name        = "${var.prefix}-linux_vm-instance"
    environment = "Production"
  }
}

/*
####################################
### erstellen zweite instanc eС2 ###
####################################


resource "aws_instance" "linuxvm2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.linux_vm.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.linux_vm.id
  vpc_security_group_ids      = [aws_security_group.linux_vm.id]


  tags = {
    Name = "${var.prefix}-linux_vm-instance"
    environment = "Production"  
  }
}



*/

# We're using a little trick here so we can run the provisioner without
# destroying the VM. Do not do this in production.

# If you need ongoing management (Day N) of your virtual machines a tool such
# as Chef or Puppet is a better choice. These tools track the state of
# individual files and can keep them in the correct configuration.

# Here we do the following steps:
# Sync everything in files/ to the remote VM.
# Set up some environment variables for our script.
# Add execute permissions to our scripts.
# Run the deploy_app.sh script.

resource "null_resource" "configure-cat-app" {
  depends_on = [aws_eip_association.linux_vm]

  triggers = {
    build_number = timestamp()
  }

  provisioner "file" {
    source      = "files/"
    destination = "/home/ubuntu/"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.linux_vm.private_key_pem
      host        = aws_eip.linux_vm.public_ip
    }
  }


  provisioner "remote-exec" {
    inline = [
      "sudo apt -y update",
      "sleep 15",
      "sudo apt -y update",
      "sudo apt -y install ansible",

      #"sudo apt -y install apache2",
      #"sudo systemctl start apache2",
      #"sudo chown -R ubuntu:ubuntu /var/www/html",
      #"chmod +x *.sh",
      #"PLACEHOLDER=${var.placeholder} WIDTH=${var.width} HEIGHT=${var.height} PREFIX=${var.prefix} ./deploy_app.sh",
      "sudo apt -y install cowsay",
      "cowsay Success! Experience the magic of Dima Automation with Terraform!",
    ]


    # figlet kerneltalks | cowsay -n

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.linux_vm.private_key_pem
      host        = aws_eip.linux_vm.public_ip
    }
  }
}

resource "tls_private_key" "linux_vm" {
  algorithm = "ED25519"
}

locals {
  private_key_filename = "${var.prefix}-ssh-key.pem"
}

resource "aws_key_pair" "linux_vm" {
  key_name   = local.private_key_filename
  public_key = tls_private_key.linux_vm.public_key_openssh
}
