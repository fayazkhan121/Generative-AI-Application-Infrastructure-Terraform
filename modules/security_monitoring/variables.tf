variable "environment" {
  description = "Environment (dev, staging, production)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "s3_web_bucket_id" {
  description = "ID of the S3 bucket for web content"
  type        = string
}

variable "secret_ids" {
  description = "List of secret IDs to rotate"
  type        = list(string)
}

variable "enable_guardduty" {
  description = "Whether to enable GuardDuty"
  type        = bool
  default     = true
}

variable "enable_config" {
  description = "Whether to enable AWS Config"
  type        = bool
  default     = true
}

variable "enable_securityhub" {
  description = "Whether to enable Security Hub"
  type        = bool
  default     = true
}