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
  destination_cidr_block = "0.0.0.0/0"
}

# ### CREATE A EC2 NAT GATEWAY INSTANCE
# resource "aws_eip" "todo-app-nat-eip" {
#   vpc = true
#   instance = aws_instance.todo-app-nat-instance.id

#   tags = {
#     Name = "todo-app-nat-instance-eip"
#   }
# }

# resource "aws_instance" "todo-app-nat-instance" {
#   ami = var.app_server_ami_id
#   instance_type = var.ec2_instance_type
#   subnet_id = aws_subnet.todo-app-public-subnet-b.id
#   tags = {
#     Name = "Todo App Nat Instance"
#   }
# }

### CREATE NAT GATEWAY (AWS MANAGE)
resource "aws_eip" "todo-app-nat-gateway-eip" {
  tags = {
    Name = "todo-app-nat-gateway-eip"
  }
}

resource "aws_nat_gateway" "todo-app-nat-gateway" {
  allocation_id = aws_eip.todo-app-nat-gateway-eip.id
  subnet_id = aws_subnet.todo-app-public-subnet-a.id

  tags = {
    Name = "todo-app-nat-gateway"
  }
}

resource "aws_route" "todo-app-nat-route" {
  route_table_id = aws_route_table.todo-app-private-route-table.id
  nat_gateway_id = aws_nat_gateway.todo-app-nat-gateway.id 
  destination_cidr_block = "0.0.0.0/0"
}

### MANAGE SECURITY GROUPS
resource "aws_security_group" "todo-app-web-access-sg" {
  name = "todo-app-web-access-sg"
  vpc_id = aws_vpc.todo-app-vpc.id

  ingress {
    from_port = 0
    to_port  = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "-1"
  }

  egress {
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "-1"
  }

  tags = {
    Name = "todo-app-web-access-sg"
  }
}

resource "aws_security_group" "todo-app-jenkins-server-sg" {
  name = "todo-app-jenkins-server-sg"
  vpc_id = aws_vpc.todo-app-vpc.id
}

resource "aws_security_group_rule" "allow-all-egress" {
  type = "egress"
  from_port = 0
  to_port = 0
  cidr_blocks = ["0.0.0.0/0"]
  protocol = "-1"
  security_group_id = aws_security_group.todo-app-jenkins-server-sg.id
}

resource "aws_security_group_rule" "allow_port_8080" {
  type = "ingress"
  from_port = 80
  to_port = 80
  cidr_blocks = ["0.0.0.0/0"]
  protocol = "tcp"
  security_group_id = aws_security_group.todo-app-jenkins-server-sg.id
}

resource "aws_security_group_rule" "allow-port-ssh" {
  type = "ingress"
  from_port = 22
  to_port = 22
  cidr_blocks = ["0.0.0.0/0"]
  protocol = "tcp"
  security_group_id = aws_security_group.todo-app-jenkins-server-sg.id
}

resource "aws_security_group_rule" "allow-port-8080" {
  type = "ingress"
  from_port = 8080
  to_port = 8080
  cidr_blocks = ["0.0.0.0/0"]
  protocol = "tcp"
  security_group_id = aws_security_group.todo-app-jenkins-server-sg.id
}

resource "aws_network_interface" "tod-app-server-1-eni" {
  # subnet_id = aws_subnet.todo-app-public-subnet-a.id
  subnet_id = aws_subnet.todo-app-private-subnet-a.id
  private_ips = [ var.app_server_1_private_ip ]
  security_groups = [ aws_security_group.todo-app-web-access-sg.id ]
  attachment {
    instance = aws_instance.todo-app-server-1.id
    device_index = 1
  }

  tags = {
    Name = "App server 1 eni"
  }
}

