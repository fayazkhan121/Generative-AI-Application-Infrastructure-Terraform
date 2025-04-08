output "web_sg_id" {
  description = "Security group ID for web application"
  value       = aws_security_group.web.id
}

output "postgres_sg_id" {
  description = "Security group ID for PostgreSQL"
  value       = aws_security_group.postgres.id
}

output "msk_sg_id" {
  description = "Security group ID for MSK (Kafka)"
  value       = aws_security_group.msk.id
}

output "eks_nodes_sg_id" {
  description = "Security group ID for EKS nodes"
  value       = aws_security_group.eks_nodes.id
}

output "bastion_sg_id" {
  description = "Security group ID for bastion host"
  value       = var.bastion_enabled ? aws_security_group.bastion[0].id : ""
}