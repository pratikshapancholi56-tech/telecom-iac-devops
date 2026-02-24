# TelePay - Indian Telecom & Utility Payment System

**Group 06 Project** - Infrastructure as Code (IaC) Provisioning for Telecom System

A production-ready, fully functional telecom and utility payment platform for Indian services with complete Infrastructure as Code (IaC) automation. The system supports mobile recharge, DTH, broadband, and utility bill payments with real-time processing, transaction tracking, and multiple deployment options.

## 🌟 Live Demo

- **Landing Page**: http://localhost:8080
- **Payment Dashboard**: http://localhost:8080/app

## 📱 Supported Services

### Telecom Services
- ✅ **Mobile Recharge**: Airtel, Jio, Vi (Vodafone Idea), BSNL
- ✅ **DTH Recharge**: Tata Play, Airtel Digital TV, Dish TV, Sun Direct
- ✅ **Broadband/Fiber**: Jio Fiber, Airtel Xstream, BSNL Fiber, ACT Fibernet
- ✅ **Postpaid Bills**: All major operators

### Utility Services
- ✅ **Electricity Bills**: Adani, BSES, Tata Power, MSEDCL, BESCOM, TNEB
- ✅ **Gas Bills**: Indraprastha Gas, Mahanagar Gas, Gujarat Gas, Adani Gas
- ✅ **Water Bills**: Delhi Jal Board, Mumbai Water, Bangalore Water, Chennai Water
- ✅ **Landline Bills**: BSNL, MTNL, Airtel Landline

## Quick Start

### 🚀 Recommended: Terraform Deployment (IaC)

```bash
# Automated Terraform deployment
./scripts/deploy-terraform.sh

# Or manual Terraform deployment
cd terraform
terraform init
terraform plan
terraform apply

# Access: http://localhost:8080
```

### Option 1: Docker Compose (Quick Testing)

```bash
# Build and run with Docker Compose
docker-compose up -d

# Access Landing Page: http://localhost:8080
# Access Payment App: http://localhost:8080/app
```

### Option 2: Manual Docker Deployment

```bash
# Build and run with Docker
cd docker
docker build -t telecom-app .
docker run -d -p 8080:5000 telecom-app

# Access at http://localhost:8080
```

### Option 3: Automated Deployment Script

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Run setup (installs dependencies)
./scripts/setup.sh

# Run deployment (interactive - includes Terraform option)
./scripts/deploy.sh
```

### Option 4: Terraform (Local Docker) - IaC Approach

```bash
cd terraform
terraform init
terraform apply
```

### Using Terraform (AWS Cloud)

```bash
cd terraform

# Initialize Terraform
terraform init

# Deploy to AWS
terraform apply -var="aws_region=ap-south-1" -var="instance_type=t2.micro"

# Access using the output URL
terraform output application_url
```

### Option 5: Using Kubernetes

```bash
# Apply Kubernetes manifests
kubectl apply -f k8s/deployment.yml
kubectl apply -f k8s/service.yml

# Get service URL
kubectl get service telecom-service
```

### Automated Setup with Ansible

```bash
# Install all dependencies (Docker, Terraform, kubectl)
cd ansible
ansible-playbook -i localhost, install.yml
```

## Project Structure

```
.
├── ansible/
│   └── install.yml              # Automated dependency installation
├── docker/
│   ├── Dockerfile               # Container image definition
│   ├── app.py                   # Flask application
│   └── templates/
│       └── index.html           # Frontend interface
├── k8s/
│   ├── deployment.yml           # Kubernetes deployment
│   └── service.yml              # Kubernetes service
├── terraform/
│   ├── main.tf                  # Local Docker deployment
│   ├── aws-deployment.tf        # AWS cloud deployment
│   └── variables.tf             # Terraform variables
└── .github/
    └── workflows/
        └── deploy.yml           # CI/CD pipeline
```

## API Endpoints

- `GET /` - Main application interface
- `GET /api/plans/<operator>` - Get plans for specific operator
- `POST /api/recharge` - Process recharge transaction
- `GET /api/transactions` - Get recent transactions

## CI/CD Pipeline

The GitHub Actions workflow automatically:
1. Builds Docker image on every push
2. Runs application tests
3. Pushes to Docker Hub (if configured)
4. Deploys to Kubernetes (if configured)

## Configuration

### AWS Deployment

Create `terraform/aws.tfvars`:

```hcl
aws_region    = "ap-south-1"
instance_type = "t2.micro"
key_name      = "your-ssh-key"
```

### Docker Hub (Optional)

Add GitHub secrets:
- `DOCKER_USERNAME`
- `DOCKER_PASSWORD`

## Requirements

- Docker 20.10+
- Terraform 1.6+
- Kubernetes 1.28+
- Ansible 2.9+
- Python 3.9+

## Development

```bash
# Run locally for development
cd docker
python3 -m venv venv
source venv/bin/activate
pip install flask
python app.py
```

## License

MIT License
