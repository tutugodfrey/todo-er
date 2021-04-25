#! /bin/bash

START=$(date +%s)

METRIC_SERVER_HOSTNAME=${METRIC_SERVER_HOSTNAME}
METRIC_SERVER_IP=${METRIC_SERVER_IP}
JENKINS_SERVER_HOSTNAME=${JENKINS_SERVER_HOSTNAME}
JENKINS_SERVER_IP=${JENKINS_SERVER_IP}
JUMP_SERVER_IP=${JUMP_SERVER_IP}
JUMP_SERVER_HOSTNAME=${JUMP_SERVER_HOSTNAME}
APP_SERVER_1_IP=${APP_SERVER_1_IP}
APP_SERVER_2_IP=${APP_SERVER_2_IP}
LB_SERVER_IP=${LB_SERVER_IP}
STORAGE_SERVER_IP=${STORAGE_SERVER_IP}
DB_SERVER_IP=${DB_SERVER_IP}
APP_SERVER_1_HOSTNAME=${APP_SERVER_1_HOSTNAME}
APP_SERVER_2_HOSTNAME=${APP_SERVER_2_HOSTNAME}
LB_SERVER_HOSTNAME=${LB_SERVER_HOSTNAME}
STORAGE_SERVER_HOSTNAME=${STORAGE_SERVER_HOSTNAME}
DB_SERVER_HOSTNAME=${DB_SERVER_HOSTNAME}
ANSIBLE_PASSWD=${ANSIBLE_PASSWD}

JUMP_SERVER_USERNAME=${JUMP_SERVER_USERNAME}
JUMP_SERVER_PW=${JUMP_SERVER_PW}
APP_SERVER_1_USERNAME=${APP_SERVER_1_USERNAME}
APP_SERVER_1_PW=${APP_SERVER_1_PW}
APP_SERVER_2_USERNAME=${APP_SERVER_2_USERNAME}
APP_SERVER_2_PW=${APP_SERVER_2_PW}
LB_SERVER_USERNAME=${LB_SERVER_USERNAME}
LB_SERVER_PW=${LB_SERVER_PW}
DB_SERVER_USERNAME=${DB_SERVER_USERNAME}
DB_SERVER_PW=${DB_SERVER_PW}
STORAGE_SERVER_USERNAME=${STORAGE_SERVER_USERNAME}
STORAGE_SERVER_PW=${STORAGE_SERVER_PW}
JENKINS_SERVER_USERNAME=${JENKINS_SERVER_USERNAME}
JENKINS_SERVER_PW=${JENKINS_SERVER_PW}
METRIC_SERVER_USERNAME=${METRIC_SERVER_USERNAME}
METRIC_SERVER_PW=${METRIC_SERVER_PW}

yum update -y;
SERVER_PRIVATE_IP=$(ip a | grep inet | awk -F' ' '/brd/ { print $2 }' | awk -F/ '{ print $1 }' | cut -d' ' -f 2);
SERVER_PRIVATE_IP=$(echo $SERVER_PRIVATE_IP | cut -d' ' -f 2);
echo $SERVER_PRIVATE_IP > /tmp/server-ip.txt;

# Add epel repository if not already install
#ADD_EPEL_REPO

# Install yum config manager if not present
#YUM_CONFIG_MANAGER

# Add swap file
#ADD_SWAP_FILE

# Install node.js
# yum install -y gcc-c++ make;
# curl -sL https://rpm.nodesource.com/setup_15.x | sudo -E bash -;
# yum install nodejs -y;
# echo "Version of node install is $(node --version)";

if [ $JUMP_SERVER_HOSTNAME ]; then
  hostnamectl set-hostname $JUMP_SERVER_HOSTNAME;
fi;

cat >> /etc/hosts <<EOF
$JUMP_SERVER_IP             $JUMP_SERVER_HOSTNAME jump puppet
$APP_SERVER_1_IP            $APP_SERVER_1_HOSTNAME app1
$APP_SERVER_2_IP            $APP_SERVER_2_HOSTNAME app2
$LB_SERVER_IP               $LB_SERVER_HOSTNAME lb
$JENKINS_SERVER_IP          $JENKINS_SERVER_HOSTNAME jenkins
$STORAGE_SERVER_IP          $STORAGE_SERVER_HOSTNAME store
$DB_SERVER_IP               $DB_SERVER_HOSTNAME db
$METRIC_SERVER_IP           $METRIC_SERVER_HOSTNAME metrics
EOF

## Install and configure puppet
# ./deploy script will replace the line below with puppet configuration during run
# and reverse it after terraform has finished deploying
#PUPPET_CONFIG

# Further configuration for puppet master node
yum install puppetserver -y;
puppet config set dns_alt_names "puppet" --section main;
puppet config set server 'puppet' --section main;

# Change the default memory limit required
sed -i 's/-Xms2g -Xmx2g/-Xms450m -Xmx450m/' /etc/sysconfig/puppetserver

cat > /etc/puppetlabs/puppet/autosign.conf <<EOF
$JUMP_SERVER_HOSTNAME
$APP_SERVER_1_HOSTNAME
$APP_SERVER_2_HOSTNAME
$LB_SERVER_HOSTNAME
$JENKINS_SERVER_HOSTNAME
$STORAGE_SERVER_HOSTNAME
$DB_SERVER_HOSTNAME
$METRIC_SERVER_HOSTNAME
EOF
systemctl restart puppet;
systemctl enable --now puppetserver;
puppet agent -t;

# Track how much for puppet to have been install
PUPPET_SETUP_COMPLETE=$(date +%s)
DURATION=$(echo "$PUPPET_SETUP_COMPLETE - $START" | bc)
echo $DURATION >> /tmp/duration.txt

