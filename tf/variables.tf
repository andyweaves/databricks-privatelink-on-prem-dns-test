variable "aws_account_id" {
  description = "AWS account ID for integration"
  type        = string
}

variable "client_id" {
  description = "Databricks client ID for OAuth"
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "Databricks client secret for OAuth"
  type        = string
  sensitive   = true
}

variable "databricks_account_id" {
  description = "Databricks account ID"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "AWS region for resource deployment"
  type        = string
}

variable "resource_owner" {
  description = "Owner of the resources for tracking and management"
  type        = string
}

variable "resource_prefix" {
  description = "Prefix for naming created resources"
  type        = string
}

variable ec2_keypair_name {

  description = "Keypair to use to connect to EC2 instances"
  type        = string
}

variable rdp_public_ip {

  description = "Public IP to allow list for RDP access"
  type        = string
}