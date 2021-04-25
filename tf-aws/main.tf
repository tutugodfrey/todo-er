# Import vpc modules
module "vpc-module" {
  source = "./modules/vpc-module"
  vpc_cidr_block = var.vpc_cidr_block
  public_subnet_a_cidr = var.public_subnet_a_cidr
  public_subnet_b_cidr = var.public_subnet_b_cidr
  private_subnet_a_cidr = var.private_subnet_a_cidr
  private_subnet_b_cidr = var.private_subnet_b_cidr
  public_cidr = var.public_cidr
}

# Implement Security groups
module "security-groups" {
  source = "./modules/sg-module"
  vpc_cidr_block = var.vpc_cidr_block
  public_cidr = var.public_cidr
  private_subnet_a_cidr = var.private_subnet_a_cidr
  private_subnet_b_cidr = var.private_subnet_b_cidr
  vpc-id = module.vpc-module.vpc_id
}

resource "aws_route" "todo-app-nat-instance-route" {
  route_table_id = module.vpc-module.private_route_table
  instance_id = aws_instance.todo-app-nat-instance.id
  destination_cidr_block = var.public_cidr
}

## CREATE A EC2 NAT GATEWAY INSTANCE
resource "aws_instance" "todo-app-nat-instance" {
  ami = var.app_server_ami_id
  key_name = var.ec2_keypair
  instance_type = var.ec2_instance_type
  subnet_id = module.vpc-module.public_subnet_b
  associate_public_ip_address = true
  source_dest_check = false
  security_groups = [
    module.security-groups.nat-instance-sg,
    module.security-groups.external-ssh-sg
  ]
  user_data = <<EOF
    #!/bin/bash
    yum -y update
    echo 1 > /proc/sys/net/ipv4/ip_forward
    echo 0 > /proc/sys/net/ipv4/conf/eth0/send_redirects
    /sbin/iptables -t nat -A POSTROUTING -o eth0 -s 0.0.0.0/0 -j MASQUERADE
    /sbin/iptables-save > /etc/sysconfig/iptables
    mkdir -p /etc/sysctl.d/
    cat <<END > /etc/sysctl.d/nat.conf
    net.ipv4.ip_forward = 1
    net.ipv4.conf.eth0.send_redirects = 0
    END
  EOF
  tags = {
    Name = "Todo App Nat Instance"
  }
}

locals {
  template_file_vars = {
    METRIC_SERVER_HOSTNAME = var.metric_server_hostname
    METRIC_SERVER_IP = var.metric_server_private_ip
    JENKINS_SERVER_IP = var.jenkins_server_private_ip
    JENKINS_SERVER_HOSTNAME = var.jenkins_server_hostname
    JUMP_SERVER_IP = var.jump_server_private_ip
    JUMP_SERVER_HOSTNAME = var.jump_server_hostname
    APP_SERVER_1_IP = var.app_server_1_private_ip
    APP_SERVER_1_HOSTNAME = var.app_server_1_hostname
    APP_SERVER_2_IP = var.app_server_2_private_ip
    APP_SERVER_2_HOSTNAME = var.app_server_2_hostname
    LB_SERVER_IP = var.lb_server_private_ip
    LB_SERVER_HOSTNAME = var.lb_server_hostname
    STORAGE_SERVER_IP = var.storage_server_private_ip
    STORAGE_SERVER_HOSTNAME = var.storage_server_hostname
    DB_SERVER_IP = var.db_server_private_ip
    DB_SERVER_HOSTNAME = var.db_server_hostname
    
    # server users details
    ANSIBLE_PASSWD = var.ansible_passwd
    APP_SERVER_1_USERNAME = var.app_server_1_username
    APP_SERVER_1_PW = var.app_server_1_pw
    APP_SERVER_2_USERNAME = var.app_server_2_username
    APP_SERVER_2_PW = var.app_server_2_pw
    LB_SERVER_USERNAME = var.lb_server_username
    LB_SERVER_PW = var.lb_server_pw
    DB_SERVER_USERNAME = var.db_server_username
    DB_SERVER_PW = var.db_server_pw
    STORAGE_SERVER_USERNAME = var.storage_server_username
    STORAGE_SERVER_PW = var.storage_server_pw
    JENKINS_SERVER_USERNAME = var.jenkins_server_username
    JENKINS_SERVER_PW = var.jenkins_server_pw
    JUMP_SERVER_USERNAME = var.jump_server_username
    JUMP_SERVER_PW = var.jump_server_pw
    METRIC_SERVER_USERNAME = var.metric_server_username
    METRIC_SERVER_PW = var.metric_server_pw

    DB_NAME = var.db_name
    DB_USER_NAME = var.db_user_name
    DB_USER_PASS = var.db_user_pass
    DB_PORT = var.db_port
    VPC_CIDR_BLOCK = var.vpc_cidr_block
    NAGIOS_ADMIN_PASSWD = var.nagios_admin_passwd
    ZABBIX_USERNAME = var.zabbix_username
    ZABBIX_DB = var.zabbix_db
    ZABBIX_PS = var.zabbix_ps
  }
}

