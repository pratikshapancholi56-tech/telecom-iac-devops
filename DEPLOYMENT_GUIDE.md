# Deployment Guide - Indian Telecom Recharge System

## Prerequisites

Before deploying, ensure you have the following installed:

- Docker 20.10+
- Python 3.9+ (for local development)
- Terraform 1.6+ (for infrastructure deployment)
- kubectl 1.28+ (for Kubernetes deployment)
- Ansible 2.9+ (for automated setup)

## Deployment Options

### 1. Quick Start - Docker Compose (Recommended for Testing)

This is the fastest way to get the application running locally.

```bash
# Clone the repository
git clone <repository-url>
cd telecom-iac

# Start the application
docker-compose up -d

# Check logs
docker-compose logs -f

# Access the application
open http://localhost:5000

# Stop the application
docker-compose down
```

### 2. Manual Docker Deployment

```bash
# Navigate to docker directory
cd docker

# Build the image
docker build -t telecom-app:latest .

# Run the container
docker run -d \
  --name telecom-recharge \
  -p 5000:5000 \
  --restart unless-stopped \
  telecom-app:latest

# View logs
docker logs -f telecom-recharge

# Stop and remove
docker stop telecom-recharge
docker rm telecom-recharge
```

### 3. Kubernetes Deployment

#### Prerequisites
- Running Kubernetes cluster (minikube, kind, or cloud provider)
- kubectl configured to access your cluster

```bash
# Build and load image (for local clusters like minikube)
cd docker
docker build -t telecom-app:latest .

# For minikube
minikube image load telecom-app:latest

# Deploy to Kubernetes
kubectl apply -f k8s/deployment.yml
kubectl apply -f k8s/service.yml

# Check deployment status
kubectl get deployments
kubectl get pods
kubectl get services

# Get service URL (for minikube)
minikube service telecom-service --url

# For cloud providers with LoadBalancer
kubectl get service telecom-service

# View logs
kubectl logs -l app=telecom

# Scale deployment
kubectl scale deployment telecom-deployment --replicas=5

# Delete deployment
kubectl delete -f k8s/
```

### 4. AWS Cloud Deployment with Terraform

#### Prerequisites
- AWS account with appropriate permissions
- AWS CLI configured (`aws configure`)
- SSH key pair created in AWS

```bash
# Navigate to terraform directory
cd terraform

# Initialize Terraform
terraform init

# Review the plan
terraform plan \
  -var="aws_region=ap-south-1" \
  -var="instance_type=t2.micro" \
  -var="key_name=your-ssh-key-name"

# Apply the configuration
terraform apply \
  -var="aws_region=ap-south-1" \
  -var="instance_type=t2.micro" \
  -var="key_name=your-ssh-key-name"

# Get the application URL
terraform output application_url

# Destroy infrastructure when done
terraform destroy
```

#### AWS Deployment Notes
- Default region: ap-south-1 (Mumbai) - optimal for Indian users
- Default instance: t2.micro (free tier eligible)
- Security group allows ports 22, 80, and 5000
- Application runs on port 5000

### 5. Local Docker with Terraform

```bash
cd terraform

# Initialize Terraform
terraform init

# Apply configuration
terraform apply -auto-approve

# Access at http://localhost:5000

# Destroy when done
terraform destroy -auto-approve
```

### 6. Automated Setup with Scripts

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Install all dependencies
./scripts/setup.sh

# Deploy the application (interactive)
./scripts/deploy.sh
```

### 7. Ansible Automated Setup

```bash
cd ansible

# Install dependencies on localhost
ansible-playbook -i localhost, -c local install.yml

# For remote hosts
ansible-playbook -i inventory.ini install.yml
```

## CI/CD Setup

### GitHub Actions

The repository includes a GitHub Actions workflow that automatically:
1. Builds Docker image on push
2. Runs tests
3. Pushes to Docker Hub (optional)
4. Deploys to Kubernetes (optional)

To enable:
1. Add secrets in GitHub repository settings:
   - `DOCKER_USERNAME`
   - `DOCKER_PASSWORD`
2. Push to main branch

### Jenkins

The repository includes a Jenkinsfile for Jenkins CI/CD.

To use:
1. Create a new Pipeline job in Jenkins
2. Point to this repository
3. Add Docker Hub credentials with ID: `docker-hub-credentials`
4. Configure kubectl access for Kubernetes deployment

## Testing the Application

### Manual Testing

1. Open http://localhost:5000 (or your deployment URL)
2. Enter a 10-digit mobile number (starting with 6-9)
3. Select an operator (Airtel, Jio, Vi, or BSNL)
4. Choose a recharge plan
5. Click "Proceed to Recharge"
6. Verify transaction appears in "Recent Transactions"

### API Testing

```bash
# Get plans for Airtel
curl http://localhost:5000/api/plans/airtel

# Process a recharge
curl -X POST http://localhost:5000/api/recharge \
  -H "Content-Type: application/json" \
  -d '{
    "mobile": "9876543210",
    "operator": "airtel",
    "plan_id": "air_1"
  }'

# Get recent transactions
curl http://localhost:5000/api/transactions
```

## Monitoring and Logs

### Docker
```bash
# View logs
docker logs -f telecom-recharge

# Check container status
docker ps
docker stats telecom-recharge
```

### Kubernetes
```bash
# View logs
kubectl logs -l app=telecom -f

# Check pod status
kubectl get pods -l app=telecom

# Describe pod for details
kubectl describe pod <pod-name>

# Check resource usage
kubectl top pods
```

### AWS
```bash
# SSH into instance
ssh -i your-key.pem ubuntu@<instance-ip>

# View Docker logs
sudo docker logs -f telecom-app
```

## Troubleshooting

### Application won't start
- Check Docker is running: `docker ps`
- Check port 5000 is available: `lsof -i :5000`
- View logs: `docker logs <container-name>`

### Kubernetes pod not starting
- Check image is available: `kubectl describe pod <pod-name>`
- Check logs: `kubectl logs <pod-name>`
- Verify resources: `kubectl get events`

### AWS deployment fails
- Verify AWS credentials: `aws sts get-caller-identity`
- Check Terraform state: `terraform show`
- Review security group rules

### Plans not loading
- Check browser console for errors
- Verify API endpoint: `curl http://localhost:5000/api/plans/airtel`
- Check Flask logs

## Production Considerations

1. **Database**: Add PostgreSQL/MySQL for persistent transaction storage
2. **Authentication**: Implement user authentication and authorization
3. **Payment Gateway**: Integrate real payment processing
4. **SSL/TLS**: Add HTTPS with Let's Encrypt or AWS Certificate Manager
5. **Monitoring**: Add Prometheus, Grafana, or CloudWatch
6. **Logging**: Centralize logs with ELK stack or CloudWatch Logs
7. **Backup**: Implement database backup strategy
8. **Scaling**: Use auto-scaling groups or Kubernetes HPA
9. **CDN**: Add CloudFront or similar for static assets
10. **Rate Limiting**: Implement API rate limiting

## Support

For issues or questions:
1. Check logs first
2. Review this deployment guide
3. Check README.md for additional information
4. Review Terraform/Kubernetes documentation
