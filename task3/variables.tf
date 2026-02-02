variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "assignment5"
}

variable "environment" {
  description = "The environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "The CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "frontend_container_cpu" {
  description = "The CPU units to allocate to the frontend container"
  type        = number
  default     = 256
}

variable "frontend_container_memory" {
  description = "The memory to allocate to the frontend container"
  type        = number
  default     = 512
}

variable "backend_container_cpu" {
  description = "The CPU units to allocate to the backend container"
  type        = number
  default     = 256
}

variable "backend_container_memory" {
  description = "The memory to allocate to the backend container"
  type        = number
  default     = 512
}

variable "frontend_desired_count" {
  description = "The number of instances of the frontend task to run"
  type        = number
  default     = 1
}

variable "backend_desired_count" {
  description = "The number of instances of the backend task to run"
  type        = number
  default     = 1
}

variable "frontend_port" {
  description = "The port the frontend container listens on"
  type        = number
  default     = 3000
}

variable "backend_port" {
  description = "The port the backend container listens on"
  type        = number
  default     = 8000
}

variable "alb_port" {
  description = "The port the load balancer listens on"
  type        = number
  default     = 80
}
