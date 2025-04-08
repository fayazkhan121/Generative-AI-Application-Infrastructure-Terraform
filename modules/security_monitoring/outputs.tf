output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector"
  value       = var.enable_guardduty ? aws_guardduty_detector.genai[0].id : null
}

output "config_recorder_id" {
  description = "The ID of the AWS Config recorder"
  value       = var.enable_config ? aws_config_configuration_recorder.genai[0].id : null
}

output "securityhub_enabled" {
  description = "Whether Security Hub is enabled"
  value       = var.enable_securityhub
}

output "vpc_flow_log_id" {
  description = "The ID of the VPC flow log"
  value       = aws_flow_log.vpc_flow_log.id
}

output "cloudtrail_id" {
  description = "The ID of the CloudTrail trail"
  value       = aws_cloudtrail.genai.id
}

output "cloudtrail_bucket_id" {
  description = "The ID of the CloudTrail S3 bucket"
  value       = aws_s3_bucket.cloudtrail.id
}

output "secrets_rotation_lambda_arn" {
  description = "The ARN of the secrets rotation Lambda function"
  value       = aws_lambda_function.secrets_rotation_lambda.arn
}