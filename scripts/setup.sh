#!/bin/bash

set -e

echo "=========================================="
echo "Telecom System Setup Script"
echo "=========================================="

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
else
    echo "Unsupported OS"
    exit 1
fi

print_info "Detected OS: $OS"

# Install Docker
if ! command -v docker &> /dev/null; then
    print_info "Installing Docker..."
    if [ "$OS" = "linux" ]; then
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        rm get-docker.sh
    else
        print_info "Please install Docker Desktop for Mac from: https://www.docker.com/products/docker-desktop"
        exit 1
    fi
    print_success "Docker installed"
else
    print_success "Docker already installed"
fi

# Install Terraform
if ! command -v terraform &> /dev/null; then
    print_info "Installing Terraform..."
    if [ "$OS" = "linux" ]; then
        wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
        unzip terraform_1.6.0_linux_amd64.zip
        sudo mv terraform /usr/local/bin/
        rm terraform_1.6.0_linux_amd64.zip
    else
        brew tap hashicorp/tap
        brew install hashicorp/tap/terraform
    fi
    print_success "Terraform installed"
else
    print_success "Terraform already installed"
fi

# Install kubectl
if ! command -v kubectl &> /dev/null; then
    print_info "Installing kubectl..."
    if [ "$OS" = "linux" ]; then
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        rm kubectl
    else
        brew install kubectl
    fi
    print_success "kubectl installed"
else
    print_success "kubectl already installed"
fi

# Install Ansible
if ! command -v ansible &> /dev/null; then
    print_info "Installing Ansible..."
    if [ "$OS" = "linux" ]; then
        sudo apt-get update
        sudo apt-get install -y ansible
    else
        brew install ansible
    fi
    print_success "Ansible installed"
else
    print_success "Ansible already installed"
fi

echo ""
print_success "All dependencies installed successfully!"
print_info "You may need to log out and back in for Docker permissions to take effect"
print_info "Run './scripts/deploy.sh' to deploy the application"
