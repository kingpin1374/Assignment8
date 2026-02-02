output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.myapp.public_ip
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.myapp.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.app_sg.id
}