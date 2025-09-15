# Add Virtual Private Cloud for the dual tier app Setup
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-VPC"
  }

}

# Create internet gateway (IGW) and connect it to VPC (for outgoing traffic)
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-IGW"
  }

}

# Fetch all AZs
data "aws_availability_zones" "azs" {
  state = "available"

}

# Store az details
locals {
  az1     = data.aws_availability_zones.azs.names[0]
  az2     = data.aws_availability_zones.azs.names[1]
  all_ips = "0.0.0.0/0"
}

# Create public subnets for both AZs
resource "aws_subnet" "public_subnetA" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_A
  availability_zone       = local.az1
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnetA"
  }

}

resource "aws_subnet" "public_subnetB" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_B
  availability_zone       = local.az2
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnetB"
  }

}

# Create route table for public traffic
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "Public-Route"
  }

}

# Attach route-table to the subnet az1
resource "aws_route_table_association" "attach_route_subnetA" {
  subnet_id      = aws_subnet.public_subnetA.id
  route_table_id = aws_route_table.public_route_table.id

}

# Attach route-table to the subnet az2
resource "aws_route_table_association" "attach_route_subnetB" {
  subnet_id      = aws_subnet.public_subnetB.id
  route_table_id = aws_route_table.public_route_table.id

}

# Create private subnet
resource "aws_subnet" "private_subnetA" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_A
  availability_zone = local.az1
  #map_customer_owned_ip_on_launch = false

  tags = {
    Name = "private_subnetA"
  }

}

resource "aws_subnet" "private_subnetB" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_B
  availability_zone = local.az2
  #map_customer_owned_ip_on_launch = false

  tags = {
    Name = "private_subnetB"
  }

}