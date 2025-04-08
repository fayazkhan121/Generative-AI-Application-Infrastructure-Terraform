output "alarms_sns_topic_arn" {
  description = "ARN of the SNS topic for alarms"
  value       = aws_sns_topic.alarms.arn
}

output "eks_cpu_alarm_arn" {
  description = "ARN of the EKS CPU alarm"
  value       = aws_cloudwatch_metric_alarm.eks_cluster_node_cpu.arn
}

output "eks_memory_alarm_arn" {
  description = "ARN of the EKS memory alarm"
  value       = aws_cloudwatch_metric_alarm.eks_cluster_node_memory.arn
}

output "eks_disk_alarm_arn" {
  description = "ARN of the EKS disk alarm"
  value       = aws_cloudwatch_metric_alarm.eks_cluster_node_disk.arn
}

output "rds_cpu_alarm_arn" {
  description = "ARN of the RDS CPU alarm"
  value       = aws_cloudwatch_metric_alarm.rds_cpu_utilization.arn
}

output "rds_memory_alarm_arn" {
  description = "ARN of the RDS memory alarm"
  value       = aws_cloudwatch_metric_alarm.rds_freeable_memory.arn
}

output "rds_storage_alarm_arn" {
  description = "ARN of the RDS storage alarm"
  value       = aws_cloudwatch_metric_alarm.rds_storage_space.arn
}

output "msk_cpu_alarm_arn" {
  description = "ARN of the MSK CPU alarm"
  value       = aws_cloudwatch_metric_alarm.msk_cpu_utilization.arn
}

output "msk_disk_alarm_arn" {
  description = "ARN of the MSK disk alarm"
  value       = aws_cloudwatch_metric_alarm.msk_disk_utilization.arn
}

output "api_gateway_5xx_alarm_arn" {
  description = "ARN of the API Gateway 5XX alarm"
  value       = aws_cloudwatch_metric_alarm.api_gateway_5xx_errors.arn
}

output "cloudfront_5xx_alarm_arn" {
  description = "ARN of the CloudFront 5XX alarm"
  value       = aws_cloudwatch_metric_alarm.cloudfront_5xx_errors.arn
}