## Install and configure Ansible
yum install ansible -y;
useradd -G wheel ansible -m;

echo $ANSIBLE_PASSWD | passwd --stdin ansible;
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config;
sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config;
systemctl restart sshd; 

echo 'ansible ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/ansible;
mkdir /home/ansible/.ssh;
chown ansible:ansible /home/ansible/.ssh
chmod 700 /home/ansible/.ssh;
ssh-keygen -t rsa -b 2048 -f /home/ansible/.ssh/id_rsa -C ansible;
cp home/ansible/.ssh/id_rsa* /etc/;
chown ansible:ansible /home/ansible/.ssh/id_rsa*;

# Use puppet to copy ansible ssh key to the agent server
cd /etc/puppetlabs/code/environments/production/manifests;
cat >> copysshkey.pp <<EOF
class copy_ssh_key {
  file {'/home/ansible/.ssh/authorized_keys':
    content => 'ANSIBLE_SSH_KEY'
  }
}
include copy_ssh_key
EOF

cat > puppet-test-file.pp <<EOF
class createfile {
  file { '/tmp/testfile.txt':
     ensure => present,
     content => "This is a test file",
     owner => ansible,
     group => ansible
  }
}

include createfile
EOF

sed -i "s|ANSIBLE_SSH_KEY|$(cat /home/ansible/.ssh/id_rsa.pub)|" copysshkey.pp;

# Execute puppet
puppet apply puppet-test-file.pp
puppet apply copysshkey.pp

PUPPET_SETUP_APPLY=$(date +%s)
DURATION=$(echo "$PUPPET_SETUP_APPLY - $START" | bc)
echo PUPPET APPLY AT $DURATION >> /tmp/duration.txt

# Create ansible inventory file
cat >> /home/ansible/inventory <<EOF
app1
app2
lb
db
jenkins
store
metrics

[apps]
app1
app2
EOF

# Create a custom ansible config file
cat >> /home/ansible/ansible.cfg <<EOF
[defaults]
root_user = ansible
host_key_checking = False
inventory = inventory

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
EOF
chown ansible:ansible /home/ansible/{ansible.cfg,inventory};

## Test the ansible configuration
sudo -i -u ansible
cd /home/ansible;
cat > gather-facts.yml <<EOF
- name: Gather facts
  hosts: all
  become: true
  gather_facts: yes
  tasks:
  - name: fact gathering
    blockinfile:
      path: /home/ansible/hostdetail.txt
      create: yes
      marker: ""
      block: |
          Host detail IP {{ ansible_facts.default_ipv4.address }}
          Hostname {{ ansible_facts.hostname }}
EOF

# Use ansible to create dedicated users for all our servers
cat > create-user.yml <<EOF
- name: Jump Server
  hosts: jump
  become: yes
  tasks:
    - name: Create Jump server user
      user:
        name: ${JUMP_SERVER_USERNAME}
        password: ${JUMP_SERVER_PW}
        groups:
        - wheel
        append: yes
        ignore_errors: true
- name: App Server 1
  hosts: app1
  become: yes
  tasks:
    - name: Create App server 1 user
      user:
        name: ${APP_SERVER_1_USERNAME}
        password: ${APP_SERVER_1_PW}
        groups:
        - wheel
        append: yes
- name: App Server 2
  hosts: app2
  become: yes
  tasks:
    - name: Create App server 2 user
      user:
        name: ${APP_SERVER_2_USERNAME}
        password: ${APP_SERVER_2_PW}
        groups:
        - wheel
        append: yes
- name: LB Server
  hosts: lb
  become: yes
  tasks:
    - name: Create LB server user
      user:
        name: ${LB_SERVER_USERNAME}
        password: ${LB_SERVER_PW}
        groups:
        - wheel
        append: yes
- name: DB Server
  hosts: db
  become: yes
  tasks:
    - name: Create DB Server user
      user:
        name: ${DB_SERVER_USERNAME}
        password: ${DB_SERVER_PW}
        groups:
        - wheel
        append: yes
- name: Create Users
  hosts: store
  become: yes
  tasks:
    - name: Create storage server user
      user:
        name: ${STORAGE_SERVER_USERNAME}
        password: ${STORAGE_SERVER_PW}
        groups:
        - wheel
        append: yes
- name: Jenkins Server
  hosts: jenkins
  become: yes
  tasks:
    - name: Create Jenkins user
      user:
        name: ${JENKINS_SERVER_USERNAME}
        password: ${JENKINS_SERVER_PW}
        groups:
        - wheel
        append: yes
- name: Metric Server
  hosts: metrics
  become: yes
  tasks:
    - name: Create Metric User
      user:
        name: ${METRIC_SERVER_USERNAME}
        password: ${METRIC_SERVER_PW}
        groups:
        - wheel
        append: yes
EOF
ansible all -i inventory -m shell -a 'whoami' &2> /tmp/ansible_answer.txt;
chown ansible:ansible {gather-facts,create-user}.yml;
ansible-playbook -i inventory gather-facts.yml;
ansible-playbook -i inventory create-user.yml;

# Install and configure Nagios NRPE plugin
#NRPE

## Add configuration for prometheus node exporter
#NODEEXPORTER

## Create a systemd service for node exporter
cat > /etc/systemd/system/node_exporter.service <<EOF 
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=nodeusr
Group=nodeusr
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload;
systemctl start node_exporter;

## Install and configure Zabbix agent
#ZABBIXAGENT

yum install git -y;

# Script execution end
END=$(date +%s)
