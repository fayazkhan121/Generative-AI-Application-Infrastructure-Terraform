output "eks_node_role_arn" {
  description = "ARN of the IAM role for EKS nodes"
  value       = aws_iam_role.eks_node_role.arn
}

output "eks_service_account_role_arn" {
  description = "ARN of the IAM role for EKS service accounts"
  value       = aws_iam_role.eks_service_account_role.arn
}

output "postgres_secrets_policy_arn" {
  description = "ARN of the IAM policy for PostgreSQL secrets access"
  value       = aws_iam_policy.postgres_secrets_access.arn
}

output "msk_access_policy_arn" {
  description = "ARN of the IAM policy for MSK (Kafka) access"
  value       = aws_iam_policy.msk_access.arn
}

output "s3_web_access_policy_arn" {
  description = "ARN of the IAM policy for S3 web bucket access"
  value       = aws_iam_policy.s3_web_access.arn
}

output "cloudwatch_logs_policy_arn" {
  description = "ARN of the IAM policy for CloudWatch logs access"
  value       = aws_iam_policy.cloudwatch_logs.arn
}

output "aws_load_balancer_controller_policy_arn" {
  description = "ARN of the IAM policy for AWS Load Balancer Controller"
  value       = aws_iam_policy.aws_load_balancer_controller.arn
}

output "external_dns_policy_arn" {
  description = "ARN of the IAM policy for External DNS"
  value       = aws_iam_policy.external_dns.arn
}