module "app-server-1" {
  source = "./modules/ec2-instance"
  subnet_id = module.vpc-module.private_subnet_a
  private_ip = var.app_server_1_private_ip
  userdata_file = "userdata.sh"
  security_groups = [
    module.security-groups.metric-server-sg,
    module.security-groups.web-access-sg,
    module.security-groups.db-server-sg,
  ]
  associate_public_ip_address = false
  instance_name_tag = "App Server 1"
  template_file_vars = local.template_file_vars
}

module "app-server-2" {
  source = "./modules/ec2-instance"
  subnet_id = module.vpc-module.private_subnet_b
  private_ip = var.app_server_2_private_ip
  userdata_file = "userdata.sh"
  security_groups = [
    module.security-groups.metric-server-sg,
    module.security-groups.web-access-sg,
    module.security-groups.db-server-sg,
  ]
  associate_public_ip_address = false
  instance_name_tag = "App Server 2"
  template_file_vars = local.template_file_vars
}


# provision an elastic ip for the load balancer
/* resource "aws_eip" "todo-app-lb-eip" {
  vpc = true
  instance = aws_instance.todo-app-lb-server.id

  tags = {
    Name = "LoadBalancer Server EIP"
  }
} */
module "lb-server" {
  source = "./modules/ec2-instance"
  subnet_id = module.vpc-module.public_subnet_b
  private_ip = var.lb_server_private_ip
  userdata_file = "userdata-lb.sh"
  security_groups = [
    module.security-groups.metric-server-sg,
    module.security-groups.web-access-sg,
  ]
  instance_name_tag = "LB Server"
  template_file_vars = local.template_file_vars
}

## SETUP A POSTGRESQL DATABASE SERVER WITH EC2 INSTANCE
module "db-server" {
  source = "./modules/ec2-instance"
  subnet_id = module.vpc-module.private_subnet_b
  private_ip = var.db_server_private_ip
  userdata_file = "userdata-db.sh"
  security_groups = [
    module.security-groups.metric-server-sg,
    module.security-groups.web-access-sg,
    module.security-groups.db-server-sg,
  ]
  associate_public_ip_address = false
  instance_name_tag = "DB Server"
  template_file_vars = local.template_file_vars
}

module "jump-server" {
  source = "./modules/ec2-instance"
  subnet_id = module.vpc-module.public_subnet_b
  private_ip = var.jump_server_private_ip
  userdata_file = "userdata-jump.sh"
  security_groups = [
    module.security-groups.metric-server-sg,
    module.security-groups.web-access-sg,
    module.security-groups.external-ssh-sg,
  ]
  instance_name_tag = "Jump Server"
  template_file_vars = local.template_file_vars
}

module "jenkins-server" {
  source = "./modules/ec2-instance"
  subnet_id = module.vpc-module.public_subnet_a
  private_ip = var.jenkins_server_private_ip
  userdata_file = "userdata-jenkins.sh"
  security_groups = [
    module.security-groups.metric-server-sg,
    module.security-groups.web-access-sg,
  ]
  instance_name_tag = "Jenkins Server"
  template_file_vars = local.template_file_vars
}

## SET UP A STORAGE SERVER
module "storage-server" {
  source = "./modules/ec2-instance"
  subnet_id = module.vpc-module.private_subnet_a
  private_ip = var.storage_server_private_ip
  userdata_file = "userdata-storage.sh"
  security_groups = [
    module.security-groups.metric-server-sg,
    module.security-groups.web-access-sg,
  ]
  associate_public_ip_address = false
  instance_name_tag = "Storage Server"
  template_file_vars = local.template_file_vars
}

## SET UP A METRICS SERVER
module "metrics-server" {
  source = "./modules/ec2-instance"
  subnet_id = module.vpc-module.public_subnet_a
  private_ip = var.metric_server_private_ip
  userdata_file = "userdata-metrics.sh"
  security_groups = [
    module.security-groups.metric-server-sg,
    module.security-groups.web-access-sg,
    module.security-groups.external-ssh-sg,
  ]
  instance_name_tag = "Metrics Server"
  template_file_vars = local.template_file_vars
}

### CREATE NAT GATEWAY (AWS MANAGE)
/* resource "aws_eip" "todo-app-nat-gateway-eip" {
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
  destination_cidr_block = var.public_cidr
} */


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
#   # db_user_name, db_password should be replace with dynamic values
#   username = "db_user_name"
#   password =  "db_password"
#   vpc_security_group_ids = [aws_security_group.todo-app-rds-security-group.id]
#   publicly_accessible = false
#   skip_final_snapshot = true
# }
