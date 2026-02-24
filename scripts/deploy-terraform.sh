#!/bin/bash

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     TelePay - Terraform Deployment Script                 ║"
echo "║     Group 06 - IaC Provisioning                           ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed"
    print_info "Install from: https://www.terraform.io/downloads"
    exit 1
fi
print_success "Terraform is installed: $(terraform version -json | grep -o '"version":"[^"]*' | cut -d'"' -f4)"

# Check if Docker is running
if ! docker ps &> /dev/null; then
    print_error "Docker is not running"
    print_info "Please start Docker Desktop and try again"
    exit 1
fi
print_success "Docker is running"

echo ""
echo "Select deployment type:"
echo "1) Local Docker (Terraform)"
echo "2) AWS Cloud (Terraform)"
read -p "Enter choice [1-2]: " choice

case $choice in
    1)
        print_info "Deploying with Terraform (Local Docker)..."
        cd terraform
        
        # Initialize Terraform
        print_info "Initializing Terraform..."
        terraform init
        print_success "Terraform initialized"
        
        # Validate configuration
        print_info "Validating configuration..."
        terraform validate
        print_success "Configuration is valid"
        
        # Show plan
        print_info "Generating execution plan..."
        terraform plan -out=tfplan
        
        echo ""
        read -p "Do you want to apply this plan? (yes/no): " confirm
        
        if [ "$confirm" = "yes" ]; then
            print_info "Applying Terraform configuration..."
            terraform apply tfplan
            rm tfplan
            
            echo ""
            print_success "Deployment completed successfully!"
            echo ""
            print_info "Application URLs:"
            terraform output -raw application_url
            echo ""
            echo ""
            print_info "Container Details:"
            echo "   Name: $(terraform output -raw container_name)"
            echo "   ID: $(terraform output -raw container_id | cut -c1-12)"
            echo ""
            print_info "Useful Commands:"
            echo "   View logs: docker logs $(terraform output -raw container_name)"
            echo "   Stop app: terraform destroy"
            echo "   Restart: terraform apply -auto-approve"
        else
            print_info "Deployment cancelled"
            rm tfplan
        fi
        ;;
    
    2)
        print_info "Deploying to AWS with Terraform..."
        cd terraform
        
        # Check AWS credentials
        if ! aws sts get-caller-identity &> /dev/null; then
            print_error "AWS credentials not configured"
            print_info "Run: aws configure"
            exit 1
        fi
        print_success "AWS credentials configured"
        
        # Check for variables file
        if [ ! -f "terraform.tfvars" ]; then
            print_info "Creating terraform.tfvars file..."
            cat > terraform.tfvars <<EOF
aws_region    = "ap-south-1"
instance_type = "t2.micro"
key_name      = ""
EOF
            print_info "Please edit terraform.tfvars and add your SSH key name"
            print_info "Then run this script again"
            exit 1
        fi
        
        # Initialize Terraform
        print_info "Initializing Terraform..."
        terraform init
        print_success "Terraform initialized"
        
        # Validate configuration
        print_info "Validating configuration..."
        terraform validate
        print_success "Configuration is valid"
        
        # Show plan
        print_info "Generating execution plan..."
        terraform plan -var-file="terraform.tfvars" -out=tfplan
        
        echo ""
        read -p "Do you want to apply this plan? (yes/no): " confirm
        
        if [ "$confirm" = "yes" ]; then
            print_info "Applying Terraform configuration..."
            print_info "This will take 3-5 minutes..."
            terraform apply tfplan
            rm tfplan
            
            echo ""
            print_success "AWS deployment completed successfully!"
            echo ""
            print_info "Application Details:"
            echo "   URL: $(terraform output -raw application_url)"
            echo "   Public IP: $(terraform output -raw instance_public_ip)"
            echo "   Public DNS: $(terraform output -raw instance_public_dns)"
            echo ""
            print_info "SSH Access:"
            echo "   ssh -i ~/.ssh/your-key.pem ubuntu@$(terraform output -raw instance_public_ip)"
            echo ""
            print_info "Useful Commands:"
            echo "   Destroy: terraform destroy -var-file='terraform.tfvars'"
        else
            print_info "Deployment cancelled"
            rm tfplan
        fi
        ;;
    
    *)
        print_error "Invalid choice"
        exit 1
        ;;
esac

echo ""
print_success "Script completed!"
