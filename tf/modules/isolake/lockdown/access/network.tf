module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = "${var.resource_prefix}-frontend-vpc"
  cidr = var.frontend_vpc_cidr_range
  azs  = var.frontend_availability_zones
  enable_dns_hostnames   = true
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  create_igw             = true

  private_subnets      = var.frontend_private_subnets_cidr
  private_subnet_names = [for az in var.frontend_availability_zones : format("%s-frontend-private-%s", var.resource_prefix, az)]
  public_subnets      = var.frontend_public_subnets_cidr
  public_subnet_names = [for az in var.frontend_availability_zones : format("%s-frontend-public-%s", var.resource_prefix, az)]
}

// SG
resource "aws_security_group" "frontend" {

  vpc_id     = module.vpc.vpc_id
  depends_on = [module.vpc]

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
  egress {
    from_port        = 3389
    to_port          = 3389
    protocol         = "tcp"
    cidr_blocks      = [var.rdp_public_ip]
  }
  egress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.rdp_public_ip]
  }
  egress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 53
    to_port          = 53
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 53
    to_port          = 53
    protocol         = "udp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol = "tcp"
    cidr_blocks   = [var.rdp_public_ip]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol = "tcp"
    cidr_blocks   = [var.rdp_public_ip]
  }

  tags = {
    Name = "${var.resource_prefix}-frontend-sg"
  }
}

resource "aws_security_group_rule" "transit_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = -1
  cidr_blocks       = [var.transit_vpc_cidr_range]
  security_group_id = aws_security_group.frontend.id
  depends_on = [aws_security_group.frontend]
}

resource "aws_security_group_rule" "transit_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = -1
  cidr_blocks       = [var.transit_vpc_cidr_range]
  security_group_id = aws_security_group.frontend.id
  depends_on = [aws_security_group.frontend]
}

resource "aws_route" "frontend_private_to_tgw" {
  route_table_id            = module.vpc.private_route_table_ids[0]
  destination_cidr_block    = var.transit_vpc_cidr_range
  transit_gateway_id        = aws_ec2_transit_gateway.tgw.id
  depends_on                = [aws_ec2_transit_gateway.tgw]
}

resource "aws_route" "frontend_public_to_tgw" {
  route_table_id            = module.vpc.public_route_table_ids[0]
  destination_cidr_block    = var.transit_vpc_cidr_range
  transit_gateway_id        = aws_ec2_transit_gateway.tgw.id
  depends_on                = [aws_ec2_transit_gateway.tgw]
}