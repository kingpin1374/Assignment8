# Frontend and Backend Deployment with Terraform and Ansible

This project deploys a Flask backend and Nginx frontend on AWS EC2 instances using Terraform for infrastructure and Ansible for configuration.

## 🏗️ Architecture

- **Backend**: Flask application running on EC2 (port 8000)
- **Frontend**: Nginx web server serving HTML/JavaScript (ports 80 & 3000)
- **Database**: MongoDB (if configured)
- **Load Balancer**: Nginx acts as reverse proxy for API calls

## 📋 Prerequisites

1. **AWS CLI** configured with credentials
2. **Terraform** installed
3. **Ansible** installed
4. **SSH key pair** (`~/.ssh/mykey_rsa`) or update the inventory

## 🚀 Quick Deployment

### 1. Initialize and Apply Terraform

```bash
cd /home/palmu/Terraform-tasks/task2

# Initialize Terraform
terraform init

# Apply infrastructure (will prompt for AWS credentials)
terraform apply -auto-approve
```

### 2. Deploy Applications

```bash
# Use the automated deployment script
./deploy.sh
```

Or deploy manually:

```bash
# Update inventory with new IPs (automatically done by deploy.sh)
# Then run playbooks
ansible-playbook -i inventory backend.yaml
ansible-playbook -i inventory frontend.yaml
```

## 📁 File Structure

```
task2/
├── main.tf              # Terraform infrastructure
├── variables.tf         # Terraform variables
├── outputs.tf           # Terraform outputs
├── backend.yaml         # Ansible backend playbook
├── frontend.yaml        # Ansible frontend playbook
├── nginx.conf           # Nginx configuration
├── inventory            # Ansible inventory
├── deploy.sh            # Automated deployment script
└── README.md           # This file
```

## 🔧 Configuration

### Backend (Flask)
- **Location**: `/opt/backend/`
- **Service**: `flask-backend` (systemd)
- **Port**: 8000
- **Dependencies**: Flask, flask-cors, pymongo

### Frontend (Nginx)
- **Location**: `/var/www/html/`
- **Service**: `nginx` (systemd)
- **Ports**: 80, 3000
- **API Proxy**: `/api/` → `backend:8000/process`

## 🌐 Access Points

After deployment, access your application at:

- **Primary Frontend**: `http://<frontend-ip>:3000`
- **Alternative Frontend**: `http://<frontend-ip>` (if port 80 accessible)
- **Backend API**: `http://<backend-ip>:8000/process`
- **Via Frontend API**: `http://<frontend-ip>:3000/api/`

## 🔒 Security Groups

The deployment automatically configures security groups for:

- **Backend**: SSH (22), Flask app (8000)
- **Frontend**: SSH (22), HTTP (80), Alternative HTTP (3000)

## 🛠️ Manual Operations

### Check Service Status

```bash
# Backend
ansible -i inventory web_servers -m shell -a "systemctl status flask-backend"

# Frontend
ansible -i inventory frontend_servers -m shell -a "systemctl status nginx"
```

### Restart Services

```bash
# Backend
ansible -i inventory web_servers -m systemd -a "name=flask-backend state=restarted"

# Frontend
ansible -i inventory frontend_servers -m systemd -a "name=nginx state=restarted"
```

### View Logs

```bash
# Backend logs
ansible -i inventory web_servers -m shell -a "journalctl -u flask-backend -f"

# Frontend logs
ansible -i inventory frontend_servers -m shell -a "journalctl -u nginx -f"
```

## 🔍 Troubleshooting

### Common Issues

1. **SSH Connection Issues**
   - Ensure `~/.ssh/mykey_rsa` exists and matches the AWS key pair
   - Check security group allows SSH (port 22)

2. **Backend Not Starting**
   - Check Python dependencies: `pip list` in virtual environment
   - Verify systemd service: `systemctl status flask-backend`
   - Check logs: `journalctl -u flask-backend`

3. **Frontend Not Accessible**
   - Verify Nginx is running: `systemctl status nginx`
   - Check security groups allow ports 80 and 3000
   - Test locally: `curl http://localhost` on the frontend instance

4. **API Calls Failing**
   - Verify backend is accessible from frontend
   - Check nginx proxy configuration
   - Test API directly: `curl http://backend-ip:8000/process`

### Debug Commands

```bash
# Test connectivity between instances
ansible -i inventory frontend_servers -m shell -a "curl -I http://<backend-ip>:8000"

# Check nginx configuration
ansible -i inventory frontend_servers -m shell -a "nginx -t"

# Verify virtual environment
ansible -i inventory web_servers -m shell -a "/opt/backend/venv/bin/pip list"
```

## 🔄 Redeployment

To redeploy applications without recreating infrastructure:

```bash
# Update application code in /home/palmu/Assignment5/
# Then run:
./deploy.sh
```

To completely redeploy everything:

```bash
# Destroy infrastructure
terraform destroy -auto-approve

# Redeploy
terraform apply -auto-approve
./deploy.sh
```

## 📊 Monitoring

### Health Checks

```bash
# Backend health
curl -X POST http://<backend-ip>:8000/process \
  -H "Content-Type: application/json" \
  -d '{"name":"health","email":"check@test.com"}'

# Frontend health
curl -I http://<frontend-ip>:3000
```

### Service Status

```bash
# All services status
ansible -i inventory all -m shell -a "systemctl status nginx flask-backend || echo 'Service not found'"
```

## 🎯 Features

- **Automated Deployment**: One-command deployment with `deploy.sh`
- **Service Management**: Systemd services for auto-restart
- **Load Balancing**: Nginx reverse proxy for API calls
- **Security**: Properly configured security groups
- **Monitoring**: Health checks and logging
- **Scalability**: Easy to add more instances
- **Idempotent**: Ansible playbooks can be run multiple times

## 📝 Notes

- The deployment uses Ubuntu 20.04+ AMI
- Backend runs as a systemd service for reliability
- Frontend serves on multiple ports for accessibility
- All configurations are idempotent and safe to rerun
- Security groups are automatically updated during deployment
