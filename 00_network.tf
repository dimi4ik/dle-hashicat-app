###################################
### erstellen VPC ( vNet) ##########
####################################
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name        = "${lower(var.app_name)}-${lower(var.app_environment)}-vpc"
    Mandant     = "${var.prefix}-vpc-${var.region}"
    Environment = var.app_environment
  }
}

####################################
### erstellen Subnet in VPC ########
### Define the public subnet #######
####################################
resource "aws_subnet" "public-subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.aws_az
  tags = {
    Name        = "${lower(var.app_name)}-${lower(var.app_environment)}-public-subnet"
    Mandant     = "${var.prefix}-vpc-${var.region}"
    Environment = var.app_environment
  }
}

#####################################
### erstellen Private Subnet in VPC #
### Define the Private subnet #######
####################################
resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_subnet_cidr
  #availability_zone = var.aws_az
  tags = {
    Name        = "${lower(var.app_name)}-${lower(var.app_environment)}-Private-subnet"
    Mandant     = "${var.prefix}-vpc-${var.region}"
    Environment = var.app_environment
  }
}



####################################
### erstellen Gataway.      ########
### Define the internet gateway ####
####################################

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${lower(var.app_name)}-${lower(var.app_environment)}-igw"
    Mandant     = "${var.prefix}-vpc-${var.region}"
    Environment = var.app_environment
  }
}


#Create EIP for NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "demo_igw_eip"
  }
}

#Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  depends_on    = [aws_subnet.public_subnets]
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnets["public_subnet_1"].id
  tags = {
    Name        = "${lower(var.app_name)}-${lower(var.app_environment)}-ngw"
    Mandant     = "${var.prefix}-vpc-${var.region}"
    Environment = var.app_environment
  }
}


####################################
### erstellen IGW Route Table ######
### Define the public route table ##
####################################
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name        = "${lower(var.app_name)}-${lower(var.app_environment)}-public-subnet-rt"
    Mandant     = "${var.prefix}-vpc-${var.region}"
    Environment = var.app_environment
  }
}

# Assign the public route table to the public subnet
resource "aws_route_table_association" "public-rt-association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}



####################################
### erstellen NGW Route Table ######
### Define the private route table ##
####################################
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.vnat_gateway_eip.vpc_id
  }
  tags = {
    Name        = "${lower(var.app_name)}-${lower(var.app_environment)}-public-subnet-rt"
    Mandant     = "${var.prefix}-vpc-${var.region}"
    Environment = var.app_environment
  }
}

# Assign the private route table to the private subnet
resource "aws_route_table_association" "private-rt-association" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
}



####################################
### Define the security group ######
####################################
resource "aws_security_group" "aws-windows-sg" {
  name        = "${lower(var.app_name)}-${var.app_environment}-windows-sg"
  description = "Allow incoming connections"
  vpc_id      = aws_vpc.vpc.id

  /*

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTP connections"
  }
*/

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming RDP connections"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${lower(var.app_name)}-${var.app_environment}-windows-sg"
    Mandant     = "${var.prefix}-vpc-${var.region}"
    Environment = var.app_environment
  }
}
