# General
aws_region  = "us-west-2"
environment = "dev"
domain_name = "genai-app.example.com"

# VPC Configuration
vpc_cidr = "10.0.0.0/16"
availability_zones = [
  "us-west-2a",
  "us-west-2b",
  "us-west-2c"
]
private_subnets = [
  "10.0.1.0/24",
  "10.0.2.0/24",
  "10.0.3.0/24"
]
public_subnets = [
  "10.0.101.0/24",
  "10.0.102.0/24",
  "10.0.103.0/24"
]
database_subnets = [
  "10.0.201.0/24",
  "10.0.202.0/24",
  "10.0.203.0/24"
]
bastion_enabled = true
bastion_cidr    = ["10.0.0.0/16"]  # Restrict to your organization's IP range in production

# EKS Configuration
kubernetes_version = "1.24"

# General node group
general_node_group_min_size     = 2
general_node_group_max_size     = 5
general_node_group_desired_size = 2
general_node_group_instance_types = [
  "m5.large",
  "m5a.large",
  "m5d.large"
]

# Memory-optimized node group
memory_node_group_min_size     = 1
memory_node_group_max_size     = 3
memory_node_group_desired_size = 1
memory_node_group_instance_types = [
  "r5.large",
  "r5a.large",
  "r5d.large"
]

# GPU node group
gpu_node_group_min_size     = 1
gpu_node_group_max_size     = 3
gpu_node_group_desired_size = 1
gpu_node_group_instance_types = [
  "g4dn.xlarge",
  "g4dn.2xlarge"
]

# PostgreSQL Configuration
postgres_version               = "13.7"
postgres_instance_class        = "db.r5.large"
postgres_allocated_storage     = 100
postgres_max_allocated_storage = 500
postgres_db_name               = "genaidb"
postgres_username              = "postgres"
postgres_password              = "CHANGE_ME_IN_PRODUCTION"  # Use environment variables or AWS SSM Parameter Store in production
postgres_port                  = 5432
postgres_backup_retention_period = 7

# MSK Configuration
msk_instance_type        = "kafka.m5.large"
msk_scaling_max_capacity = 1000
msk_log_retention_hours  = 168  # 7 days
cassandra_ports          = [9042, 9142]

# API Gateway Configuration
api_domain_name      = "api.genai-app.example.com"
api_certificate_arn  = ""  # Replace with your certificate ARN

# CloudFront Configuration
cloudfront_certificate_arn = ""  # Replace with your certificate ARN

# Feature Flags
enable_service_mesh  = true
enable_external_dns  = true
enable_cert_manager  = true
enable_guardduty     = true
enable_config        = true
enable_securityhub   = true