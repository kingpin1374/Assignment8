#!/bin/bash

# Simple deployment script for Assignment5 to AWS EC2 (No Docker)
# Usage: ./deploy.sh [EC2_PUBLIC_IP]

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <EC2_PUBLIC_IP>"
    echo "Please provide the EC2 instance public IP address"
    exit 1
fi

EC2_IP=$1
KEY_PATH="${2:-~/.ssh/mykey.pem}"

echo "Deploying Assignment5 to EC2 instance at $EC2_IP (No Docker)..."

# Check if SSH key exists
if [ ! -f "$KEY_PATH" ]; then
    echo "Error: SSH key not found at $KEY_PATH"
    echo "Please provide the correct path to your AWS key pair file"
    exit 1
fi

# Set proper permissions for SSH key
chmod 400 "$KEY_PATH"

# Create app directory on EC2 and copy files
echo "Creating app directory and copying files..."
ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no ubuntu@$EC2_IP "mkdir -p /home/ubuntu/app"

# Copy the entire Assignment5 directory to EC2
echo "Copying application files..."
scp -i "$KEY_PATH" -o StrictHostKeyChecking=no -r /home/palmu/Assignment5/* ubuntu@$EC2_IP:/home/ubuntu/app/

# Connect to EC2 and run the application
echo "Installing dependencies and starting services..."
ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no ubuntu@$EC2_IP << 'EOF'
cd /home/ubuntu/app

# Stop any existing services
pm2 stop all 2>/dev/null || true
pm2 delete all 2>/dev/null || true

# Install Python dependencies for backend
echo "Installing Python dependencies..."
cd backend
pip3 install -r requirements.txt
cd ..

# Install Node.js dependencies for frontend
echo "Installing Node.js dependencies..."
cd frontend
npm install
cd ..

# Start Flask backend
echo "Starting Flask backend..."
cd backend
pm2 start app.py --name backend --interpreter python3
cd ..

# Start Express frontend
echo "Starting Express frontend..."
cd frontend
pm2 start app.js --name frontend
cd ..

# Save pm2 process list and setup startup
pm2 save
pm2 startup

# Wait for services to start
echo "Waiting for services to start..."
sleep 10

# Check service status
echo "Service status:"
pm2 status

echo "Application logs (last 20 lines):"
pm2 logs --lines 20
EOF

echo "Deployment completed!"
echo "Your application should be accessible at:"
echo "- Frontend: http://$EC2_IP:3000"
echo "- Backend API: http://$EC2_IP:8000"
echo "- MongoDB: mongodb://$EC2_IP:27017"
echo ""
echo "To check status: ssh -i $KEY_PATH ubuntu@$EC2_IP 'pm2 status'"
echo "To view logs: ssh -i $KEY_PATH ubuntu@$EC2_IP 'pm2 logs'"
echo "To restart services: ssh -i $KEY_PATH ubuntu@$EC2_IP 'pm2 restart all'"
