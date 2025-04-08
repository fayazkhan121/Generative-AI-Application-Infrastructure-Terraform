variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, production)"
  type        = string
}

variable "postgres_host" {
  description = "PostgreSQL host"
  type        = string
}

variable "postgres_port" {
  description = "PostgreSQL port"
  type        = number
}

variable "postgres_db_name" {
  description = "PostgreSQL database name"
  type        = string
}

variable "postgres_username" {
  description = "PostgreSQL username"
  type        = string
}

variable "postgres_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "postgres_secret_name" {
  description = "PostgreSQL secret name"
  type        = string
}

variable "msk_bootstrap_servers" {
  description = "MSK bootstrap servers"
  type        = string
}

variable "prometheus_endpoint" {
  description = "AWS Managed Prometheus endpoint"
  type        = string
}

variable "service_account_role_arn" {
  description = "IAM role ARN for service account"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "private_subnets" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "api_gateway_id" {
  description = "API Gateway ID"
  type        = string
}

variable "enable_service_mesh" {
  description = "Whether to enable service mesh"
  type        = bool
  default     = true
}

variable "enable_gpu_operator" {
  description = "Whether to enable NVIDIA GPU Operator"
  type        = bool
  default     = true
}

variable "enable_external_dns" {
  description = "Whether to enable External DNS"
  type        = bool
  default     = true
}

variable "enable_cert_manager" {
  description = "Whether to enable cert-manager"
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

variable "domain_certificate_arn" {
  description = "ARN of the domain certificate"
  type        = string
  default     = ""
}

variable "aws_load_balancer_controller_enabled" {
  description = "Whether to enable AWS Load Balancer Controller"
  type        = bool
  default     = true
}