# Terraform Deployment Guide - TelePay

## Overview

This guide shows how to deploy TelePay using Terraform for Infrastructure as Code (IaC) provisioning.

## Available Terraform Deployments

### 1. Local Docker Deployment (terraform/main.tf)
Deploys the application as a Docker container on your local machine.

### 2. AWS Cloud Deployment (terraform/aws-deployment.tf)
Deploys the application on AWS EC2 with complete VPC setup.

---

## Option 1: Local Docker Deployment with Terraform

### Prerequisites
- Terraform 1.6+
- Docker installed and running

### Step 1: Navigate to Terraform Directory
```bash
cd terraform
```

### Step 2: Initialize Terraform
```bash
terraform init
```

This will download the Docker provider plugin.

### Step 3: Review the Plan
```bash
terraform plan
```

This shows what Terraform will create:
- Docker image (built from ../docker)
- Docker container (telepay-terraform)
- Port mapping (8080 → 5000)
- Health checks

### Step 4: Apply the Configuration
```bash
terraform apply
```

Type `yes` when prompted.

### Step 5: Access the Application
```bash
# Terraform will output:
# application_url = "http://localhost:8080"
# container_id = "<container-id>"
# container_name = "telepay-terraform"

# Open in browser
open http://localhost:8080
```

### Step 6: Verify Deployment
```bash
# Check container status
docker ps | grep telepay-terraform

# View logs
docker logs telepay-terraform

# Test API
curl http://localhost:8080/api/operators/mobile
```

### Step 7: Destroy Infrastructure (when done)
```bash
terraform destroy
```

Type `yes` when prompted.

---

## Option 2: AWS Cloud Deployment with Terraform

### Prerequisites
- Terraform 1.6+
- AWS CLI configured
- AWS account with appropriate permissions
- SSH key pair created in AWS

### Step 1: Configure AWS Credentials
```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter default region: ap-south-1 (Mumbai)
```

### Step 2: Create Variables File
```bash
cd terraform
cat > terraform.tfvars <<EOF
aws_region    = "ap-south-1"
instance_type = "t2.micro"
key_name      = "your-ssh-key-name"
EOF
```

### Step 3: Initialize Terraform
```bash
terraform init
```

### Step 4: Review the Plan
```bash
terraform plan -var-file="terraform.tfvars"
```

This will create:
- VPC with CIDR 10.0.0.0/16
- Public subnet
- Internet Gateway
- Route table
- Security group (ports 22, 80, 5000)
- EC2 instance (Ubuntu 22.04)
- Automated Docker installation
- Application deployment

### Step 5: Apply the Configuration
```bash
terraform apply -var-file="terraform.tfvars"
```

Type `yes` when prompted. This takes 3-5 minutes.

### Step 6: Get Application URL
```bash
terraform output application_url
# Output: http://<public-ip>:5000

terraform output instance_public_ip
# Output: <public-ip>

terraform output instance_public_dns
# Output: <public-dns>
```

### Step 7: Access the Application
```bash
# Open in browser
open $(terraform output -raw application_url)

# Or SSH into instance
ssh -i ~/.ssh/your-key.pem ubuntu@$(terraform output -raw instance_public_ip)
```

### Step 8: Verify Deployment
```bash
# Test from local machine
curl http://$(terraform output -raw instance_public_ip):5000

# SSH and check Docker
ssh -i ~/.ssh/your-key.pem ubuntu@$(terraform output -raw instance_public_ip)
docker ps
docker logs telecom-app
```

### Step 9: Destroy Infrastructure (when done)
```bash
terraform destroy -var-file="terraform.tfvars"
```

Type `yes` when prompted.

---

## Terraform Commands Reference

### Basic Commands
```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Format configuration files
terraform fmt

# Show current state
terraform show

# List resources
terraform state list

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy
```

### Advanced Commands
```bash
# Apply without confirmation
terraform apply -auto-approve

# Destroy without confirmation
terraform destroy -auto-approve

# Target specific resource
terraform apply -target=docker_container.telecom_container

# Import existing resource
terraform import docker_container.telecom_container <container-id>

# Refresh state
terraform refresh

# Output specific value
terraform output application_url
terraform output -raw application_url
```

