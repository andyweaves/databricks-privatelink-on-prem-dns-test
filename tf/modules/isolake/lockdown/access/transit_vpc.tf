module "transit_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = "${var.resource_prefix}-transit-vpc"
  cidr = var.transit_vpc_cidr_range
  azs  = var.transit_vpc_availability_zones
  enable_dns_hostnames   = true
  enable_nat_gateway     = false
  single_nat_gateway     = false
  one_nat_gateway_per_az = false
  create_igw             = false

  private_subnets      = var.transit_vpc_private_subnets_cidr
  private_subnet_names = [for az in var.transit_vpc_availability_zones : format("%s-transit-private-%s", var.resource_prefix, az)]
}

// SG
resource "aws_security_group" "transit" {

  vpc_id     = module.transit_vpc.vpc_id
  depends_on = [module.transit_vpc]

  dynamic "ingress" {
    for_each = var.sg_ingress_protocol
    content {
      from_port = 0
      to_port   = 65535
      protocol  = ingress.value
      self      = true
    }
  }

  dynamic "egress" {
    for_each = var.sg_egress_protocol
    content {
      from_port = 0
      to_port   = 65535
      protocol  = egress.value
      self      = true
    }
  }
  tags = {
    Name = "${var.resource_prefix}-transit-sg"
  }
}

resource "aws_security_group_rule" "frontend_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = -1
  cidr_blocks       = [var.frontend_vpc_cidr_range]
  security_group_id = aws_security_group.transit.id
  depends_on = [aws_security_group.transit]
}

resource "aws_security_group_rule" "frontend_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = -1
  cidr_blocks       = [var.frontend_vpc_cidr_range]
  security_group_id = aws_security_group.transit.id
  depends_on = [aws_security_group.transit]
}

resource "aws_route" "transit_to_tgw" {
  count                     = length(module.transit_vpc.private_route_table_ids)
  route_table_id            = module.transit_vpc.private_route_table_ids[count.index]
  destination_cidr_block    = var.frontend_vpc_cidr_range
  transit_gateway_id        = aws_ec2_transit_gateway.tgw.id
  depends_on                = [aws_ec2_transit_gateway.tgw]
}