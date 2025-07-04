
# VPC
resource "aws_vpc" "ec2_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  tags = {
    Name = "ec2-vpc"
  }
}


# INTERNET GATEWAY
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ec2_vpc.id
  tags = {
    Name = "ec2-Internet Gateway"
  }
}


# ELASTIC IP
resource "aws_eip" "EIP" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
}


# SUBNETS
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.ec2_vpc.id
  count             = length(var.vpc_availability_zones)
  cidr_block        = cidrsubnet(aws_vpc.ec2_vpc.cidr_block, 8, count.index + 1)
  availability_zone = element(var.vpc_availability_zones, count.index)
  tags = {
    Name = "ec2 Public subnet ${count.index + 1}"
  }
}


resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.ec2_vpc.id
  count             = length(var.vpc_availability_zones)
  cidr_block        = cidrsubnet(aws_vpc.ec2_vpc.cidr_block, 8, count.index + 3)
  availability_zone = element(var.vpc_availability_zones, count.index)
  tags = {
    Name = "ec2 Private subnet ${count.index + 1}"
  }
}


# NAT Gateway
resource "aws_nat_gateway" "ec2_nat_gateway" {
  allocation_id = aws_eip.EIP.id
  count          = length(var.vpc_availability_zones)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name = "ec2-Nat Gateway"
  }
}


# ROUTE TABLES AND ASSOCIATION
resource "aws_route_table" "ec2_route_table_public_subnet" {
  vpc_id = aws_vpc.ec2_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Public subnet Route Table"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  route_table_id = aws_route_table.ec2_route_table_public_subnet.id
  count          = length(var.vpc_availability_zones)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
}


resource "aws_route_table" "ec2_route_table_private_subnet" {
  depends_on = [aws_nat_gateway.ec2_nat_gateway]
  vpc_id     = aws_vpc.ec2_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "aws_nat_gateway.ec2_nat_gateway[*].id"
  }
  tags = {
    Name = "Private subnet Route Table"
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  route_table_id = aws_route_table.ec2_route_table_private_subnet.id
  count          = length(var.vpc_availability_zones)
  subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
}