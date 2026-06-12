terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.aws_region
}

# -----------------------------------------------
# SNS Topic
# -----------------------------------------------
resource "aws_sns_topic" "cpu_alarm_topic" {
  name = "cpu-alarm-topic"
}

# -----------------------------------------------
# SNS Email Subscription
# -----------------------------------------------
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.cpu_alarm_topic.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# -----------------------------------------------
# EC2 Instance (để demo alarm)
# -----------------------------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "cpu-alarm-ec2-sg"
  description = "Security group for CPU alarm demo EC2"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "demo" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # Script stress test CPU khi khởi động (tuỳ chọn để trigger alarm)
  user_data = <<-EOF
    #!/bin/bash
    yum install -y stress
    # Uncomment dòng dưới để tự trigger alarm ngay:
    # stress --cpu 2 --timeout 400 &
  EOF

  tags = {
    Name = "cpu-alarm-demo"
  }
}

# -----------------------------------------------
# CloudWatch Alarm: CPU > 80% trong 5 phút
# -----------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "ec2-cpu-high-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300   # 5 phút (300 giây)
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alarm when EC2 CPU exceeds 80% for 5 consecutive minutes"
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.demo.id
  }

  # Gửi alert khi vào trạng thái ALARM
  alarm_actions = [aws_sns_topic.cpu_alarm_topic.arn]

  # Gửi alert recovery khi trở về trạng thái OK
  ok_actions = [aws_sns_topic.cpu_alarm_topic.arn]
}