data "template_file" "user-data-app-server-1" {
  template = file("userdata.sh")
  vars = {
    NEW_HOSTNAME = var.app_server_1_hostname
    SERVER_IP = var.app_server_1_private_ip
    STORAGE_SERVER_IP = var.storage_server_private_ip
    STORAGE_SERVER_HOSTNAME = var.storage_server_hostname
    JUMP_SERVER_IP = var.jump_server_private_ip
    JUMP_SERVER_HOSTNAME = var.jump_server_hostname
    DB_SERVER_IP = var.db_server_private_ip
    DB_SERVER_HOSTNAME = var.db_server_hostname
    DB_NAME = var.db_name
    DB_USER_PASS = var.db_user_pass
    DB_USER_NAME = var.db_user_name 
    DB_PORT = var.db_port
  }
}

resource "aws_instance" "todo-app-server-1" {
  ami = var.app_server_ami_id
  instance_type = var.ec2_instance_type
  key_name = var.ec2_keypair
  security_groups = [aws_security_group.todo-app-web-access-sg.id]
  # subnet_id = aws_subnet.todo-app-public-subnet-a.id
  subnet_id = aws_subnet.todo-app-private-subnet-a.id
  user_data = data.template_file.user-data-app-server-1.rendered
  associate_public_ip_address = true

  tags = {
    Name = "App server 1"
  }
}

resource "aws_network_interface" "tod-app-server-2-eni" {
  subnet_id = aws_subnet.todo-app-public-subnet-b.id
  private_ips = [ var.app_server_2_private_ip ]
  security_groups = [ aws_security_group.todo-app-web-access-sg.id ]

  attachment {
    instance = aws_instance.todo-app-server-2.id
    device_index = 1
  }

  tags = {
    Name = "App server 2 eni"
  }
}

data "template_file" "user-data-app-server-2" {
  template = file("userdata.sh")
  vars = {
    NEW_HOSTNAME = var.app_server_2_hostname
    SERVER_IP = var.app_server_2_private_ip
    STORAGE_SERVER_IP = var.storage_server_private_ip
    STORAGE_SERVER_HOSTNAME = var.storage_server_hostname
    JUMP_SERVER_IP = var.jump_server_private_ip
    JUMP_SERVER_HOSTNAME = var.jump_server_hostname
    DB_SERVER_IP = var.db_server_private_ip
    DB_SERVER_HOSTNAME = var.db_server_hostname
    DB_NAME = var.db_name
    DB_USER_PASS = var.db_user_pass
    DB_USER_NAME = var.db_user_name
    DB_PORT = var.db_port
  }
}

resource "aws_instance" "todo-app-server-2" {
  ami = var.app_server_ami_id
  instance_type = var.ec2_instance_type
  key_name = var.ec2_keypair
  security_groups = [aws_security_group.todo-app-web-access-sg.id]
  subnet_id = aws_subnet.todo-app-public-subnet-b.id
  user_data = data.template_file.user-data-app-server-2.rendered
  associate_public_ip_address = true

  tags = {
    Name = "App Server 2"
  }
}

# SET UP A LOAD BALANCER SERVER
# provision an elastic ip for the load balancer
resource "aws_eip" "todo-app-lb-eip" {
  vpc = true
  instance = aws_instance.todo-app-lb-server.id

  tags = {
    Name = "LoadBalancer Server EIP"
  }
}

resource "aws_network_interface" "todo-app-lb-server-eni" {
  subnet_id = aws_subnet.todo-app-public-subnet-b.id
  private_ips = [var.lb_server_private_ip]
  security_groups = [ aws_security_group.todo-app-web-access-sg.id]

  attachment {
    instance = aws_instance.todo-app-lb-server.id
    device_index = 1
  }

  tags = {
    Name = "Load balancer eni"
  }
}

