output "flask_backend_public_ip" {
  description = "Public IP address of the Flask backend instance"
  value       = aws_instance.flask_backend.public_ip
}

output "flask_backend_private_ip" {
  description = "Private IP address of the Flask backend instance"
  value       = aws_instance.flask_backend.private_ip
}

output "express_frontend_public_ip" {
  description = "Public IP address of the Express frontend instance"
  value       = aws_instance.express_frontend.public_ip
}

output "express_frontend_private_ip" {
  description = "Private IP address of the Express frontend instance"
  value       = aws_instance.express_frontend.private_ip
}

output "flask_backend_url" {
  description = "URL to access the Flask backend"
  value       = "http://${aws_instance.flask_backend.public_ip}:8000"
}

output "express_frontend_url" {
  description = "URL to access the Express frontend"
  value       = "http://${aws_instance.express_frontend.public_ip}:3000"
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "flask_security_group_id" {
  description = "ID of the Flask backend security group"
  value       = aws_security_group.flask_sg.id
}

output "express_security_group_id" {
  description = "ID of the Express frontend security group"
  value       = aws_security_group.express_sg.id
}
