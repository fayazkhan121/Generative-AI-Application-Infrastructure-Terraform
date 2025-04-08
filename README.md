# Terraform Infrastructure for Generative AI Application

This repository contains Terraform code for deploying a production-ready infrastructure for a generative AI application in AWS. The infrastructure is designed to meet the requirements specified for securely hosting a generative AI application with PostgreSQL for structured data, Cassandra (implemented via MSK) for timeseries data, Kubernetes for application workloads, GPU acceleration, and secure connectivity.
![image](https://github.com/user-attachments/assets/2cdc308f-5c5a-4bbc-8ef8-0825c27ebcd9)


## Architecture Overview

The infrastructure includes the following components:

- **VPC** with public, private, and database subnets across multiple availability zones
- **EKS Cluster** for Kubernetes workloads with separate node groups for:
  - General purpose applications
  - Memory-intensive applications
  - GPU-accelerated model inference
- **PostgreSQL RDS** for structured data with high availability
- **MSK (Amazon Managed Streaming for Kafka)** for timeseries data (as a modern alternative to Cassandra)
- **Security Components**:
  - AWS WAF for web application firewall
  - VPC security groups for network segmentation
  - IAM roles and policies for secure access
  - Encryption for data at rest and in transit
  - GuardDuty, AWS Config, and SecurityHub for security monitoring
- **Connectivity Components**:
  - API Gateway for external API access
  - CloudFront for web application delivery
  - ALB for Kubernetes service exposure
- **Monitoring and Observability**:
  - CloudWatch alarms for all services
  - AWS Managed Prometheus for Kubernetes metrics
  - Grafana for visualization
  - CloudTrail for audit logging

## Prerequisites

- AWS Account with administrative privileges
- Terraform v1.0.0 or newer
- AWS CLI configured with appropriate credentials
- Domain name for the application (for TLS certificates)

## Getting Started

1. Clone this repository
2. Update the `terraform.tfvars` file with your specific values
3. Initialize Terraform:

```bash
terraform init
```

4. Plan the deployment:

```bash
terraform plan
```

5. Apply the configuration:

```bash
terraform apply
```

## Important Security Notes

- The sample `terraform.tfvars` file contains placeholder values that should be changed for a production deployment
- Sensitive values (like database passwords) should be provided via environment variables or AWS Systems Manager Parameter Store
- For production use, restrict SSH access to bastion hosts to specific IP ranges
- Review IAM permissions to ensure they follow the principle of least privilege
- Enable all security monitoring features in production environments

## Module Structure

The Terraform code is organized into the following modules:

- **vpc**: Network infrastructure
- **security_groups**: Network security configuration
- **eks**: Kubernetes cluster and node groups
- **postgres**: PostgreSQL RDS instance
- **msk**: Kafka cluster for timeseries data
- **iam**: IAM roles and policies
- **kubernetes_resources**: Kubernetes deployments, services, and configurations
- **cloudwatch_alarms**: Monitoring and alerting
- **security_monitoring**: Security-focused monitoring and compliance

## Deployment Phases

For large-scale deployments, it's recommended to deploy the infrastructure in phases:

1. Core networking (VPC, subnets, security groups)
2. Data stores (PostgreSQL, MSK)
3. Kubernetes infrastructure (EKS, node groups)
4. Application components (deployments, services)
5. Monitoring and security components

## Customization

The infrastructure can be customized by modifying:

- Instance types and counts in the `terraform.tfvars` file
- Kubernetes deployments in the `kubernetes_resources` module
- Monitoring thresholds in the `cloudwatch_alarms` module
- Security configurations in the `security_monitoring` module

## Cost Optimization

For development or testing environments, you can reduce costs by:

- Reducing the number of nodes in each node group
- Using smaller instance types
- Disabling multi-AZ deployments for RDS
- Reducing MSK broker count
- Disabling some of the security monitoring features

## Maintenance

Regular maintenance tasks include:

- Applying Kubernetes and AWS security patches
- Reviewing and rotating access credentials
- Monitoring resource utilization and scaling as needed
- Reviewing security findings from GuardDuty and SecurityHub
- Updating Terraform modules to incorporate new best practices

## Cleanup

To destroy the infrastructure when no longer needed:

```bash
terraform destroy
```

**Note**: This will remove all resources, including data in RDS and MSK. Make sure to back up any important data before running this command.

## Troubleshooting

Common issues and their solutions:

- **EKS Cluster Creation Failures**: Verify IAM permissions and VPC configuration
- **RDS Connectivity Issues**: Check security groups and subnet configurations
- **Kubernetes Deployment Failures**: Verify OIDC provider configuration for service accounts
- **MSK Access Problems**: Confirm IAM policies and security group rules

## Contributing

1. Fork the repository
2. Create a new feature branch
3. Make your changes
4. Submit a pull request with a detailed description of the changes

## License

This project is licensed under the MIT License - see the LICENSE file for details.