data "template_file" "user-data-lb-server" {
  template = file("userdata-lb.sh")
  vars = {
    NEW_HOSTNAME = var.lb_server_hostname
    APP_SERVER_1_HOSTNAME = var.app_server_1_hostname
    APP_SERVER_2_HOSTNAME = var.app_server_2_hostname
    APP_SERVER_1_IP = var.app_server_1_private_ip
    APP_SERVER_2_IP = var.app_server_2_private_ip
    JUMP_SERVER_IP = var.jump_server_private_ip
    JUMP_SERVER_HOSTNAME = var.jump_server_hostname
    STORAGE_SERVER_HOSTNAME = var.storage_server_hostname
    STORAGE_SERVER_IP = var.storage_server_private_ip
  }
}

resource "aws_instance" "todo-app-lb-server" {
  ami = var.app_server_ami_id
  instance_type = var.ec2_instance_type
  key_name = var.ec2_keypair
  security_groups = [aws_security_group.todo-app-web-access-sg.id]
  subnet_id = aws_subnet.todo-app-public-subnet-b.id
  user_data = data.template_file.user-data-lb-server.rendered
  associate_public_ip_address = true

  tags = {
    Name = "Load Balancer"
  }
}

# SET UP A JENKINS SERVER INSTANCE
resource "aws_network_interface" "todo-app-jenkins-server-eni" {
  subnet_id = aws_subnet.todo-app-public-subnet-b.id
  private_ips = [var.jenkins_server_private_ip]
  security_groups = [ aws_security_group.todo-app-web-access-sg.id]

  attachment {
    instance = aws_instance.todo-app-jenkins-server.id
    device_index = 1
  }

  tags = {
    Name = "Jenkins-eni"
  }
}

data "template_file" "jenkins-server-template" {
  template = file("userdata-jenkins.sh")
  vars  = {
    JENKINS_SERVER_HOSTNAME = var.jenkins_server_hostname
    JENKINS_SERVER_IP = var.jenkins_server_private_ip
    APP_SERVER_1_IP = var.app_server_1_private_ip
    APP_SERVER_1_HOSTNAME = var.app_server_1_hostname
    APP_SERVER_2_IP = var.app_server_2_private_ip
    APP_SERVER_2_HOSTNAME = var.app_server_2_hostname
    STORAGE_SERVER_IP = var.storage_server_private_ip
    STORAGE_SERVER_HOSTNAME = var.storage_server_hostname
    DB_SERVER_IP = var.db_server_private_ip
    DB_SERVER_HOSTNAME = var.db_server_hostname
    LB_SERVER_IP = var.lb_server_private_ip
    LB_SERVER_HOSTNAME =var.lb_server_hostname
    JUMP_SERVER_IP = var.jump_server_private_ip
    JUMP_SERVER_HOSTNAME = var.jump_server_hostname
    NAGIOS_ADMIN_PASSWD = var.nagios_admin_passwd
  }
}

resource "aws_instance" "todo-app-jenkins-server" {
  ami = var.jenkins_server_ami_id
  instance_type = var.ec2_instance_type
  key_name = var.ec2_keypair
  security_groups = [aws_security_group.todo-app-jenkins-server-sg.id]
  subnet_id = aws_subnet.todo-app-public-subnet-b.id
  user_data = data.template_file.jenkins-server-template.rendered
  associate_public_ip_address = true
  tags = {
    Name = "Jenkins server"
  }
}

# SET UP AN RDS DATABASE INSTANCE
# resource "aws_security_group" "todo-app-rds-security-group" {
#   name = "todo-app-rds-security-group"
#   vpc_id = aws_vpc.todo-app-vpc.id
# }

# resource "aws_security_group_rule" "rds-security-group" {
#   type = "ingress"
#   from_port = 0
#   to_port = 5432
#   cidr_blocks = [var.vpc_cidr_block]
#   security_group_id = aws_security_group.todo-app-rds-security-group.id
#   protocol = "tcp"
# }
# resource "aws_db_instance" "todo-app-db-instance" {
#   identifier = "todo-app-db-instance"
#   db_subnet_group_name = "default-${aws_vpc.todo-app-vpc.id}"
#   allocated_storage = 20
#   engine = "postgres"
#   engine_version = "12.5"
#   instance_class = "db.t2.micro"
#   name = "todo_app"
#   username = "tutug"
#   password =  "password123"
#   vpc_security_group_ids = [aws_security_group.todo-app-rds-security-group.id]
#   publicly_accessible = false
#   skip_final_snapshot = true
# }

