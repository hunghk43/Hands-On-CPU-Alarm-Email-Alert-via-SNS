output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.cpu_alarm_topic.arn
}

output "ec2_instance_id" {
  description = "ID of the demo EC2 instance"
  value       = aws_instance.demo.id
}

output "cloudwatch_alarm_name" {
  description = "Name of the CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.cpu_high.alarm_name
}

output "subscription_note" {
  description = "Action required"
  value       = "Check your email (${var.alert_email}) and CONFIRM the SNS subscription to activate alerts."
}
