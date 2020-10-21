# Main Route Tables Associations
## Forcing our Route Tables to be the main ones for our VPCs,
## otherwise AWS automatically will create a main Route Table
## for each VPC, leaving our own Route Tables as secondary

resource "aws_main_route_table_association" "main-rt-vpc-1" {
  vpc_id         = aws_vpc.vpc-1.id
  route_table_id = aws_route_table.vpc-1-rtb.id
}

resource "aws_main_route_table_association" "main-rt-vpc-2" {
  vpc_id         = aws_vpc.vpc-2.id
  route_table_id = aws_route_table.vpc-2-rtb.id
}

resource "aws_main_route_table_association" "main-rt-vpc-3" {
  vpc_id         = aws_vpc.vpc-3.id
  route_table_id = aws_route_table.vpc-3-rtb.id
}

# Route Tables
## Usually unecessary to explicitly create a Route Table in Terraform
## since AWS automatically creates and assigns a 'Main Route Table'
## whenever a VPC is created. However, in a Transit Gateway scenario,
## Route Tables are explicitly created so an extra route to the
## Transit Gateway could be defined

# Route Table VPC-1 Dev
resource "aws_route_table" "vpc-1-rtb" {
  vpc_id = aws_vpc.vpc-1.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.test-tgw.id
  }

  tags = {
    Name     = "vpc-1-rtb"
    env      = "dev"
    scenario = var.scenario
  }
}

# Route Table VPC-2 Dev
resource "aws_route_table" "vpc-2-rtb" {
  vpc_id = aws_vpc.vpc-2.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.test-tgw.id
  }

  tags = {
    Name     = "vpc-2-rtb"
    env      = "dev"
    scenario = var.scenario
  }
}

# Route Table VPC-3 Shared
resource "aws_route_table" "vpc-3-rtb" {
  vpc_id = aws_vpc.vpc-3.id

  route {
    cidr_block         = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.test-tgw.id
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc-3-igw.id
  }

  tags = {
    Name     = "vpc-3-rtb-pub"
    env      = "shared"
    scenario = var.scenario
  }

  depends_on = [aws_ec2_transit_gateway.test-tgw]
}

# Associate RT Public with public subnets
resource "aws_route_table_association" "vpc3-rtb-sub-pub-a" {
  route_table_id = aws_route_table.vpc-3-rtb.id
  subnet_id      = aws_subnet.vpc-3-pub-sub-a.id
}

resource "aws_route_table_association" "vpc3-rtb-sub-pub-b" {
  route_table_id = aws_route_table.vpc-3-rtb.id
  subnet_id      = aws_subnet.vpc-3-pub-sub-b.id
}

# Route Table Private - A VPC-3 Shared
resource "aws_route_table" "vpc-3-rtb-priv" {
  vpc_id = aws_vpc.vpc-3.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw-vpc-3-pub-sub-a.id
  }

  tags = {
    Name     = "vpc-3-rtb-priv-a"
    env      = "shared"
    scenario = var.scenario
  }

  depends_on = [aws_nat_gateway.gw-vpc-3-pub-sub-a]
}

resource "aws_route_table" "vpc-3-rtb-priv-b" {
  vpc_id = aws_vpc.vpc-3.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw-vpc-3-pub-sub-b.id
  }

  tags = {
    Name     = "vpc-3-rtb-priv-b"
    env      = "shared"
    scenario = var.scenario
  }

  depends_on = [aws_nat_gateway.gw-vpc-3-pub-sub-b]
}

# Associate RT Public with private subnets
resource "aws_route_table_association" "vpc3-rtb-sub-priv-a" {
  route_table_id = aws_route_table.vpc-3-rtb-priv.id
  subnet_id      = aws_subnet.vpc-3-priv-sub-a.id
}

resource "aws_route_table_association" "vpc3-rtb-sub-priv-b" {
  route_table_id = aws_route_table.vpc-3-rtb-priv-b.id
  subnet_id      = aws_subnet.vpc-3-priv-sub-b.id
}
