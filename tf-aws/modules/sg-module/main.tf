### MANAGE SECURITY GROUPS
# Nat instance security group
resource "aws_security_group" "todo-app-nat-instance-sg" {
  name = "todo-app-nat-instance-sg"
  vpc_id = var.vpc-id
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.private_subnet_a_cidr, var.private_subnet_b_cidr]
  }
  egress {
    from_port = 0
    to_port = 0
    cidr_blocks = [var.public_cidr]
    protocol = "-1"
  }
  tags = {
    Name = "todo-app-nat-instance-sg"
  }
}

resource "aws_security_group" "todo-app-web-access-sg" {
  name = "todo-app-web-access-sg"
  vpc_id = var.vpc-id
  tags = {
    Name = "todo-app-web-access-sg"
  }
}

resource "aws_security_group_rule" "allow-port-all-egress" {
  type = "egress"
  from_port = 0
  to_port = 0
  cidr_blocks = [var.public_cidr]
  protocol = "-1"
  security_group_id = aws_security_group.todo-app-web-access-sg.id
}

resource "aws_security_group_rule" "allow_port_80" {
  type = "ingress"
  from_port = 80
  to_port = 80
  cidr_blocks = [var.public_cidr]
  protocol = "tcp"
  security_group_id = aws_security_group.todo-app-web-access-sg.id
}

resource "aws_security_group_rule" "allow-port-8080" {
  type = "ingress"
  from_port = 8080
  to_port = 8080
  cidr_blocks = [var.public_cidr]
  protocol = "tcp"
  security_group_id = aws_security_group.todo-app-web-access-sg.id
}

resource "aws_security_group_rule" "allow-port-443" {
  type = "ingress"
  from_port = 443
  to_port = 443
  cidr_blocks = [var.public_cidr]
  protocol = "tcp"
  security_group_id = aws_security_group.todo-app-web-access-sg.id
}

resource "aws_security_group_rule" "allow-icmp" {
  type = "ingress"
  from_port = -1
  to_port = -1
  cidr_blocks = [var.public_cidr]
  protocol = "icmp"
  security_group_id = aws_security_group.todo-app-web-access-sg.id
}

## Allow ssh betten servers in the network
resource "aws_security_group_rule" "todo-app-internal-ssh-sg" {
  type = "ingress"
  from_port = 22
  to_port = 22
  cidr_blocks = [var.vpc_cidr_block]
  protocol = "tcp"
  security_group_id = aws_security_group.todo-app-web-access-sg.id
}

## Puppetserver sg
resource "aws_security_group_rule" "todo-app-puppet-sg" {
  type = "ingress"
  from_port = 0
  to_port = 8140
  cidr_blocks = [var.vpc_cidr_block]
  protocol = "tcp"
  security_group_id = aws_security_group.todo-app-web-access-sg.id
}

## NFS port 2049 for tcp 
resource "aws_security_group_rule" "todo-app-allow-nfs-tcp" {
  type = "ingress"
  from_port = 2049
  to_port = 2049
  cidr_blocks = [var.vpc_cidr_block]
  protocol = "tcp"
  security_group_id = aws_security_group.todo-app-web-access-sg.id
}

# NFS port 2049 for udp
resource "aws_security_group_rule" "todo-app-allow-nfs-udp" {
  type = "ingress"
  from_port = 2049
  to_port = 2049
  cidr_blocks = [var.vpc_cidr_block]
  protocol = "udp"
  security_group_id = aws_security_group.todo-app-web-access-sg.id
}

# Allow ssh connection from external network. 
# Should only be attached to Admin servers. e.g Jump server and metric server
resource "aws_security_group" "todo-app-external-ssh-sg" {
  vpc_id = var.vpc-id
  name = "todo-app-external-ssh-sg"
  ingress {
    from_port = 22
    to_port = 22
    cidr_blocks = [var.public_cidr]
    protocol = "tcp"
  }
  tags = {
    Name = "todo-app-external-ssh-sg"
  }
}

## SG to access DB server within the network
resource "aws_security_group" "todo-app-db-server-sg" {
  name = "todo-app-db-server-sg"
  vpc_id = var.vpc-id

  ingress {
    from_port = 0
    to_port  = 5432
    cidr_blocks = [var.vpc_cidr_block]
    protocol = "tcp"
  }
  tags = {
    Name = "todo-app-db-server-sg"
  }
}

resource "aws_security_group" "todo-app-metric-server-sg" {
  name = "todo-app-metric-server-sg"
  vpc_id = var.vpc-id
  tags = {
    Name = "todo-app-metric-server-sg"
  }
}

resource "aws_security_group_rule" "allow-prometheus-port-9090" {
  type = "ingress"
  from_port = 9090
  to_port = 9090
  cidr_blocks = [var.public_cidr]
  protocol = "tcp"
  security_group_id = aws_security_group.todo-app-metric-server-sg.id
}

resource "aws_security_group_rule" "allow-node-exporter-port-9100" {
  type = "ingress"
  from_port = 9100
  to_port = 9100
  cidr_blocks = [var.public_cidr]
  protocol = "tcp"
  security_group_id = aws_security_group.todo-app-metric-server-sg.id
}

resource "aws_security_group_rule" "allow-grafana-port-3000" {
  type = "ingress"
  from_port = 3000
  to_port = 3000
  cidr_blocks = [var.public_cidr]
  protocol = "tcp"
  security_group_id = aws_security_group.todo-app-metric-server-sg.id
}

resource "aws_security_group_rule" "allow-zabbix-agent-port-10050" {
  type = "ingress"
  from_port = 10050
  to_port = 10050
  cidr_blocks = [var.public_cidr]
  protocol = "tcp"
  security_group_id = aws_security_group.todo-app-metric-server-sg.id
}

resource "aws_security_group_rule" "allow-zabbix-server-port-10051" {
  type = "ingress"
  from_port = 10051
  to_port = 10051
  cidr_blocks = [var.public_cidr]
  protocol = "tcp"
  security_group_id = aws_security_group.todo-app-metric-server-sg.id
}

resource "aws_security_group_rule" "allow-nagios-nrpe-port-5666" {
  type = "ingress"
  from_port = 5666
  to_port = 5666
  cidr_blocks = [var.public_cidr]
  protocol = "tcp"
  security_group_id = aws_security_group.todo-app-metric-server-sg.id
}
