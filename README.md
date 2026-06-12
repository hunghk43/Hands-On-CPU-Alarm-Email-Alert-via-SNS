# CPU Alarm → Email Alert via SNS

## Mục tiêu
Gửi email cảnh báo khi CPU của EC2 > 80% trong 5 phút liên tiếp.

## Các bước thực hiện

### 1. Chuẩn bị
- Cài [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.3
- Cấu hình AWS credentials: `aws configure`

### 2. Điền email nhận alert
Mở file `terraform.tfvars` và thay email:
```
alert_email = "your-email@example.com"
```

### 3. Triển khai
```bash
terraform init
terraform plan
terraform apply
```

### 4. Xác nhận SNS Subscription (BẮT BUỘC)
Sau khi `apply` xong, AWS sẽ gửi email **"AWS Notification - Subscription Confirmation"**.
Bạn phải click vào link **"Confirm subscription"** trong email đó thì mới nhận được alert.

### 5. Test thử alarm (tuỳ chọn)
SSH vào EC2 và chạy stress test:
```bash
sudo yum install -y stress
stress --cpu 2 --timeout 400 &
```
Sau ~5 phút CPU cao, bạn sẽ nhận được email cảnh báo.

### 6. Dọn dẹp
```bash
terraform destroy
```

## Tài nguyên được tạo
| Resource | Tên |
|---|---|
| SNS Topic | cpu-alarm-topic |
| SNS Subscription | Email của bạn |
| EC2 Instance | cpu-alarm-demo (t2.micro) |
| CloudWatch Alarm | ec2-cpu-high-alarm |
