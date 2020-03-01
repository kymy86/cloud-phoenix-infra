resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "${var.app_name} - VPC"
    Environment = var.environment
    Application = var.app_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.app_name} - IGW"
    Environment = var.environment
    Application = var.app_name
  }
}

resource "aws_route" "public_access" {
  route_table_id         = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_subnet" "public_subnet" {
  count                   = length(split(",", var.az_zones))
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index+10)
  availability_zone       = element(split(",", var.az_zones), count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.app_name} - Public subnet ${element(split(",", var.az_zones), count.index)}"
    Environment = var.environment
    Application = var.app_name
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.app_name} - Private Route table"
    Environment = var.environment
    Application = var.app_name
  }
}

#elastic IP for the NAT Gateway
resource "aws_eip" "nat_eip" {}

#NAT gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.0.id
}

resource "aws_route" "private_access" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.nat_gateway.id

  depends_on = [aws_route_table.private_route_table, aws_nat_gateway.nat_gateway]
}

resource "aws_subnet" "private_subnet" {
  count             = length(split(",", var.az_zones))
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, count.index+20)
  availability_zone = element(split(",", var.az_zones), count.index)

  tags = {
    Name = "${var.app_name} - Private subnet ${element(split(",", var.az_zones), count.index)}"
    Environment = var.environment
    Application = var.app_name
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = length(split(",", var.az_zones))
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_vpc.vpc.main_route_table_id
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = length(split(",", var.az_zones))
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}
