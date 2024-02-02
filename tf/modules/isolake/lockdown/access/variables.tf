variable "resource_prefix" {
  type = string
}

variable "region" {
  type = string
}

variable "region_name" {
  type = string
}

variable "databricks_account_id" {
  type = string
}

variable "frontend_vpc_cidr_range" {
  type = string
}

variable "frontend_private_subnets_cidr" {
  type = list(string)
}

variable "frontend_public_subnets_cidr" {
  type = list(string)
}

variable "frontend_availability_zones" {
  type = list(string)
}

variable "workspace_url" {
  type = string
}

variable "workspace_id" {
  type = string
}

variable "workspace_vpce_service" {
  type = string
}

variable "sg_egress_protocol" {
  type = list(string)
}

variable "sg_ingress_protocol" {
  type = list(string)
}

variable "credential_configuration" {
  type = string
}

variable "storage_configuration" {
  type = string
}

variable "network_configuration" {
  type = string
}

variable "managed_services_customer_managed_key_id" {
  type = string
}

variable "storage_customer_managed_key_id" {
  type = string
}

variable "rdp_public_ip" {
  type = string
}

variable "transit_vpc_cidr_range" {

  type = string
}

variable "transit_vpc_private_subnets_cidr" {

  type = list(string)
}

variable "transit_vpc_availability_zones" {

  type = list(string)
}

variable "ec2_keypair_name" {

  type = string
}