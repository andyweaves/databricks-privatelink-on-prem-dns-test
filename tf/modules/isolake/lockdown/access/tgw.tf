resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "Transit Gateway"
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = {
    Name = "${var.resource_prefix}-${var.region}-tgw"
  }
}

// Attach Transit VPC to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "transit_attachment" {
  subnet_ids         = module.transit_vpc.private_subnets[*]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = module.transit_vpc.vpc_id
  dns_support        = "enable"

  tags = {
    Name    = "${var.resource_prefix}-${var.region}-transit-vpc"
    Purpose = "Transit VPC TGW Attachment"
  }
}

# //# Attach Frontend VPC to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "frontend_attachment" {
  subnet_ids         = module.vpc.public_subnets[*] 
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = module.vpc.vpc_id
  dns_support        = "enable"

  tags = {
    Name    = "${var.resource_prefix}-${var.region}-frontend-vpc"
    Purpose = "Front End VPC TGW Attachment"
  }
}

resource "aws_ec2_transit_gateway_route_table" "transit" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_ec2_transit_gateway_route_table" "frontend" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_ec2_transit_gateway_route_table_association" "transit" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.transit.id
}

resource "aws_ec2_transit_gateway_route_table_association" "frontend" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.frontend_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.frontend.id
}

resource "aws_ec2_transit_gateway_route" "to_frontend" {
  destination_cidr_block         = var.frontend_vpc_cidr_range
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.frontend_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.transit.id
}

resource "aws_ec2_transit_gateway_route" "to_transit" {
  destination_cidr_block         = var.transit_vpc_cidr_range 
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.frontend.id
}