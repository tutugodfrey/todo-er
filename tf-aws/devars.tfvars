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