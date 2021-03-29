## Terraform Outputs

output "jump_server_public_ip" {
  value = aws_instance.todo-app-jump-server.*.public_ip
}

output "jump_server_public_dns" {
  value = aws_instance.todo-app-jump-server.*.public_dns
}

output "lb_server_public_ip" {
  value = aws_instance.todo-app-lb-server.*.public_ip
}

output "lb_server_public_eip" {
  value = aws_eip.todo-app-lb-eip.public_ip
}

output "lb_server_public_eip_dns" {
  value = aws_eip.todo-app-lb-eip.public_dns
}

output "lb_server_public_dns" {
  value = aws_instance.todo-app-lb-server.*.public_dns
}

output "jenkins_server_public_ip" {
  value = aws_instance.todo-app-jenkins-server.*.public_ip
}

output "jenkins_server_public_dns" {
  value = aws_instance.todo-app-jenkins-server.*.public_dns
}

output "storage_server_private_ip" {
  value = aws_instance.todo-app-storage-server.*.private_ip
}

output "db_server_private_ip" {
  value = aws_instance.todo-app-db-server.*.private_ip
}

output "app1_server_private_ip" {
  value = aws_instance.todo-app-server-1.*.private_ip
}

output "app2_server_private_ip" {
  value = aws_instance.todo-app-server-2.*.private_ip
}

# Running output terraform command
# terraform output lb_server_public_ip