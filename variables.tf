variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "alert_email" {
  description = "Email address to receive CPU alarm notifications"
  type        = string
  # Điền email của bạn vào terraform.tfvars
}
