// Databricks REST API endpoint
resource "aws_vpc_endpoint" "frontend_rest" {
  #vpc_id             = module.vpc.vpc_id
  vpc_id             = module.transit_vpc.vpc_id
  service_name       = var.workspace_vpce_service
  vpc_endpoint_type  = "Interface"
  #security_group_ids = [aws_security_group.frontend.id]
  security_group_ids = [aws_security_group.transit.id]
  #subnet_ids = module.vpc.private_subnets
  subnet_ids = module.transit_vpc.private_subnets
  #private_dns_enabled = true
  private_dns_enabled = false
  #depends_on          = [module.vpc.vpc_id]
  depends_on          = [module.transit_vpc.vpc_id]
  tags = {
    Name = "${var.resource_prefix}-databricks-frontend-rest"
  }
}

data "aws_network_interface" "eni" {
  depends_on = [aws_vpc_endpoint.frontend_rest]
  id         = tolist(aws_vpc_endpoint.frontend_rest.network_interface_ids)[0]
}