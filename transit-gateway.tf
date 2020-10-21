# Transit Gateway
## Default association and propagation are disabled since our scenario involves
## a more elaborated setup where
## - Dev VPCs can reach themselves and the Shared VPC
## - the Shared VPC can reach all VPCs
## The default setup being a full mesh scenario where all VPCs can see every other
resource "aws_ec2_transit_gateway" "test-tgw" {
  description                     = "Transit Gateway testing scenario with 3 VPCs, 2 subnets each"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = {
    Name     = "${var.scenario}-pub"
    scenario = var.scenario
  }
}

# VPC attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-1" {
  subnet_ids                                      = [aws_subnet.vpc-1-sub-a.id, aws_subnet.vpc-1-sub-b.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.test-tgw.id
  vpc_id                                          = aws_vpc.vpc-1.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name     = "tgw-att-vpc1"
    scenario = var.scenario
  }
  depends_on = [aws_ec2_transit_gateway.test-tgw]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-2" {
  subnet_ids                                      = [aws_subnet.vpc-2-sub-a.id, aws_subnet.vpc-2-sub-b.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.test-tgw.id
  vpc_id                                          = aws_vpc.vpc-2.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name     = "tgw-att-vpc2"
    scenario = var.scenario
  }
  depends_on = [aws_ec2_transit_gateway.test-tgw]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-3" {
  subnet_ids                                      = [aws_subnet.vpc-3-priv-sub-a.id, aws_subnet.vpc-3-priv-sub-b.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.test-tgw.id
  vpc_id                                          = aws_vpc.vpc-3.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name     = "tgw-att-vpc3"
    scenario = var.scenario
  }
  depends_on = [aws_ec2_transit_gateway.test-tgw]
}

# Route Tables

resource "aws_ec2_transit_gateway_route_table" "tgw-dev-rt" {
  transit_gateway_id = aws_ec2_transit_gateway.test-tgw.id
  tags = {
    Name     = "tgw-dev-rt"
    scenario = var.scenario
  }
  depends_on = [aws_ec2_transit_gateway.test-tgw]
}

resource "aws_ec2_transit_gateway_route_table" "tgw-shared-rt" {
  transit_gateway_id = aws_ec2_transit_gateway.test-tgw.id
  tags = {
    Name     = "tgw-shared-rt"
    scenario = var.scenario
  }
  depends_on = [aws_ec2_transit_gateway.test-tgw]
}

# Route Tables Associations
## This is the link between a VPC (already symbolized with its attachment to the Transit Gateway)
##  and the Route Table the VPC's packet will hit when they arrive into the Transit Gateway.
## The Route Tables Associations do not represent the actual routes the packets are routed to.
## These are defined in the Route Tables Propagations section below.

resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc-1-assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-dev-rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc-2-assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-dev-rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc-3-assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-3.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-shared-rt.id
}

# Transit GTW Route Tables 
## This section define Routes from TGW Route Table Attchments
resource "aws_ec2_transit_gateway_route" "tgw-rt-vpc-dev-att-vpc-shared" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-dev-rt.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-3.id
}

# Blackhole to make sure VPCs can’t communicate with each other through the NAT gateway.
resource "aws_ec2_transit_gateway_route" "tgw-rt-vpc-dev-att-vpc-shared-black-1" {
  destination_cidr_block         = "192.168.0.0/16"
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-dev-rt.id
}

resource "aws_ec2_transit_gateway_route" "tgw-rt-vpc-dev-att-vpc-shared-black-2" {
  destination_cidr_block         = "172.16.0.0/12"
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-dev-rt.id
}

# resource "aws_ec2_transit_gateway_route" "tgw-rt-vpc-dev-att-vpc-shared-black-3" {
#   destination_cidr_block         = "10.0.0.0/8"
#   blackhole                      = true
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-dev-rt.id
# }

resource "aws_ec2_transit_gateway_route" "tgw-rt-vpc-shared-att-vpc-1" {
  destination_cidr_block         = "10.10.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-shared-rt.id
}

resource "aws_ec2_transit_gateway_route" "tgw-rt-vpc-shared-att-vpc-2" {
  destination_cidr_block         = "10.11.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-shared-rt.id
}