## SETUP A DATABASE SERVER WITH POSTGRESQL
# resource "aws_security_group" "todo-app-db-server-sg" {
#   name = "todo-app-db-server-security-group"
#   vpc_id = aws_vpc.todo-app-vpc.id
# }

# resource "aws_security_group_rule" "db-server-sg-allow-5432" {
#   type = "ingress"
#   from_port = 0
#   to_port = 5432
#   cidr_blocks = [ var.vpc_cidr_block ]
#   security_group_id = aws_security_group.todo-app-db-server-sg.id
#   protocol = "tcp"
# }

# resource "aws_security_group_rule" "db-server-sg-allow-all-ingress" {
#   type = "ingress"
#   from_port = 0
#   to_port = 0
#   cidr_blocks = [ "0.0.0.0/0" ]
#   security_group_id = aws_security_group.todo-app-db-server-sg.id
#   protocol = "tcp"
# }

resource "aws_security_group" "todo-app-db-server-sg" {
  name = "todo-app-db-server-sg"
  vpc_id = aws_vpc.todo-app-vpc.id

  ingress {
    from_port = 0
    to_port  = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "-1"
  }

  egress {
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "-1"
  }

  tags = {
    Name = "todo-app-db-server-sg"
  }
}

resource "aws_network_interface" "todo-app-db-server-eni" {
  subnet_id = aws_subnet.todo-app-private-subnet-b.id
  private_ips = [var.db_server_private_ip]
  security_groups = [ aws_security_group.todo-app-db-server-sg.id ]
  # security_groups = [ aws_security_group.todo-app-web-access-sg.id,
    # aws_security_group.todo-app-db-server-sg.id ]
  attachment {
    instance = aws_instance.todo-app-db-server.id
    device_index = 1
  }

  tags = {
    Name = "DB-server eni"
  }
}

data "template_file" "db-server-template-file" {
  template = file("userdata-db.sh")
  vars = {
    VPC_CIDR_BLOCK = var.vpc_cidr_block
    DB_SERVER_IP = var.db_server_private_ip
    DB_SERVER_HOSTNAME = var.db_server_hostname
    JUMP_SERVER_IP = var.jump_server_private_ip
    JUMP_SERVER_HOSTNAME = var.jump_server_hostname
    DB_NAME = var.db_name
    DB_USER_PASS = var.db_user_pass
    DB_USER_NAME = var.db_user_name
    DB_PORT = var.db_port
  }
}
resource "aws_instance" "todo-app-db-server" {
  ami = var.app_server_ami_id
  instance_type = var.ec2_instance_type
  key_name = var.ec2_keypair
  subnet_id = aws_subnet.todo-app-private-subnet-b.id
  security_groups = [ aws_security_group.todo-app-db-server-sg.id ]
  # security_groups = [ aws_security_group.todo-app-web-access-sg.id,
  #   aws_security_group.todo-app-db-server-sg.id ]
  associate_public_ip_address = true
  user_data = data.template_file.db-server-template-file.rendered

  tags = {
    Name = "DB Server"
  }
}

## SET UP A STORAGE SERVER
resource "aws_network_interface" "todo-app-storage-server-eni" {
  subnet_id = aws_subnet.todo-app-public-subnet-b.id
  private_ips = [var.storage_server_private_ip]
  security_groups = [ aws_security_group.todo-app-web-access-sg.id ]

  attachment {
    instance = aws_instance.todo-app-storage-server.id
    device_index = 1
  }

  tags = {
    Name = "Storage server network interface"
  }
}

