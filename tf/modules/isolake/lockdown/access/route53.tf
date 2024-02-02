// PHZ
# resource "aws_route53_zone" "private" {
#   name = "cloud.databricks.com"

#     vpc {
#       vpc_id = module.vpc.vpc_id
#         }
#       }

# resource "aws_route53_record" "rest_endpoint" {
#   zone_id    = aws_route53_zone.private.id
#   name       = replace(var.workspace_url, "https://", "")
#   type       = "A"
#   ttl        = "300"
#   records    = data.aws_network_interface.eni.private_ips
#   depends_on = [aws_vpc_endpoint.frontend_rest]
#   }

# resource "aws_route53_record" "dbc_endpoint" {
#   zone_id    = aws_route53_zone.private.id
#   name       = "dbc-dp-${var.workspace_id}.cloud.databricks.com"
#   type       = "CNAME"
#   ttl        = "300"
#   records    = [replace(var.workspace_url, "https://", "")]
#   depends_on = [aws_vpc_endpoint.frontend_rest]
# }

//// ^^^ Remove above when ready

resource "aws_route53_resolver_endpoint" "transit" {
  name      = "${var.resource_prefix}-${var.region}-inbound-resolver"
  direction = "INBOUND"

  security_group_ids = [aws_security_group.transit.id]

  ip_address {
    subnet_id = module.transit_vpc.private_subnets[0]
  }

  ip_address {
    subnet_id = module.transit_vpc.private_subnets[1]
  }

  resolver_endpoint_type = "IPV4"

  protocols = ["DoH", "Do53"]

  tags = {
   Name    = "${var.resource_prefix}-${var.region}-inbound-resolver"
  }
}

data "aws_route53_resolver_endpoint" "transit" {
  resolver_endpoint_id = aws_route53_resolver_endpoint.transit.id
}

resource "aws_route53_zone" "privatelink" {
  name = "${var.region_name}.privatelink.cloud.databricks.com"

    vpc {
      vpc_id = module.transit_vpc.vpc_id
      }
}

resource "aws_route53_record" "region_endpoint" {
  zone_id    = aws_route53_zone.privatelink.id
  name       = "${var.region_name}.privatelink.cloud.databricks.com"
  type       = "A"
  alias {
    name                   = "${lookup(aws_vpc_endpoint.frontend_rest.dns_entry[0], "dns_name")}"
    zone_id                = "${lookup(aws_vpc_endpoint.frontend_rest.dns_entry[0], "hosted_zone_id")}"
    evaluate_target_health = true
  }
  depends_on = [aws_vpc_endpoint.frontend_rest, aws_route53_zone.privatelink]
}