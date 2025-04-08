# GuardDuty
resource "aws_guardduty_detector" "genai" {
  count = var.enable_guardduty ? 1 : 0
  
  enable                       = true
  finding_publishing_frequency = "SIX_HOURS"
  
  tags = {
    Environment = var.environment
    Name        = "genai-guardduty-${var.environment}"
  }
}

# AWS Config
resource "aws_config_configuration_recorder" "genai" {
  count = var.enable_config ? 1 : 0
  
  name     = "genai-config-recorder-${var.environment}"
  role_arn = aws_iam_role.config_role[0].arn
  
  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_configuration_recorder_status" "genai" {
  count = var.enable_config ? 1 : 0
  
  name       = aws_config_configuration_recorder.genai[0].name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.genai]
}

resource "aws_config_delivery_channel" "genai" {
  count = var.enable_config ? 1 : 0
  
  name           = "genai-config-delivery-channel-${var.environment}"
  s3_bucket_name = aws_s3_bucket.config_logs[0].bucket
  depends_on     = [aws_config_configuration_recorder.genai]
}

resource "aws_s3_bucket" "config_logs" {
  count = var.enable_config ? 1 : 0
  
  bucket = "genai-config-logs-${var.environment}-${random_id.suffix[0].hex}"
  
  tags = {
    Environment = var.environment
    Name        = "genai-config-logs-${var.environment}"
  }
}

