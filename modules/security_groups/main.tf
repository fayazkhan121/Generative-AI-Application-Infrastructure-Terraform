# Web Application Security Group
resource "aws_security_group" "web" {
  name        = "genai-web-${var.environment}"
  description = "Security group for web application"
  vpc_id      = var.vpc_id
  
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTP (redirect to HTTPS)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "genai-web-${var.environment}"
    Environment = var.environment
  }
}

# PostgreSQL Security Group
resource "aws_security_group" "postgres" {
  name        = "genai-postgres-${var.environment}"
  description = "Security group for PostgreSQL"
  vpc_id      = var.vpc_id
  
  ingress {
    description     = "PostgreSQL from EKS"
    from_port       = var.postgres_port
    to_port         = var.postgres_port
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
  }
  
  ingress {
    description     = "PostgreSQL from Bastion"
    from_port       = var.postgres_port
    to_port         = var.postgres_port
    protocol        = "tcp"
    security_groups = var.bastion_enabled ? [aws_security_group.bastion[0].id] : []
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "genai-postgres-${var.environment}"
    Environment = var.environment
  }
}

# MSK (Kafka) Security Group
resource "aws_security_group" "msk" {
  name        = "genai-msk-${var.environment}"
  description = "Security group for MSK (Kafka)"
  vpc_id      = var.vpc_id
  
  ingress {
    description     = "Kafka from EKS"
    from_port       = 9092
    to_port         = 9092
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
  }
  
  ingress {
    description     = "Kafka TLS from EKS"
    from_port       = 9094
    to_port         = 9094
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
  }
  
  ingress {
    description     = "Kafka from Bastion"
    from_port       = 9092
    to_port         = 9092
    protocol        = "tcp"
    security_groups = var.bastion_enabled ? [aws_security_group.bastion[0].id] : []
  }
  
  ingress {
    description     = "Kafka TLS from Bastion"
    from_port       = 9094
    to_port         = 9094
    protocol        = "tcp"
    security_groups = var.bastion_enabled ? [aws_security_group.bastion[0].id] : []
  }
  
  ingress {
    description     = "ZooKeeper from EKS"
    from_port       = 2181
    to_port         = 2181
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "genai-msk-${var.environment}"
    Environment = var.environment
  }
}

# EKS Nodes Security Group
resource "aws_security_group" "eks_nodes" {
  name        = "genai-eks-nodes-${var.environment}"
  description = "Security group for EKS nodes"
  vpc_id      = var.vpc_id
  
  ingress {
    description = "Self reference"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }
  
  ingress {
    description     = "From Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = var.bastion_enabled ? [aws_security_group.bastion[0].id] : []
  }
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name                                        = "genai-eks-nodes-${var.environment}"
    Environment                                 = var.environment
    "kubernetes.io/cluster/genai-eks-cluster"   = "owned"
  }
}

# Bastion Host Security Group (conditional)
resource "aws_security_group" "bastion" {
  count = var.bastion_enabled ? 1 : 0
  
  name        = "genai-bastion-${var.environment}"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id
  
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.bastion_cidr
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "genai-bastion-${var.environment}"
    Environment = var.environment
  }
}