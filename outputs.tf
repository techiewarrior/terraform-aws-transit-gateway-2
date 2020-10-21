output "shared-public-ip" {
  value = aws_instance.test-tgw-instance3-shared.public_ip
}

output "dev-1-private-ip" {
  value = aws_instance.test-tgw-instance1-dev.private_ip
}

output "dev-2-private-ip" {
  value = aws_instance.test-tgw-instance2-dev.private_ip
}