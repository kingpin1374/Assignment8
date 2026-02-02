# Assignment 5: Flask and Express Deployment with Docker and AWS

This project deploys a Flask backend and Express frontend using Docker containers on AWS ECS with Terraform.

## Architecture

- **ECR**: Two repositories for Docker images (frontend and backend)
- **VPC**: Custom VPC with public and private subnets
- **ECS**: Fargate cluster with services for both applications
- **ALB**: Application Load Balancer for routing traffic
- **Security Groups**: Proper network isolation and access control

## Prerequisites

1. AWS CLI configured with appropriate permissions
2. Terraform installed
3. Docker installed
4. Existing Docker images: `assignment5-frontend` and `assignment5-backend`

## Deployment Steps

### 1. Initialize Terraform

```bash
cd task3
terraform init
```

### 2. Plan and Apply Infrastructure

```bash
# Review the deployment plan
terraform plan

# Apply the infrastructure
terraform apply
```

### 3. Push Docker Images to ECR

After Terraform creates the ECR repositories, push your existing images:

```bash
# Get your AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Run the push script
./push-images.sh ap-south-1 $AWS_ACCOUNT_ID
```

Or manually:

```bash
# Login to ECR
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.ap-south-1.amazonaws.com

# Tag and push frontend
docker tag assignment5-frontend:latest $(aws sts get-caller-identity --query Account --output text).dkr.ecr.ap-south-1.amazonaws.com/assignment5-frontend:latest
docker push $(aws sts get-caller-identity --query Account --output text).dkr.ecr.ap-south-1.amazonaws.com/assignment5-frontend:latest

# Tag and push backend
docker tag assignment5-backend:latest $(aws sts get-caller-identity --query Account --output text).dkr.ecr.ap-south-1.amazonaws.com/assignment5-backend:latest
docker push $(aws sts get-caller-identity --query Account --output text).dkr.ecr.ap-south-1.amazonaws.com/assignment5-backend:latest
```

### 4. Update ECS Services (if needed)

If the services were created before images were pushed, update them:

```bash
# Update frontend service
aws ecs update-service --cluster assignment5-cluster --service assignment5-frontend-service --force-new-deployment

# Update backend service
aws ecs update-service --cluster assignment5-cluster --service assignment5-backend-service --force-new-deployment
```

## Access Your Applications

After deployment, get the Load Balancer URL:

```bash
terraform output alb_url
```

- **Frontend**: Access at the ALB URL (http://your-alb-dns-name)
- **Backend API**: Access at the ALB URL with `/api/*` prefix (http://your-alb-dns-name/api/*)

## Infrastructure Components

### ECR Repositories
- `assignment5-frontend`: For Express frontend image
- `assignment5-backend`: For Flask backend image

### VPC Configuration
- **VPC CIDR**: 10.0.0.0/16
- **Public Subnets**: 10.0.1.0/24, 10.0.2.0/24
- **Private Subnets**: 10.0.10.0/24, 10.0.11.0/24
- **Internet Gateway**: For public subnet internet access
- **NAT Gateway**: For private subnet outbound internet access

### ECS Configuration
- **Cluster**: assignment5-cluster
- **Launch Type**: Fargate
- **Frontend Service**: 256 CPU, 512 MB RAM, Port 3000
- **Backend Service**: 256 CPU, 512 MB RAM, Port 5000

### Load Balancer Configuration
- **Type**: Application Load Balancer
- **Frontend Target Group**: Port 3000, health check on "/"
- **Backend Target Group**: Port 5000, health check on "/health"
- **Listener Rule**: Routes `/api/*` to backend, everything else to frontend

## Monitoring and Logs

- **CloudWatch Logs**: `/ecs/assignment5` log group
- **ECS Container Insights**: Enabled for monitoring
- **Health Checks**: Configured for both services

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## Troubleshooting

### Common Issues

1. **ECS Service Fails to Start**: Check if images are pushed to ECR
2. **Health Check Failures**: Ensure your applications respond to health check endpoints
3. **Permission Errors**: Verify AWS credentials and IAM permissions

### Useful Commands

```bash
# Check ECS service status
aws ecs describe-services --cluster assignment5-cluster --services assignment5-frontend-service assignment5-backend-service

# Check task status
aws ecs list-tasks --cluster assignment5-cluster

# View CloudWatch logs
aws logs tail /ecs/assignment5 --follow

# Check ALB target health
aws elbv2 describe-target-health --target-group-arn $(terraform output -raw frontend_target_group_arn)
```

## Cost Optimization

- Using Fargate Spot instances can reduce costs
- Consider auto-scaling policies for production workloads
- Monitor and adjust resource allocation based on usage

## Security Considerations

- All resources are tagged for proper identification
- Security groups follow least privilege principle
- Private subnets for application workloads
- No sensitive data in configuration
