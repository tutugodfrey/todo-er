resource "aws_vpc" "todo-app-vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags =  {
    Name = "todo-app-vpc"
  }
}

resource "aws_subnet" "todo-app-public-subnet-a" {
  cidr_block  = var.public_subnet_a_cidr
  vpc_id = aws_vpc.todo-app-vpc.id
  availability_zone = "${var.region}a"
  tags = {
    Name = "todo-app-public-subnet-a"
  }
}

resource "aws_subnet" "todo-app-private-subnet-a" {
  cidr_block = var.private_subnet_a_cidr
  vpc_id = aws_vpc.todo-app-vpc.id
  availability_zone = "${var.region}a"

  tags = {
    Name = "todo-app-private-subnety-a"
  }
}

resource "aws_subnet" "todo-app-public-subnet-b" {
  cidr_block = var.public_subnet_b_cidr
  vpc_id = aws_vpc.todo-app-vpc.id
  availability_zone = "${var.region}b"
  tags = {
    Name = "todo-app-public-subnet-b"
  }
}

resource "aws_subnet" "todo-app-private-subnet-b" {
  cidr_block = var.private_subnet_b_cidr
  vpc_id = aws_vpc.todo-app-vpc.id
  availability_zone = "${var.region}b"

  tags = {
    Name = "todo-app-private-subnet-b"
  }
}

resource "aws_route_table" "todo-app-public-route-table" {
  vpc_id = aws_vpc.todo-app-vpc.id
  tags = {
    Name = "todo-app-public-route-table"
  }
}

resource "aws_route_table" "todo-app-private-route-table" {
  vpc_id = aws_vpc.todo-app-vpc.id
  tags = {
    Name = "todo-app-private-route-table"
  }  
}

resource "aws_route_table_association" "todo-app-public-subnet-a-association" {
  route_table_id = aws_route_table.todo-app-public-route-table.id
  subnet_id = aws_subnet.todo-app-public-subnet-a.id
}

resource "aws_route_table_association" "todo-app-public-subnet-b-association" {
  route_table_id = aws_route_table.todo-app-public-route-table.id
  subnet_id = aws_subnet.todo-app-public-subnet-b.id
}

resource "aws_route_table_association" "todo-app-private-subnet-a-association" {
  route_table_id = aws_route_table.todo-app-private-route-table.id
  subnet_id = aws_subnet.todo-app-private-subnet-a.id
}

resource "aws_route_table_association" "todo-app-private-subnet-b-association" {
  route_table_id = aws_route_table.todo-app-private-route-table.id
  subnet_id = aws_subnet.todo-app-private-subnet-b.id
}

resource "aws_internet_gateway" "todo-app-igw" {
  vpc_id = aws_vpc.todo-app-vpc.id
  
  tags = {
    Name = "todo-app-igw"
  }
}

resource "aws_route" "todo-app-igw-route" {
  route_table_id = aws_route_table.todo-app-public-route-table.id
  gateway_id = aws_internet_gateway.todo-app-igw.id
  destination_cidr_block = var.public_cidr
}

