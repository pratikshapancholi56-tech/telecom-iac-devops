#!/bin/bash

set -e

echo "=========================================="
echo "Telecom System Deployment Script"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi
print_success "Docker is installed"

# Deployment type selection
echo ""
echo "Select deployment type:"
echo "1) Local Docker"
echo "2) Kubernetes"
echo "3) AWS (Terraform)"
echo "4) Local Docker (Terraform)"
read -p "Enter choice [1-4]: " choice

case $choice in
    1)
        print_info "Deploying with Local Docker..."
        cd docker
        docker build -t telecom-app:latest .
        docker stop telecom-app 2>/dev/null || true
        docker rm telecom-app 2>/dev/null || true
        docker run -d -p 5000:5000 --name telecom-app --restart always telecom-app:latest
        print_success "Application deployed successfully!"
        print_info "Access the application at: http://localhost:5000"
        ;;
    
    2)
        print_info "Deploying to Kubernetes..."
        if ! command -v kubectl &> /dev/null; then
            print_error "kubectl is not installed"
            exit 1
        fi
        
        # Build image
        cd docker
        docker build -t telecom-app:latest .
        cd ..
        
        # Apply Kubernetes manifests
        kubectl apply -f k8s/deployment.yml
        kubectl apply -f k8s/service.yml
        
        print_success "Kubernetes deployment completed!"
        print_info "Checking service status..."
        kubectl get service telecom-service
        ;;
    
    3)
        print_info "Deploying to AWS with Terraform..."
        if ! command -v terraform &> /dev/null; then
            print_error "Terraform is not installed"
            exit 1
        fi
        
        cd terraform
        terraform init
        terraform plan -out=tfplan
        read -p "Do you want to apply this plan? (yes/no): " confirm
        
        if [ "$confirm" = "yes" ]; then
            terraform apply tfplan
            print_success "AWS deployment completed!"
            terraform output
        else
            print_info "Deployment cancelled"
        fi
        ;;
    
    4)
        print_info "Deploying with Terraform (Local Docker)..."
        if ! command -v terraform &> /dev/null; then
            print_error "Terraform is not installed"
            exit 1
        fi
        
        cd terraform
        terraform init
        terraform apply -auto-approve
        print_success "Terraform deployment completed!"
        ;;
    
    *)
        print_error "Invalid choice"
        exit 1
        ;;
esac

echo ""
print_success "Deployment completed successfully!"
