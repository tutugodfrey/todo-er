output "server_public_ip" {
  value = aws_instance.ec2-instance.*.public_ip
}

output "server_public_dns" {
  value = aws_instance.ec2-instance.*.public_dns
}

output "server_private_ip" {
  value = aws_instance.ec2-instance.*.private_ip
}
