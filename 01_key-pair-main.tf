##############################
## Key Pair - Main  Windows ##
##############################

# Generates a secure private key and encodes it as PEM
resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create the Key Pair
resource "aws_key_pair" "key_pair" {
  key_name   = "${lower(var.app_name)}-${lower(var.app_environment)}-windows-${lower(var.region)}"
  public_key = tls_private_key.key_pair.public_key_openssh
}

# Save file
resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.key_pair.key_name}.pem"
  content  = tls_private_key.key_pair.private_key_pem
}


##############################
## Key Pair - Main  Linux   ##
##############################

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


##############################
## Output - Key             ##
##############################

# Output private key content
output "ssh_key_linux" {
  value     = "${var.prefix}-ssh-key.pem"
  sensitive = true
}



# Output private key content
output "ssh_key" {
  value     = tls_private_key.key_pair.private_key_pem
  sensitive = true
}