data "template_file" "storage-server-template-file" {
  template = file("userdata-storage.sh")
  vars = {
    APP_SERVER_1_IP = var.app_server_1_private_ip
    APP_SERVER_1_HOSTNAME = var.app_server_1_hostname
    APP_SERVER_2_IP = var.app_server_2_private_ip
    APP_SERVER_2_HOSTNAME = var.app_server_2_hostname
    LB_SERVER_IP = var.lb_server_private_ip
    LB_SERVER_HOSTNAME = var.lb_server_hostname
    JENKINS_SERVER_IP = var.jenkins_server_private_ip
    JENKINS_SERVER_HOSTNAME = var.jenkins_server_hostname
    STORAGE_SERVER_IP = var.storage_server_private_ip
    STORAGE_SERVER_HOSTNAME = var.storage_server_hostname
    JUMP_SERVER_IP = var.jump_server_private_ip
    JUMP_SERVER_HOSTNAME = var.jump_server_hostname
    DB_SERVER_IP = var.db_server_private_ip
    DB_SERVER_HOSTNAME = var.db_server_hostname
    DB_NAME = var.db_name
    DB_USER_PASS = var.db_user_pass
    DB_USER_NAME = var.db_user_name
    DB_PORT = var.db_port
  }
}

resource "aws_instance" "todo-app-storage-server" {
  ami = var.app_server_ami_id
  instance_type = var.ec2_instance_type
  key_name = var.ec2_keypair
  subnet_id = aws_subnet.todo-app-public-subnet-b.id
  security_groups = [ aws_security_group.todo-app-web-access-sg.id ]
  user_data = data.template_file.storage-server-template-file.rendered
  associate_public_ip_address = true
  tags = {
    Name = "Storage Server"
  }
}

## SET UP AN ADMINISTRATION SERVER
# resource "aws_eip" "todo-app-jump-server-eip" {
#   vpc = true
#   instance = aws_instance.todo-app-jump-server.id

#     tags = {
#     Name = "Jump Server EIP"
#   }
# }

resource "aws_network_interface" "todo-app-jump-server-eni" {
  subnet_id = aws_subnet.todo-app-public-subnet-b.id
  private_ips = [var.jump_server_private_ip]
  security_groups = [ aws_security_group.todo-app-web-access-sg.id ]

  attachment {
    instance = aws_instance.todo-app-jump-server.id
    device_index = 1
  }

  tags = {
    Name = "Jump server network interface"
  }
}

data "template_file" "jump-server-template-file" {
  template = file("userdata-jump.sh")

  vars = {
    APP_SERVER_1_IP = var.app_server_1_private_ip
    APP_SERVER_1_HOSTNAME = var.app_server_1_hostname
    APP_SERVER_2_IP = var.app_server_2_private_ip
    APP_SERVER_2_HOSTNAME = var.app_server_2_hostname
    LB_SERVER_IP = var.lb_server_private_ip
    LB_SERVER_HOSTNAME = var.lb_server_hostname
    JENKINS_SERVER_IP = var.jenkins_server_private_ip
    JENKINS_SERVER_HOSTNAME = var.jenkins_server_hostname
    STORAGE_SERVER_IP = var.storage_server_private_ip
    STORAGE_SERVER_HOSTNAME = var.storage_server_hostname
    JUMP_SERVER_IP = var.jump_server_private_ip    
    JUMP_SERVER_HOSTNAME = var.jump_server_hostname
    DB_SERVER_IP = var.db_server_private_ip
    DB_SERVER_HOSTNAME = var.db_server_hostname
    ANSIBLE_PASSWD = var.ansible_passwd
  }
}

resource "aws_instance" "todo-app-jump-server" {
  ami = var.app_server_ami_id
  instance_type = var.ec2_instance_type
  key_name = var.ec2_keypair
  security_groups = [ aws_security_group.todo-app-web-access-sg.id ]
  subnet_id = aws_subnet.todo-app-public-subnet-b.id
  user_data = data.template_file.jump-server-template-file.rendered
  associate_public_ip_address = true

  tags = {
    Name = "Jump Server"
  }
}
