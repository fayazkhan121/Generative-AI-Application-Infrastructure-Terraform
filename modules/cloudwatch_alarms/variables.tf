variable "environment" {
  description = "Environment (dev, staging, production)"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "rds_instance_id" {
  description = "RDS instance ID"
  type        = string
}

variable "msk_cluster_name" {
  description = "MSK cluster name"
  type        = string
}

variable "api_gateway_name" {
  description = "API Gateway name"
  type        = string
}

variable "cloudfront_distro" {
  description = "CloudFront distribution ID"
  type        = string
}

variable "alarms_email" {
  description = "Email address for alarm notifications"
  type        = string
  default     = "alerts@example.com"
}