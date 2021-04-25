profile = "tgodfrey"
region  = "us-west-2"

ec2_instance_type = "t2.micro"
ec2_keypair = "aws2-oregon-key"

# amazon linux 2 ami id
app_server_ami_id = "ami-0e999cbd62129e3b1"
jenkins_server_ami_id = "ami-0e999cbd62129e3b1"

public_cidr = "0.0.0.0/0"
vpc_cidr_block = "10.0.0.0/16"

# specify private ip address
public_subnet_a_cidr = "10.0.2.0/24"
metric_server_private_ip = "10.0.2.8"
jenkins_server_private_ip = "10.0.2.10"

public_subnet_b_cidr = "10.0.10.0/24"
jump_server_private_ip = "10.0.10.8"
lb_server_private_ip = "10.0.10.11"

private_subnet_a_cidr = "10.0.5.0/24"
app_server_1_private_ip = "10.0.5.8"
storage_server_private_ip = "10.0.5.9"

private_subnet_b_cidr = "10.0.20.0/24"
db_server_private_ip = "10.0.20.12"
app_server_2_private_ip = "10.0.20.13"

# specify server hostname
jenkins_server_hostname = "jenkins.todo.com"
storage_server_hostname = "store.todo.com"
jump_server_hostname = "jump.todo.com"
app_server_1_hostname = "app1.todo.com"
app_server_2_hostname = "app2.todo.com"
lb_server_hostname = "lb-server.todo.com"
db_server_hostname = "db.todo.com"
metric_server_hostname = "metrics.todo.com"

# Variable values should be replace before deployment
# when ./deploy script is executed and the process will
# reverse after terraform has finish deploying
db_name = "DB_NAME"
db_user_name = "DB_USERNAME"
db_user_pass = "DB_PASSWD"
ansible_passwd = "ANSIBLE_PASSWD"
nagios_admin_passwd = "NAGIOS_ADMIN_PASSWD"

## dedicated Users for each servers
jump_server_username = "JUMP_SERVER_USERNAME"
jump_server_pw = "JUMP_SERVER_PW"
app_server_1_username = "APP_SERVER_1_USERNAME"
app_server_1_pw = "APP_SERVER_1_PW"
app_server_2_username = "APP_SERVER_2_USERNAME"
app_server_2_pw = "APP_SERVER_2_PW"
lb_server_username = "LB_SERVER_USERNAME"
lb_server_pw = "LB_SERVER_PW"
db_server_username   = "DB_SERVER_USERNAME"
db_server_pw = "DB_SERVER_PW"
storage_server_username = "STORAGE_SERVER_USERNAME"
storage_server_pw = "STORAGE_SERVER_PW"
jenkins_server_username = "JENKINS_SERVER_USERNAME"
jenkins_server_pw = "JENKINS_SERVER_PW"
metric_server_username = "METRIC_SERVER_USERNAME"
metric_server_pw = "METRIC_SERVER_PW"

## Zabbix User
zabbix_username = "ZABBIX_USERNAME"
zabbix_db = "ZABBIX_DB"
zabbix_ps = "ZABBIX_PS"
