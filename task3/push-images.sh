#!/bin/bash

# Script to push Docker images to ECR
# Usage: ./push-images.sh [AWS_REGION] [AWS_ACCOUNT_ID]

set -e

# Configuration
AWS_REGION=${1:-"ap-south-1"}
AWS_ACCOUNT_ID=${2:-$(aws sts get-caller-identity --query Account --output text)}
PROJECT_NAME="assignment5"

# ECR Repository URIs
FRONTEND_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}-frontend"
BACKEND_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}-backend"

# Image names
FRONTEND_IMAGE="assignment5-frontend"
BACKEND_IMAGE="assignment5-backend"

echo "=== Pushing Docker images to ECR ==="
echo "AWS Region: $AWS_REGION"
echo "AWS Account ID: $AWS_ACCOUNT_ID"
echo "Frontend Repository: $FRONTEND_REPO"
echo "Backend Repository: $BACKEND_REPO"
echo ""

# Login to ECR
echo "Logging in to ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Tag and push frontend image
echo "Tagging and pushing frontend image..."
docker tag $FRONTEND_IMAGE:latest $FRONTEND_REPO:latest
docker push $FRONTEND_REPO:latest

# Tag and push backend image
echo "Tagging and pushing backend image..."
docker tag $BACKEND_IMAGE:latest $BACKEND_REPO:latest
docker push $BACKEND_REPO:latest

echo ""
echo "=== Images pushed successfully! ==="
echo "Frontend: $FRONTEND_REPO:latest"
echo "Backend: $BACKEND_REPO:latest"
