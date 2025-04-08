variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, production)"
  type        = string
}

variable "postgres_port" {
  description = "PostgreSQL port"
  type        = number
  default     = 5432
}

variable "cassandra_ports" {
  description = "Ports for Cassandra access"
  type        = list(number)
  default     = [9042, 9142]
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "bastion_enabled" {
  description = "Whether to create a bastion host security group"
  type        = bool
  default     = true
}

variable "bastion_cidr" {
  description = "CIDR blocks for bastion access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}