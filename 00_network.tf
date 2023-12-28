

##########################################
## Network Single AZ Public Only - Main ##
##########################################

###################################
### erstellen VPC ( vNet) ##########
####################################

#resource "aws_vpc" "hashicat" {
  
# Create the VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  #cidr_block           = var.address_space
  enable_dns_hostnames = true
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpc"
    #name        = "${var.prefix}-vpc-${var.region}"
    Environment = var.app_environment
  }
}


####################################
### erstellen Subnet in VPC ########
####################################

#resource "aws_subnet" "hashicat" {
#  vpc_id     = aws_vpc.hashicat.id
#  cidr_block = var.subnet_prefix
#}
  
# Define the public subnet
resource "aws_subnet" "public-subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.aws_az
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-public-subnet"
    Environment = var.app_environment
  }
}



####################################
### erstellen Gataway.      ########
####################################

#resource "aws_internet_gateway" "hashicat" {
#  vpc_id = aws_vpc.hashicat.id
#}

# Define the internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-igw"
    Environment = var.app_environment
  }
}


####################################
### erstellen Route Table ########
####################################

/*
resource "aws_route_table" "hashicat" {
  vpc_id = aws_vpc.hashicat.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hashicat.id
  }
}

resource "aws_route_table_association" "hashicat" {
  subnet_id      = aws_subnet.hashicat.id
  route_table_id = aws_route_table.hashicat.id
}


*/


# Define the public route table
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-public-subnet-rt"
    Environment = var.app_environment
  }
}

# Assign the public route table to the public subnet
resource "aws_route_table_association" "public-rt-association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}
