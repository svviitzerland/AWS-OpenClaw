output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.openclaw.id
}

output "instance_public_ip" {
  description = "Public IP address"
  value       = var.use_elastic_ip ? aws_eip.openclaw[0].public_ip : aws_instance.openclaw.public_ip
}

output "openclaw_url" {
  description = "OpenClaw web interface URL"
  value       = "http://${var.use_elastic_ip ? aws_eip.openclaw[0].public_ip : aws_instance.openclaw.public_ip}:${var.openclaw_port}"
}

output "ssh_command" {
  description = "SSH command to connect to instance"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${var.use_elastic_ip ? aws_eip.openclaw[0].public_ip : aws_instance.openclaw.public_ip}"
}
