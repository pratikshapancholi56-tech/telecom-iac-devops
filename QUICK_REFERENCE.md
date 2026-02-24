# Quick Reference Card

## 🚀 Fastest Way to Run

```bash
docker-compose up -d
# Access: http://localhost:5000
```

## 📋 Common Commands

### Docker
```bash
# Build
docker build -t telecom-app docker/

# Run
docker run -d -p 5000:5000 telecom-app

# Logs
docker logs -f <container-name>

# Stop
docker stop <container-name>
```

### Docker Compose
```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# Logs
docker-compose logs -f

# Rebuild
docker-compose up -d --build
```

### Kubernetes
```bash
# Deploy
kubectl apply -f k8s/

# Status
kubectl get all

# Logs
kubectl logs -l app=telecom -f

# Scale
kubectl scale deployment telecom-deployment --replicas=5

# Delete
kubectl delete -f k8s/
```

### Terraform (Local)
```bash
cd terraform
terraform init
terraform apply
terraform destroy
```

### Terraform (AWS)
```bash
cd terraform
terraform init
terraform apply \
  -var="aws_region=ap-south-1" \
  -var="instance_type=t2.micro" \
  -var="key_name=your-key"
```

### Scripts
```bash
# Setup dependencies
./scripts/setup.sh

# Deploy (interactive)
./scripts/deploy.sh

# Test
./scripts/test.sh
```

### Ansible
```bash
cd ansible
ansible-playbook -i localhost, -c local install.yml
```

## 🧪 Testing

### Quick Test
```bash
curl http://localhost:5000
```

### Full Test Suite
```bash
./scripts/test.sh
```

### API Tests
```bash
# Get plans
curl http://localhost:5000/api/plans/airtel

# Recharge
curl -X POST http://localhost:5000/api/recharge \
  -H "Content-Type: application/json" \
  -d '{"mobile":"9876543210","operator":"airtel","plan_id":"air_1"}'

# Transactions
curl http://localhost:5000/api/transactions
```

## 📊 Monitoring

### Docker
```bash
docker ps
docker stats
docker logs -f <container>
```

### Kubernetes
```bash
kubectl get pods
kubectl top pods
kubectl describe pod <pod-name>
kubectl logs -f <pod-name>
```

## 🔧 Troubleshooting

### Port Already in Use
```bash
# Find process
lsof -i :5000

# Kill process
kill -9 <PID>
```

### Docker Issues
```bash
# Clean up
docker system prune -f

# Remove all containers
docker rm -f $(docker ps -aq)

# Remove all images
docker rmi -f $(docker images -q)
```

### Kubernetes Issues
```bash
# Check events
kubectl get events --sort-by='.lastTimestamp'

# Describe pod
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>
```

## 📱 Supported Operators

- **Airtel**: ₹199 - ₹2999
- **Jio**: ₹209 - ₹2999
- **Vi**: ₹179 - ₹2899
- **BSNL**: ₹197 - ₹2399

## 🌐 URLs

- **Local**: http://localhost:5000
- **Minikube**: `minikube service telecom-service --url`
- **AWS**: Check Terraform output

## 📁 Important Files

- `docker/app.py` - Main application
- `docker/templates/index.html` - Frontend
- `k8s/deployment.yml` - K8s deployment
- `k8s/service.yml` - K8s service
- `terraform/main.tf` - Local deployment
- `terraform/aws-deployment.tf` - AWS deployment
- `docker-compose.yml` - Compose config

## 🔑 Environment Variables

```bash
# Flask
FLASK_ENV=production

# AWS (for Terraform)
AWS_ACCESS_KEY_ID=<your-key>
AWS_SECRET_ACCESS_KEY=<your-secret>
AWS_DEFAULT_REGION=ap-south-1
```

## 📞 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | / | Main UI |
| GET | /api/plans/{operator} | Get plans |
| POST | /api/recharge | Process recharge |
| GET | /api/transactions | Get transactions |

## 🎯 Valid Mobile Format

- 10 digits
- Starts with 6, 7, 8, or 9
- Example: 9876543210

## 💡 Tips

1. Use Docker Compose for quick testing
2. Use Kubernetes for production
3. Use Terraform for cloud deployment
4. Run tests after deployment
5. Check logs if something fails
6. Scale K8s deployment as needed
7. Use scripts for automation

## 📚 Documentation

- `README.md` - Quick start
- `DEPLOYMENT_GUIDE.md` - Detailed deployment
- `PROJECT_OVERVIEW.md` - Complete overview
- `QUICK_REFERENCE.md` - This file