---

## Terraform State Management

### Local State (Default)
Terraform stores state in `terraform.tfstate` file locally.

```bash
# View state
terraform show

# List resources in state
terraform state list

# Show specific resource
terraform state show docker_container.telecom_container
```

### Remote State (Production)
For team collaboration, use remote state:

```hcl
terraform {
  backend "s3" {
    bucket = "telepay-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "ap-south-1"
  }
}
```

---

## Troubleshooting

### Issue: Docker provider error
```bash
Error: Cannot connect to Docker daemon
```

**Solution**:
```bash
# Check Docker is running
docker ps

# On macOS, update socket path in main.tf
provider "docker" {
  host = "unix:///Users/<username>/.docker/run/docker.sock"
}
```

### Issue: Port already in use
```bash
Error: port 8080 already allocated
```

**Solution**:
```bash
# Change port in main.tf
ports {
  internal = 5000
  external = 9090  # Use different port
}
```

### Issue: AWS credentials not found
```bash
Error: No valid credential sources found
```

**Solution**:
```bash
# Configure AWS CLI
aws configure

# Or set environment variables
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
export AWS_DEFAULT_REGION="ap-south-1"
```

### Issue: SSH key not found
```bash
Error: InvalidKeyPair.NotFound
```

**Solution**:
```bash
# Create SSH key in AWS
aws ec2 create-key-pair --key-name telepay-key --query 'KeyMaterial' --output text > ~/.ssh/telepay-key.pem
chmod 400 ~/.ssh/telepay-key.pem

# Update terraform.tfvars
key_name = "telepay-key"
```

---

## Comparison: Docker Compose vs Terraform

### Docker Compose
- ✅ Fastest for local development
- ✅ Simple YAML configuration
- ✅ Good for single machine
- ❌ Not for cloud deployment
- ❌ Limited infrastructure management

### Terraform (Local Docker)
- ✅ Infrastructure as Code
- ✅ State management
- ✅ Reproducible deployments
- ✅ Version controlled
- ✅ Can extend to cloud
- ❌ More complex than Compose

### Terraform (AWS)
- ✅ Production-ready
- ✅ Complete infrastructure
- ✅ Scalable
- ✅ Cloud-native
- ✅ Automated provisioning
- ❌ Costs money
- ❌ More complex setup

---

## Best Practices

### 1. Use Variables
```hcl
variable "app_port" {
  description = "Application port"
  type        = number
  default     = 8080
}
```

### 2. Use Outputs
```hcl
output "application_url" {
  value = "http://localhost:${var.app_port}"
}
```

### 3. Use Remote State
Store state in S3 or Terraform Cloud for team collaboration.

### 4. Use Workspaces
```bash
# Create workspace
terraform workspace new production
terraform workspace new staging

# Switch workspace
terraform workspace select production

# List workspaces
terraform workspace list
```

### 5. Use Modules
Organize code into reusable modules:
```
terraform/
├── modules/
│   ├── docker-app/
│   └── aws-infrastructure/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── production/
```

---

## Next Steps

1. **Deploy Locally**: Start with `terraform/main.tf` for local Docker deployment
2. **Test Application**: Verify all services work correctly
3. **Deploy to AWS**: Use `terraform/aws-deployment.tf` for cloud deployment
4. **Set Up CI/CD**: Integrate Terraform with GitHub Actions or Jenkins
5. **Add Monitoring**: Integrate CloudWatch or Prometheus
6. **Scale Up**: Add auto-scaling and load balancers

---

## Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [Docker Provider](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs)
- [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

---

## Summary

Terraform provides Infrastructure as Code for TelePay with:
- ✅ Automated provisioning
- ✅ Reproducible deployments
- ✅ State management
- ✅ Version control
- ✅ Multi-environment support
- ✅ Cloud-ready architecture

**Choose your deployment method and get started!**
