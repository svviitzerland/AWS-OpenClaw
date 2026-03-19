variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "openclaw"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t4g.micro"
}

variable "key_name" {
  description = "SSH key pair name in AWS"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_web_cidr" {
  description = "CIDR blocks allowed for web access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "openclaw_port" {
  description = "OpenClaw web interface port"
  type        = number
  default     = 8080
}

variable "openclaw_version" {
  description = "OpenClaw Docker image version"
  type        = string
  default     = "latest"
}

variable "openrouter_api_key" {
  description = "OpenRouter API key"
  type        = string
  sensitive   = true
}

variable "use_spot_instance" {
  description = "Use spot instance for lower cost"
  type        = bool
  default     = false
}

variable "spot_max_price" {
  description = "Maximum spot instance price per hour"
  type        = string
  default     = "0.01"
}

variable "use_elastic_ip" {
  description = "Allocate Elastic IP for static address"
  type        = bool
  default     = true
}
