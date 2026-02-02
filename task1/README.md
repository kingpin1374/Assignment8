# Assignment5 AWS Deployment Guide (Simple - No Docker)

This guide will help you deploy your Flask backend and Express frontend application to AWS EC2 using a simple setup without Docker.

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform installed
3. An AWS key pair named "mykey" (or update the key_name in main.tf)
4. Your Assignment5 code ready for deployment

## Quick Deployment Steps

### 1. Initialize Terraform

```bash
cd /home/palmu/Terraform-tasks/task1
terraform init
```

### 2. Plan and Apply Infrastructure

```bash
# Review the deployment plan
terraform plan

# Deploy the infrastructure
terraform apply
```

### 3. Get EC2 Instance IP

After terraform apply completes, you'll see the public IP in the output, or run:

```bash
terraform output instance_public_ip
```

### 4. Deploy Your Application

Use the deployment script with your EC2 public IP:

```bash
chmod +x deploy.sh
./deploy.sh <EC2_PUBLIC_IP> [PATH_TO_YOUR_KEY.pem]
```

Example:
```bash
./deploy.sh 3.108.45.123 ~/.ssh/mykey.pem
```

## What Gets Installed

The EC2 instance will automatically have:
- **Python 3** with pip for the Flask backend
- **Node.js 18** for the Express frontend
- **MongoDB** database server
- **PM2** process manager to keep your services running

## Access Your Application

Once deployed, your application will be accessible at:

- **Frontend**: http://<EC2_PUBLIC_IP>:3000
- **Backend API**: http://<EC2_PUBLIC_IP>:8000
- **MongoDB**: mongodb://<EC2_PUBLIC_IP>:27017

## Manual Deployment (Alternative)

If you prefer manual deployment instead of using the script:

```bash
# SSH into your EC2 instance
ssh -i ~/.ssh/mykey.pem ubuntu@<EC2_PUBLIC_IP>

# Once connected:
cd /home/ubuntu/app

# Install backend dependencies
cd backend
pip3 install -r requirements.txt
cd ..

# Install frontend dependencies
cd frontend
npm install
cd ..

# Start services with PM2
pm2 start backend/app.py --name backend --interpreter python3
pm2 start frontend/app.js --name frontend
pm2 save
pm2 startup
```

## Service Management

### Check Service Status
```bash
ssh -i ~/.ssh/mykey.pem ubuntu@<EC2_PUBLIC_IP> 'pm2 status'
```

### View Logs
```bash
ssh -i ~/.ssh/mykey.pem ubuntu@<EC2_PUBLIC_IP> 'pm2 logs'
```

### Restart Services
```bash
ssh -i ~/.ssh/mykey.pem ubuntu@<EC2_PUBLIC_IP> 'pm2 restart all'
```

### Stop Services
```bash
ssh -i ~/.ssh/mykey.pem ubuntu@<EC2_PUBLIC_IP> 'pm2 stop all'
```

### Monitor MongoDB
```bash
ssh -i ~/.ssh/mykey.pem ubuntu@<EC2_PUBLIC_IP> 'sudo systemctl status mongod'
```

## Troubleshooting

### Common Issues

1. **Port not accessible**: Check security group rules in AWS console
2. **Service fails to start**: Check logs with `pm2 logs`
3. **MongoDB not running**: Check with `sudo systemctl status mongod`
4. **Dependencies missing**: Ensure pip3 and npm are installed

### Restart MongoDB
```bash
ssh -i ~/.ssh/mykey.pem ubuntu@<EC2_PUBLIC_IP> 'sudo systemctl restart mongod'
```

### Update Application Code
```bash
# Copy new files
scp -i ~/.ssh/mykey.pem -r /path/to/Assignment5/* ubuntu@<EC2_PUBLIC_IP>:/home/ubuntu/app/

# Restart services
ssh -i ~/.ssh/mykey.pem ubuntu@<EC2_PUBLIC_IP> 'pm2 restart all'
```

## Security Considerations

- The current configuration opens ports to the internet (0.0.0.0/0)
- For production, consider restricting access to your IP only
- Change default MongoDB credentials
- Use environment variables for sensitive data
- Keep your EC2 instance updated with security patches

## File Structure on EC2

```
/home/ubuntu/app/
├── backend/
│   ├── app.py
│   ├── requirements.txt
│   └── ...
├── frontend/
│   ├── app.js
│   ├── package.json
│   └── views/
│       └── index.ejs
└── ...
```

## Cleanup

To destroy all resources when done:

```bash
terraform destroy
```

This will remove the EC2 instance, security group, and all other AWS resources created by this configuration.
