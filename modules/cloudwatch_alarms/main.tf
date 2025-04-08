# EKS Cluster Alarms
resource "aws_cloudwatch_metric_alarm" "eks_cluster_node_cpu" {
  alarm_name          = "genai-eks-${var.cluster_name}-node-cpu-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "node_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm monitors EKS node CPU utilization"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  
  dimensions = {
    ClusterName = var.cluster_name
  }
  
  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "eks_cluster_node_memory" {
  alarm_name          = "genai-eks-${var.cluster_name}-node-memory-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "node_memory_utilization"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm monitors EKS node memory utilization"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  
  dimensions = {
    ClusterName = var.cluster_name
  }
  
  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "eks_cluster_node_disk" {
  alarm_name          = "genai-eks-${var.cluster_name}-node-disk-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "node_filesystem_utilization"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm monitors EKS node disk utilization"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  
  dimensions = {
    ClusterName = var.cluster_name
  }
  
  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "eks_pod_restarts" {
  alarm_name          = "genai-eks-${var.cluster_name}-pod-restarts-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "pod_number_of_container_restarts"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "This alarm monitors EKS pod restarts"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  
  dimensions = {
    ClusterName = var.cluster_name
    Namespace   = "genai-app"
  }
  
  tags = {
    Environment = var.environment
  }
}

# RDS Alarms
resource "aws_cloudwatch_metric_alarm" "rds_cpu_utilization" {
  alarm_name          = "genai-rds-${var.rds_instance_id}-cpu-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm monitors RDS CPU utilization"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  
  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }
  
  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_freeable_memory" {
  alarm_name          = "genai-rds-${var.rds_instance_id}-memory-${var.environment}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 1073741824  # 1 GB
  alarm_description   = "This alarm monitors RDS freeable memory"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  
  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }
  
  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_storage_space" {
  alarm_name          = "genai-rds-${var.rds_instance_id}-storage-${var.environment}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 10737418240  # 10 GB
  alarm_description   = "This alarm monitors RDS free storage space"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  
  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }
  
  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_connections" {
  alarm_name          = "genai-rds-${var.rds_instance_id}-connections-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 100  # Adjust based on your instance type
  alarm_description   = "This alarm monitors RDS database connections"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  
  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }
  
  tags = {
    Environment = var.environment
  }
}

# MSK Alarms
resource "aws_cloudwatch_metric_alarm" "msk_cpu_utilization" {
  alarm_name          = "genai-msk-${var.msk_cluster_name}-cpu-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CpuUser"
  namespace           = "AWS/Kafka"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm monitors MSK CPU utilization"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  
  dimensions = {
    Cluster = var.msk_cluster_name
  }
  
  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "msk_disk_utilization" {
  alarm_name          = "genai-msk-${var.msk_cluster_name}-disk-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "KafkaDataLogsDiskUsed"
  namespace           = "AWS/Kafka"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm monitors MSK disk utilization"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  
  dimensions = {
    Cluster = var.msk_cluster_name
  }
  
  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "msk_memory_utilization" {
  alarm_name          = "genai-msk-${var.msk_cluster_name}-memory-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUsed"
  namespace           = "AWS/Kafka"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm monitors MSK memory utilization"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  
  dimensions = {
    Cluster = var.msk_cluster_name
  }
  
  tags = {
    Environment = var.environment
  }
}

# API Gateway Alarms
resource "aws_cloudwatch_metric_alarm" "api_gateway_5xx_errors" {
  alarm_name          = "genai-api-gateway-${var.api_gateway_name}-5xx-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "5xxError"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "This alarm monitors API Gateway 5XX errors"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  
  dimensions = {
    ApiName = var.api_gateway_name
  }
  
  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "api_gateway_4xx_errors" {
  alarm_name          = "genai-api-gateway-${var.api_gateway_name}-4xx-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "4xxError"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = 20
  alarm_description   = "This alarm monitors API Gateway 4XX errors"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  
  dimensions = {
    ApiName = var.api_gateway_name
  }
  
  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "api_gateway_latency" {
  alarm_name          = "genai-api-gateway-${var.api_gateway_name}-latency-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Latency"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Average"
  threshold           = 1000  # 1 second
  alarm_description   = "This alarm monitors API Gateway latency"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  
  dimensions = {
    ApiName = var.api_gateway_name
  }
  
  tags = {
    Environment = var.environment
  }
}

# CloudFront Alarms
resource "aws_cloudwatch_metric_alarm" "cloudfront_5xx_errors" {
  alarm_name          = "genai-cloudfront-${var.cloudfront_distro}-5xx-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "5xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = 300
  statistic           = "Average"
  threshold           = 5
  alarm_description   = "This alarm monitors CloudFront 5XX errors"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  
  dimensions = {
    DistributionId = var.cloudfront_distro
    Region         = "Global"
  }
  
  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "cloudfront_4xx_errors" {
  alarm_name          = "genai-cloudfront-${var.cloudfront_distro}-4xx-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "4xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = 300
  statistic           = "Average"
  threshold           = 20
  alarm_description   = "This alarm monitors CloudFront 4XX errors"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  
  dimensions = {
    DistributionId = var.cloudfront_distro
    Region         = "Global"
  }
  
  tags = {
    Environment = var.environment
  }
}

# SNS Topic for Alarms
resource "aws_sns_topic" "alarms" {
  name = "genai-alarms-${var.environment}"
  
  tags = {
    Environment = var.environment
  }
}

# Example SNS Topic Subscription (Email)
resource "aws_sns_topic_subscription" "alarms_email" {
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alarms_email
}