resource "aws_s3_bucket_policy" "config_logs" {
  count = var.enable_config ? 1 : 0
  
  bucket = aws_s3_bucket.config_logs[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSConfigBucketPermissionsCheck"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = "arn:aws:s3:::${aws_s3_bucket.config_logs[0].bucket}"
      },
      {
        Sid    = "AWSConfigBucketDelivery"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.config_logs[0].bucket}/AWSLogs/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "config_role" {
  count = var.enable_config ? 1 : 0
  
  name = "genai-config-role-${var.environment}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })
  
  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "config_role_policy" {
  count = var.enable_config ? 1 : 0
  
  role       = aws_iam_role.config_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

# SecurityHub
resource "aws_securityhub_account" "genai" {
  count = var.enable_securityhub ? 1 : 0
}

# Enable SecurityHub standards
resource "aws_securityhub_standards_subscription" "cis_aws_foundations" {
  count = var.enable_securityhub ? 1 : 0
  
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
  depends_on    = [aws_securityhub_account.genai]
}

resource "aws_securityhub_standards_subscription" "aws_foundational_security_best_practices" {
  count = var.enable_securityhub ? 1 : 0
  
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.name}::standards/aws-foundational-security-best-practices/v/1.0.0"
  depends_on    = [aws_securityhub_account.genai]
}

# VPC Flow Logs
resource "aws_flow_log" "vpc_flow_log" {
  log_destination      = aws_cloudwatch_log_group.flow_log.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = var.vpc_id
  iam_role_arn         = aws_iam_role.vpc_flow_log_role.arn
  
  tags = {
    Environment = var.environment
    Name        = "genai-vpc-flow-log-${var.environment}"
  }
}

resource "aws_cloudwatch_log_group" "flow_log" {
  name              = "/aws/vpc/flowlogs/genai-vpc-${var.environment}"
  retention_in_days = 90
  
  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role" "vpc_flow_log_role" {
  name = "genai-vpc-flow-log-role-${var.environment}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
  
  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "vpc_flow_log_policy" {
  name = "genai-vpc-flow-log-policy-${var.environment}"
  role = aws_iam_role.vpc_flow_log_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# CloudTrail
resource "aws_cloudtrail" "genai" {
  name                          = "genai-cloudtrail-${var.environment}"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  
  event_selector {
    read_write_type           = "All"
    include_management_events = true
    
    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::${var.s3_web_bucket_id}/"]
    }
    
    data_resource {
      type   = "AWS::Lambda::Function"
      values = ["arn:aws:lambda:::function:*"]
    }
  }
  
  tags = {
    Environment = var.environment
    Name        = "genai-cloudtrail-${var.environment}"
  }
}

resource "aws_s3_bucket" "cloudtrail" {
  bucket = "genai-cloudtrail-${var.environment}-${random_id.cloudtrail_suffix.hex}"
  
  tags = {
    Environment = var.environment
    Name        = "genai-cloudtrail-${var.environment}"
  }
}

resource "random_id" "cloudtrail_suffix" {
  byte_length = 4
}

resource "random_id" "suffix" {
  count       = var.enable_config ? 1 : 0
  byte_length = 4
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = "arn:aws:s3:::${aws_s3_bucket.cloudtrail.bucket}"
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.cloudtrail.bucket}/AWSLogs/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# AWS Secrets rotation
resource "aws_secretsmanager_secret_rotation" "postgres_credentials_rotation" {
  count = length(var.secret_ids)
  
  secret_id           = var.secret_ids[count.index]
  rotation_lambda_arn = aws_lambda_function.secrets_rotation_lambda.arn
  
  rotation_rules {
    automatically_after_days = 30
  }
}

# Lambda function for secrets rotation
resource "aws_lambda_function" "secrets_rotation_lambda" {
  function_name    = "genai-secrets-rotation-${var.environment}"
  filename         = "${path.module}/functions/secrets_rotation.zip"
  source_code_hash = filebase64sha256("${path.module}/functions/secrets_rotation.zip")
  handler          = "index.handler"
  role             = aws_iam_role.secrets_rotation_lambda_role.arn
  runtime          = "nodejs16.x"
  timeout          = 60
  
  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }
  
  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role" "secrets_rotation_lambda_role" {
  name = "genai-secrets-rotation-lambda-role-${var.environment}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  
  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "secrets_rotation_lambda_policy" {
  name = "genai-secrets-rotation-lambda-policy-${var.environment}"
  role = aws_iam_role.secrets_rotation_lambda_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecretVersionStage"
        ]
        Effect   = "Allow"
        Resource = var.secret_ids
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = [
          "rds:ModifyDBInstance"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Security Group monitoring
resource "aws_config_config_rule" "security_group_rules" {
  count = var.enable_config ? 1 : 0
  
  name        = "genai-restricted-ssh-${var.environment}"
  description = "Checks whether security groups that are in use disallow unrestricted SSH access"
  
  source {
    owner             = "AWS"
    source_identifier = "INCOMING_SSH_DISABLED"
  }
  
  depends_on = [aws_config_configuration_recorder.genai]
}

resource "aws_config_config_rule" "restricted_common_ports" {
  count = var.enable_config ? 1 : 0
  
  name        = "genai-restricted-common-ports-${var.environment}"
  description = "Checks whether security groups that are in use disallow unrestricted access to common ports"
  
  source {
    owner             = "AWS"
    source_identifier = "RESTRICTED_INCOMING_TRAFFIC"
  }
  
  depends_on = [aws_config_configuration_recorder.genai]
}

# EKS security monitoring
resource "aws_config_config_rule" "eks_endpoint_access" {
  count = var.enable_config ? 1 : 0
  
  name        = "genai-eks-endpoint-access-${var.environment}"
  description = "Checks whether Amazon EKS endpoint is not publicly accessible"
  
  source {
    owner             = "AWS"
    source_identifier = "EKS_ENDPOINT_NO_PUBLIC_ACCESS"
  }
  
  depends_on = [aws_config_configuration_recorder.genai]
}

resource "aws_config_config_rule" "eks_secrets_encrypted" {
  count = var.enable_config ? 1 : 0
  
  name        = "genai-eks-secrets-encrypted-${var.environment}"
  description = "Checks whether Amazon EKS clusters are configured to have Kubernetes secrets encrypted using AWS KMS"
  
  source {
    owner             = "AWS"
    source_identifier = "EKS_SECRETS_ENCRYPTED"
  }
  
  depends_on = [aws_config_configuration_recorder.genai]
}

# S3 bucket security monitoring
resource "aws_config_config_rule" "s3_bucket_public_access" {
  count = var.enable_config ? 1 : 0
  
  name        = "genai-s3-bucket-public-write-prohibited-${var.environment}"
  description = "Checks that your S3 buckets do not allow public write access"
  
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
  }
  
  depends_on = [aws_config_configuration_recorder.genai]
}

resource "aws_config_config_rule" "s3_bucket_ssl_requests" {
  count = var.enable_config ? 1 : 0
  
  name        = "genai-s3-bucket-ssl-requests-only-${var.environment}"
  description = "Checks whether S3 buckets have policies that require SSL"
  
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SSL_REQUESTS_ONLY"
  }
  
  depends_on = [aws_config_configuration_recorder.genai]
}

resource "aws_config_config_rule" "s3_bucket_encrypted" {
  count = var.enable_config ? 1 : 0
  
  name        = "genai-s3-default-encryption-${var.environment}"
  description = "Checks whether the S3 buckets have default encryption enabled"
  
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }
  
  depends_on = [aws_config_configuration_recorder.genai]
}

# Current AWS Region data source
data "aws_region" "current" {}