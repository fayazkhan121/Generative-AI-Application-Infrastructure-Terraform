# General
variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment (dev, staging, production)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Valid values for environment are: dev, staging, production."
  }
}

variable "domain_name" {
  description = "Base domain name for the application"
  type        = string
  default     = "genai-app.example.com"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "database_subnets" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
  default     = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]
}

# Bastion Host
variable "bastion_enabled" {
  description = "Whether to create a bastion host"
  type        = bool
  default     = true
}

variable "bastion_cidr" {
  description = "CIDR block for bastion host access"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # In production, restrict to specific IPs
}

# EKS Configuration
variable "kubernetes_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.24"
}

variable "general_node_group_min_size" {
  description = "Minimum size for general purpose node group"
  type        = number
  default     = 2
}

variable "general_node_group_max_size" {
  description = "Maximum size for general purpose node group"
  type        = number
  default     = 5
}

variable "general_node_group_desired_size" {
  description = "Desired size for general purpose node group"
  type        = number
  default     = 2
}

variable "general_node_group_instance_types" {
  description = "Instance types for general purpose node group"
  type        = list(string)
  default     = ["m5.large", "m5a.large", "m5d.large"]
}

variable "memory_node_group_min_size" {
  description = "Minimum size for memory-optimized node group"
  type        = number
  default     = 1
}

variable "memory_node_group_max_size" {
  description = "Maximum size for memory-optimized node group"
  type        = number
  default     = 5
}

variable "memory_node_group_desired_size" {
  description = "Desired size for memory-optimized node group"
  type        = number
  default     = 1
}

variable "memory_node_group_instance_types" {
  description = "Instance types for memory-optimized node group"
  type        = list(string)
  default     = ["r5.large", "r5a.large", "r5d.large"]
}

variable "gpu_node_group_min_size" {
  description = "Minimum size for GPU node group"
  type        = number
  default     = 1
}

variable "gpu_node_group_max_size" {
  description = "Maximum size for GPU node group"
  type        = number
  default     = 5
}

variable "gpu_node_group_desired_size" {
  description = "Desired size for GPU node group"
  type        = number
  default     = 1
}

variable "gpu_node_group_instance_types" {
  description = "Instance types for GPU node group"
  type        = list(string)
  default     = ["g4dn.xlarge", "g4dn.2xlarge", "p3.2xlarge"]
}

# PostgreSQL Configuration
variable "postgres_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "13.7"
}

variable "postgres_instance_class" {
  description = "PostgreSQL instance class"
  type        = string
  default     = "db.r5.large"
}

variable "postgres_allocated_storage" {
  description = "Allocated storage for PostgreSQL (in GB)"
  type        = number
  default     = 100
}

variable "postgres_max_allocated_storage" {
  description = "Maximum allocated storage for PostgreSQL (in GB)"
  type        = number
  default     = 500
}

variable "postgres_db_name" {
  description = "Name of the PostgreSQL database"
  type        = string
  default     = "genaidb"
}

variable "postgres_username" {
  description = "PostgreSQL master username"
  type        = string
  default     = "postgres"
}

variable "postgres_password" {
  description = "PostgreSQL master password"
  type        = string
  sensitive   = true
}

variable "postgres_port" {
  description = "PostgreSQL port"
  type        = number
  default     = 5432
}

variable "postgres_backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

# MSK Configuration (for timeseries data, used instead of Cassandra)
variable "msk_instance_type" {
  description = "Instance type for MSK brokers"
  type        = string
  default     = "kafka.m5.large"
}

variable "msk_scaling_max_capacity" {
  description = "Maximum storage capacity for MSK brokers (in GB)"
  type        = number
  default     = 1000
}

variable "msk_log_retention_hours" {
  description = "Log retention period in hours"
  type        = number
  default     = 168  # 7 days
}

variable "cassandra_ports" {
  description = "Ports for Cassandra access"
  type        = list(number)
  default     = [9042, 9142]  # Default and SSL ports
}

# API Gateway Configuration
variable "api_domain_name" {
  description = "Domain name for API Gateway"
  type        = string
  default     = "api.genai-app.example.com"
}

variable "api_certificate_arn" {
  description = "ARN of ACM certificate for API Gateway"
  type        = string
  default     = ""
}

# CloudFront Configuration
variable "cloudfront_certificate_arn" {
  description = "ARN of ACM certificate for CloudFront"
  type        = string
  default     = ""
}

# Feature Flags
variable "enable_service_mesh" {
  description = "Enable Service Mesh (Istio)"
  type        = bool
  default     = true
}

variable "enable_external_dns" {
  description = "Enable ExternalDNS controller"
  type        = bool
  default     = true
}

variable "enable_cert_manager" {
  description = "Enable cert-manager"
  type        = bool
  default     = true
}

variable "enable_guardduty" {
  description = "Enable GuardDuty for threat detection"
  type        = bool
  default     = true
}

variable "enable_config" {
  description = "Enable AWS Config for compliance monitoring"
  type        = bool
  default     = true
}

variable "enable_securityhub" {
  description = "Enable Security Hub for security findings"
  type        = bool
  default     = true
}