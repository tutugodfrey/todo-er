output "vpc_id" {
  value = aws_vpc.todo-app-vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.todo-app-vpc.cidr_block
}

output "public_subnet_a" {
  value = aws_subnet.todo-app-public-subnet-a.id
}

output "public_subnet_b" {
  value = aws_subnet.todo-app-public-subnet-b.id
}

output "private_subnet_a" {
  value = aws_subnet.todo-app-private-subnet-a.id
}

output "private_subnet_b" {
  value = aws_subnet.todo-app-private-subnet-b.id
}

output "public_route_table" {
  value = aws_route_table.todo-app-public-route-table.id
}

output "private_route_table" {
  value = aws_route_table.todo-app-private-route-table.id
}
