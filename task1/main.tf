terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
  }
}

provider "aws" {
  region     = "ap-south-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_security_group" "app_sg" {
  name        = "app-security-group"
  description = "Allow web traffic and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "myapp" {
  ami           = "ami-019715e0d74f695be"
  instance_type = "t3.micro"
  key_name      = "mykey"
  security_groups = [aws_security_group.app_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              
              # Install Python 3 and pip
              apt-get install -y python3 python3-pip git
              
              # Install Node.js 18
              curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
              apt-get install -y nodejs
              
              # Install MongoDB
              wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add -
              echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list
              apt-get update -y
              apt-get install -y mongodb-org
              
              # Start MongoDB
              systemctl start mongod
              systemctl enable mongod
              
              # Create app directory
              mkdir -p /home/ubuntu/app
              cd /home/ubuntu/app
              
              # Install pm2 for process management
              npm install -g pm2
              
              # Create startup script
              cat > start_services.sh << 'EOL'
#!/bin/bash
cd /home/ubuntu/app

# Start Flask backend
cd backend
pip3 install -r requirements.txt
pm2 start app.py --name backend --interpreter python3

# Start Express frontend
cd ../frontend
npm install
pm2 start app.js --name frontend

# Save pm2 process list
pm2 save
pm2 startup
EOL
              
              chmod +x start_services.sh
              EOF

  tags = {
    Name = "Assignment5-App"
  }
}
resource "aws_s3_bucket" "mybucket" {
  bucket = "my-app-${random_id.bucket_suffix.hex}"
  acl    = "private"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}
