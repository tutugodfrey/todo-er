## Terraform Outputs

output "jump_server_public_ip" {
  value = module.jump-server.server_public_ip
}

output "jump_server_public_dns" {
  value = module.jump-server.server_public_dns
}

output "lb_server_public_ip" {
  value = module.lb-server.server_public_ip
}

#output "lb_server_public_eip" {
#  value = aws_eip.todo-app-lb-eip.public_ip
#}

#output "lb_server_public_eip_dns" {
#  value = aws_eip.todo-app-lb-eip.public_dns
#} 

output "lb_server_public_dns" {
  value = module.lb-server.server_public_dns
}

output "jenkins_server_public_ip" {
  value = module.jenkins-server.server_public_ip
}

output "jenkins_server_public_dns" {
  value = module.jenkins-server.server_public_dns
}

output "storage_server_private_ip" {
  value = module.storage-server.server_private_ip
}

output "db_server_private_ip" {
  value = module.db-server.server_private_ip
}

output "app1_server_private_ip" {
  value = module.app-server-1.server_private_ip
}

output "app2_server_private_ip" {
  value = module.app-server-2.server_private_ip
}

output "metrics_server_public_ip" {
  value = module.metrics-server.server_public_ip
}

output "metrics_server_public_dns" {
  value = module.metrics-server.server_public_dns
}

output "metrics_server_private_ip" {
  value = module.metrics-server.server_private_ip
}


output "nat_instance_private_ip" {
  value = aws_instance.todo-app-nat-instance.*.private_ip
}

output "nat_instance_public_ip" {
  value = aws_instance.todo-app-nat-instance.*.public_ip
}

# Running output terraform command
# terraform output lb_server_public_ip