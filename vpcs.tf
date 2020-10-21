# VPCs
# Private VPCs
resource "aws_vpc" "vpc-1" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name     = "${var.scenario}-vpc1-dev"
    scenario = var.scenario
    env      = "dev"
  }
}

resource "aws_vpc" "vpc-2" {
  cidr_block = "10.11.0.0/16"
  tags = {
    Name     = "${var.scenario}-vpc2-dev"
    scenario = var.scenario
    env      = "dev"
  }
}

# Public VPC
resource "aws_vpc" "vpc-3" {
  cidr_block = "10.12.0.0/16"
  tags = {
    Name     = "${var.scenario}-vpc3-shared"
    scenario = var.scenario
    env      = "shared"
  }
}

# Subnets
# Private Subnet-A VPC-1
resource "aws_subnet" "vpc-1-sub-a" {
  vpc_id            = aws_vpc.vpc-1.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = var.az1

  tags = {
    Name     = "${aws_vpc.vpc-1.tags.Name}-priv-sub-a"
    scenario = var.scenario
    env      = "dev"
  }
}

# Private Subnet-B VPC-1
resource "aws_subnet" "vpc-1-sub-b" {
  vpc_id            = aws_vpc.vpc-1.id
  cidr_block        = "10.10.2.0/24"
  availability_zone = var.az2

  tags = {
    Name     = "${aws_vpc.vpc-1.tags.Name}-priv-sub-b"
    scenario = var.scenario
    env      = "dev"
  }
}

# Private Subnet-A VPC-2
resource "aws_subnet" "vpc-2-sub-a" {
  vpc_id            = aws_vpc.vpc-2.id
  cidr_block        = "10.11.1.0/24"
  availability_zone = var.az1

  tags = {
    Name     = "${aws_vpc.vpc-2.tags.Name}-priv-sub-a"
    scenario = var.scenario
    env      = "dev"
  }
}

# Private Subnet-B VPC-2
resource "aws_subnet" "vpc-2-sub-b" {
  vpc_id            = aws_vpc.vpc-2.id
  cidr_block        = "10.11.2.0/24"
  availability_zone = var.az2

  tags = {
    Name     = "${aws_vpc.vpc-2.tags.Name}-priv-sub-b"
    scenario = var.scenario
    env      = "dev"
  }
}

# Public Subnet-A VPC-3
resource "aws_subnet" "vpc-3-pub-sub-a" {
  vpc_id            = aws_vpc.vpc-3.id
  cidr_block        = "10.12.1.0/24"
  availability_zone = var.az1

  tags = {
    Name     = "${aws_vpc.vpc-3.tags.Name}-pub-sub-a"
    scenario = var.scenario
    env      = "shared"
  }
}

# Public Subnet-B VPC-3
resource "aws_subnet" "vpc-3-pub-sub-b" {
  vpc_id            = aws_vpc.vpc-3.id
  cidr_block        = "10.12.2.0/24"
  availability_zone = var.az2

  tags = {
    Name     = "${aws_vpc.vpc-3.tags.Name}-pub-sub-b"
    scenario = var.scenario
    env      = "shared"
  }
}

# Private Subnet-A VPC-3
resource "aws_subnet" "vpc-3-priv-sub-a" {
  vpc_id            = aws_vpc.vpc-3.id
  cidr_block        = "10.12.3.0/24"
  availability_zone = var.az1

  tags = {
    Name     = "${aws_vpc.vpc-3.tags.Name}-priv-sub-a"
    scenario = var.scenario
    env      = "shared"
  }
}

# Private Subnet-B VPC-3
resource "aws_subnet" "vpc-3-priv-sub-b" {
  vpc_id            = aws_vpc.vpc-3.id
  cidr_block        = "10.12.4.0/24"
  availability_zone = var.az2

  tags = {
    Name     = "${aws_vpc.vpc-3.tags.Name}-priv-sub-b"
    scenario = var.scenario
    env      = "shared"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "vpc-3-igw" {
  vpc_id = aws_vpc.vpc-3.id

  tags = {
    Name     = "vpc-3-igw"
    scenario = var.scenario
  }
}

# Nat EIPs
# NAt EIP Subnet-A
resource "aws_eip" "eip-nat-sub-a" {
  vpc = true
}

# NAt EIP Subnet-B
resource "aws_eip" "eip-nat-sub-b" {
  vpc = true
}

# Nat Gateways
# Nat Gateway Public Subnet-A
resource "aws_nat_gateway" "gw-vpc-3-pub-sub-a" {
  allocation_id = aws_eip.eip-nat-sub-a.id
  subnet_id     = aws_subnet.vpc-3-pub-sub-a.id

  tags = {
    Name     = "vpc-3-nat-pub-sub-a"
    scenario = var.scenario
  }
}

# Nat Gateway Public Subnet-B
resource "aws_nat_gateway" "gw-vpc-3-pub-sub-b" {
  allocation_id = aws_eip.eip-nat-sub-b.id
  subnet_id     = aws_subnet.vpc-3-pub-sub-b.id

  tags = {
    Name     = "vpc-3-nat-pub-sub-b"
    scenario = var.scenario
  }
}


# # Route Tables Propagations
# ## This section defines which VPCs will be routed from each Route Table created in the Transit Gateway

# resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-dev-to-vpc-1" {
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-1.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-dev-rt.id
# }

# resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-dev-to-vpc-2" {
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-2.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-dev-rt.id
# }

# resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-dev-to-vpc-3" {
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-3.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-dev-rt.id
# }

# resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-shared-to-vpc-1" {
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-1.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-shared-rt.id
# }

# resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-shared-to-vpc-2" {
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-2.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-shared-rt.id
# }
