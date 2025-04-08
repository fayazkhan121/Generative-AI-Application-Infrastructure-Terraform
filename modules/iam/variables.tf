variable "environment" {
  description = "Environment (dev, staging, production)"
  type        = string
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "eks_oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL) for the EKS cluster"
  type        = string
}

variable "postgres_instance" {
  description = "PostgreSQL instance ID"
  type        = string
}

variable "s3_web_bucket_name" {
  description = "Name of the S3 bucket for web content"
  type        = string
}

variable "msk_cluster_arn" {
  description = "ARN of the MSK (Kafka) cluster"
  type        = string
}