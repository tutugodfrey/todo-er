output "nat-instance-sg" {
  value = aws_security_group.todo-app-nat-instance-sg.id
}

output "web-access-sg" {
  value = aws_security_group.todo-app-web-access-sg.id
}

output "external-ssh-sg" {
  value = aws_security_group.todo-app-external-ssh-sg.id
}

output "db-server-sg" {
  value = aws_security_group.todo-app-db-server-sg.id
}

output "metric-server-sg" {
  value = aws_security_group.todo-app-metric-server-sg.id
}
