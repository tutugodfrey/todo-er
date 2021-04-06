profile = "tgodfrey"
region  = "us-west-2"
vpc_cidr_block = "10.0.0.0/16"
public_subnet_a_cidr = "10.0.2.0/24"
private_subnet_a_cidr = "10.0.5.0/24"
public_subnet_b_cidr = "10.0.10.0/24"
private_subnet_b_cidr = "10.0.20.0/24"
ec2_instance_type = "t2.micro"
ec2_keypair = "aws2-oregon-key"
app_server_ami_id = "ami-0e999cbd62129e3b1"
jenkins_server_ami_id = "ami-0e999cbd62129e3b1"

# specify private ip address
app_server_1_private_ip = "10.0.5.6"
app_server_2_private_ip = "10.0.10.7"
jump_server_private_ip = "10.0.10.4"
lb_server_private_ip = "10.0.10.5"
jenkins_server_private_ip = "10.0.10.9"
storage_server_private_ip = "10.0.10.8"
db_server_private_ip = "10.0.20.6"

# specify server hostname
jenkins_server_hostname = "jenkins.todo.com"
storage_server_hostname = "store.todo.com"
jump_server_hostname = "jump.todo.com"
app_server_1_hostname = "app1.todo.com"
app_server_2_hostname = "app2.todo.com"
lb_server_hostname = "lb-server.todo.com"
db_server_hostname = "db.todo.com"

# Variable values should be replace before deployment
# when ./deploy script is executed and the process will
# reverse after terraform has finish deploying
db_name = "DB_NAME"
db_user_name = "DB_USERNAME"
db_user_pass = "DB_PASSWD"
ansible_passwd = "ANSIBLE_PASSWD"
nagios_admin_passwd = "NAGIOS_ADMIN_PASSWD"

## dedicated Users for each servers
jump_server_user = "JUMP_SERVER_USER"
jump_server_user_pw = "JUMP_SERVER_USER_PW"
app_server_1_user = "APP_SERVER_1_USER"
app_server_1_user_pw = "APP_SERVER_1_USERpwd"
app_server_2_user = "APP_SERVER_2_USER"
app_server_2_user_pw = "APP_SERVER_2_USERpwd"
lb_server_user = "LB_SERVER_USER"
lb_server_user_pw = "LB_SERVER_USER_PW"
db_server_user   = "DB_SERVER_USER"
db_server_user_pw = "DB_SERVER_USER_PW"
storage_server_user = "STORAGE_SERVER_USER"
storage_server_user_pw = "STORAGE_SERVER_USERpwd"
jenkins_server_user = "JENKINS_SERVER_USER"
jenkins_server_user_pw = "JENKINS_SERVER_USERpwd"
