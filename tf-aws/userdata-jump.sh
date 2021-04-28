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


cat > /home/ansible/gather-facts.yml <<EOF
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
cat > /home/ansible/create-user.yml <<EOF
- name: Create dedicated users for each server
  hosts: all
  become: yes
  tasks:
    - name: Create Jump server user
      user:
        name: ${JUMP_SERVER_USERNAME}
        password: "{{ '${JUMP_SERVER_PW}' | password_hash('sha512') }}"
        update_password: on_create
        groups:
        - wheel
        append: yes
      ignore_errors: true
      when: ansible_nodename.find('jump') != -1
    - name: Create App server 1 user
      user:
        name: ${APP_SERVER_1_USERNAME}
        password: "{{ '${APP_SERVER_1_PW}' | password_hash('sha512') }}"
        update_password: on_create
        groups:
        - wheel
        append: yes
      when: ansible_nodename.find('app1') != -1
    - name: Create App server 2 user
      user:
        name: ${APP_SERVER_2_USERNAME}
        password: "{{ '${APP_SERVER_2_PW}' | password_hash('sha512') }}"
        update_password: on_create
        groups:
        - wheel
        append: yes
      when: ansible_nodename.find('app2') != -1

    - name: Create LB server user
      user:
        name: ${LB_SERVER_USERNAME}
        password: "{{ '${LB_SERVER_PW}' | password_hash('sha512') }}"
        update_password: on_create
        groups:
        - wheel
        append: yes
      when: ansible_nodename.find('lb') != -1
    - name: Create DB Server user
      user:
        name: ${DB_SERVER_USERNAME}
        password: "{{ '${DB_SERVER_PW}' | password_hash('sha512') }}"
        update_password: on_create
        groups:
        - wheel
        append: yes
      when: ansible_nodename.find('db') != -1
    - name: Create storage server user
      user:
        name: ${STORAGE_SERVER_USERNAME}
        password: "{{ '${STORAGE_SERVER_PW}' | password_hash('sha512') }}"
        update_password: on_create
        groups:
        - wheel
        append: yes
      when: ansible_nodename.find('store') != -1
    - name: Create Jenkins user
      user:
        name: ${JENKINS_SERVER_USERNAME}
        password: "{{ '${JENKINS_SERVER_PW}' | password_hash('sha512') }}"
        update_password: on_create
        groups:
        - wheel
        append: yes
      when: ansible_nodename.find('jenkins') != -1
    - name: Create Metric User
      user:
        name: ${METRIC_SERVER_USERNAME}
        password: "{{ '${METRIC_SERVER_PW}' | password_hash('sha512') }}"
        update_password: on_create
        groups:
        - wheel
        append: yes
      when: ansible_nodename.find('metrics') != -1
EOF

cat > /home/ansible/ansible_script.sh <<EOF
#! /bin/bash
counter=0;
until ansible all -i inventory -m shell -a 'whoami' > ansible_answer.txt || [ \$counter -gt 20 ]; do
  echo Waiting for managed servers to be ready; sleep 3;
  ((counter++));
  echo \$counter;
done;
ansible-playbook -i inventory gather-facts.yml;
ansible-playbook -i inventory create-user.yml;
EOF
chown ansible:ansible /home/ansible/{gather-facts,create-user}.yml;
chown ansible:ansible /home/ansible/ansible_script.sh;
chmod +x /home/ansible/ansible_script.sh;

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

## Test the ansible configuration
su - ansible -c /home/ansible/ansible_script.sh;

## Use puppet to copy ssh key for users managed nodes
cat > /etc/puppetlabs/code/environments/production/manifests/sshkey.pp <<EOF
# ssh_public_key will be replace during script execution
# and before running the puppet apply
\$ssh_public_key = 'SSH_PUBLIC_KEY'

class ssh_node_metric {
  ssh_authorized_key { '${METRIC_SERVER_USERNAME}@${METRIC_SERVER_HOSTNAME}':
   ensure => present,
   user => '${METRIC_SERVER_USERNAME}',
   type => 'ssh-rsa',
   key => \$ssh_public_key,
  }
}
class ssh_node_jenkins {
  ssh_authorized_key { '${JENKINS_SERVER_USERNAME}@${JENKINS_SERVER_HOSTNAME}':
   ensure => present,
   user => '${JENKINS_SERVER_USERNAME}',
   type => 'ssh-rsa',
   key => \$ssh_public_key,
  }
}
class ssh_node_jump {
  ssh_authorized_key { '${JUMP_SERVER_USERNAME}@${JUMP_SERVER_HOSTNAME}':
   ensure => present,
   user => '${JUMP_SERVER_USERNAME}',
   type => 'ssh-rsa',
   key => \$ssh_public_key,
  }
}
class ssh_node_app1 {
  ssh_authorized_key { '${APP_SERVER_1_USERNAME}@${APP_SERVER_1_HOSTNAME}':
   ensure => present,
   user => '${APP_SERVER_1_USERNAME}',
   type => 'ssh-rsa',
   key => \$ssh_public_key,
  }
}
class ssh_node_app2 {
  ssh_authorized_key { '${APP_SERVER_2_USERNAME}@${APP_SERVER_2_HOSTNAME}':
   ensure => present,
   user => '${APP_SERVER_2_USERNAME}',
   type => 'ssh-rsa',
   key => \$ssh_public_key,
  }
}
class ssh_node_lb {
  ssh_authorized_key { '${LB_SERVER_USERNAME}@${LB_SERVER_HOSTNAME}':
   ensure => present,
   user => '${LB_SERVER_USERNAME}',
   type => 'ssh-rsa',
   key => \$ssh_public_key,
  }
}
class ssh_node_storage {
  ssh_authorized_key { '${STORAGE_SERVER_USERNAME}@${STORAGE_SERVER_HOSTNAME}':
   ensure => present,
   user => '${STORAGE_SERVER_USERNAME}',
   type => 'ssh-rsa',
   key => \$ssh_public_key,
  }
}
class ssh_node_db {
  ssh_authorized_key { '${DB_SERVER_USERNAME}@${DB_SERVER_HOSTNAME}':
   ensure => present,
   user => '${DB_SERVER_USERNAME}',
   type => 'ssh-rsa',
   key => \$ssh_public_key,
  }
}

node default {}
node '${METRIC_SERVER_HOSTNAME}' {
  include ssh_node_metric
}
node '${JENKINS_SERVER_HOSTNAME}' {
  include ssh_node_jenkins
}
#node '${JUMP_SERVER_HOSTNAME}' {
#  include ssh_node_jump
#}
node '${APP_SERVER_1_HOSTNAME}' {
  include ssh_node_app1
}
node '${APP_SERVER_2_HOSTNAME}' {
  include ssh_node_app2
}
node '${LB_SERVER_HOSTNAME}' {
  include ssh_node_lb
}
node '${STORAGE_SERVER_HOSTNAME}' {
  include ssh_node_storage
}
node '${DB_SERVER_HOSTNAME}' {
  include ssh_node_db
}
EOF

ssh-keygen -t rsa -b 2048 -f /root/.ssh/id_rsa;
# Use cut get just the rsa key.
sed -i "s|SSH_PUBLIC_KEY|$(cat /root/.ssh/id_rsa.pub | cut -d' ' -f 2)|" /etc/puppetlabs/code/environments/production/manifests/sshkey.pp;
puppet apply /etc/puppetlabs/code/environments/production/manifests/sshkey.pp;


# Script execution end
END_TIME=$(date +%s)
DURATION=$(echo "$END_TIME - $START" | bc)
echo Execution complete in $DURATION | tee /tmp/duration.txt
