#! /bin/bash

yum update
yum install git -y

# Install node.js
yum install -y gcc-c++ make;
curl -sL https://rpm.nodesource.com/setup_15.x | sudo -E bash -;
yum install nodejs -y;
echo "Version of node install is $(node --version)";

APP_SERVER_1_IP=${APP_SERVER_1_IP}
APP_SERVER_2_IP=${APP_SERVER_2_IP}
LB_SERVER_IP=${LB_SERVER_IP}
STORAGE_SERVER_IP=${STORAGE_SERVER_IP}
JENKINS_SERVER_IP=${JENKINS_SERVER_IP}
JUMP_SERVER_IP=${JUMP_SERVER_IP}
DB_SERVER_IP=${DB_SERVER_IP}
APP_SERVER_1_HOSTNAME=${APP_SERVER_1_HOSTNAME}
APP_SERVER_2_HOSTNAME=${APP_SERVER_2_HOSTNAME}
LB_SERVER_HOSTNAME=${LB_SERVER_HOSTNAME}
JENKINS_SERVER_HOSTNAME=${JENKINS_SERVER_HOSTNAME}
STORAGE_SERVER_HOSTNAME=${STORAGE_SERVER_HOSTNAME}
JUMP_SERVER_HOSTNAME=${JUMP_SERVER_HOSTNAME}
DB_SERVER_HOSTNAME=${DB_SERVER_HOSTNAME}
ANSIBLE_PASSWD=${ANSIBLE_PASSWD}

# Renaming because nrpe requires this name for multiple scripts files
# refer to ./deploy.sh script
SERVER_IP=$JUMP_SERVER_IP

JUMP_SERVER_USER=${JUMP_SERVER_USER}
JUMP_SERVER_USER_PW=${JUMP_SERVER_USER_PW}
APP_SERVER_1_USER=${APP_SERVER_1_USER}
APP_SERVER_1_USER_PW=${APP_SERVER_1_USER_PW}
APP_SERVER_2_USER=${APP_SERVER_2_USER}
APP_SERVER_2_USER_PW=${APP_SERVER_2_USER_PW}
LB_SERVER_USER=${LB_SERVER_USER}
LB_SERVER_USER_PW=${LB_SERVER_USER_PW}
DB_SERVER_USER=${DB_SERVER_USER}
DB_SERVER_USER_PW=${DB_SERVER_USER_PW}
STORAGE_SERVER_USER=${STORAGE_SERVER_USER}
STORAGE_SERVER_USER_PW=${STORAGE_SERVER_USER_PW}
JENKINS_SERVER_USER=${JENKINS_SERVER_USER}
JENKINS_SERVER_USER_PW=${JENKINS_SERVER_USER_PW}

cat >> /etc/hosts <<EOF

$JUMP_SERVER_IP             $JUMP_SERVER_HOSTNAME jump puppet
$APP_SERVER_1_IP            $APP_SERVER_1_HOSTNAME app1
$APP_SERVER_2_IP            $APP_SERVER_2_HOSTNAME app2
$LB_SERVER_IP               $LB_SERVER_HOSTNAME lb
$JENKINS_SERVER_IP          $JENKINS_SERVER_HOSTNAME jenkins
$STORAGE_SERVER_IP          $STORAGE_SERVER_HOSTNAME store
$DB_SERVER_IP               $DB_SERVER_HOSTNAME db
EOF

if [ $JUMP_SERVER_HOSTNAME ]; then 
  hostnamectl set-hostname $JUMP_SERVER_HOSTNAME;
fi;

## Install and configure puppet
# ./deploy script will replace the line below with puppet configuration during run
# and reverse it after terraform has finished deploying
#PUPPET_CONFIG

# Further configuration for puppet master node
yum install puppetserver -y;
puppet config set dns_alt_names "puppet" --section main;
puppet config set server 'puppet' --section main;

# Change the default memory limit required
sed -i 's|JAVA_ARGS="-Xms2g -Xmx2g -Djruby.logger.class=com.puppetlabs.jruby_utils.jruby.Slf4jLogger"|JAVA_ARGS="-Xms500m -Xmx500m -Djruby.logger.class=com.puppetlabs.jruby_utils.jruby.Slf4jLogger"|' /etc/sysconfig/puppetserver

cat > /etc/puppetlabs/puppet/autosign.conf <<EOF
$JUMP_SERVER_HOSTNAME
$APP_SERVER_1_HOSTNAME
$APP_SERVER_2_HOSTNAME
$LB_SERVER_HOSTNAME
$JENKINS_SERVER_HOSTNAME
$STORAGE_SERVER_HOSTNAME
$DB_SERVER_HOSTNAME
EOF
puppet agent -t;
systemctl restart puppet;
systemctl enable --now puppetserver;


## Install and configure Ansible
amazon-linux-extras install epel -y;
yum-config-manager enable epel
yum install epel-release -y;
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
# cat 'eval $(ssh-agent)' >> /home/ansible/.bashrc;
# cat 'ssh-add /home/ansible/.ssh/id_rsa' >> /home/ansible/.bashrc;
# source /home/ansible/.bashrc;

# Use puppet to copy ansible ssh key to the agent server
cd /etc/puppetlabs/code/environments/production/manifests;
cat >> copysshkey.pp <<EOF
class copy_ssh {
  file {'/home/ansible/.ssh/authorized_keys':
    content => 'ANSIBLE_SSH_KEY'
  }
}
include copy_ssh
EOF

cat > createfile.pp <<EOF
class createfile {
  file { '/etc/testfile.txt':
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
puppet apply copysshkey.pp

# Create ansible inventory file
cat >> /home/ansible/inventory <<EOF
app1
app2
lb
db
jenkins
store

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
  - tasks:
    - name: Create Jump server user
      user:
        name: ${JUMP_SERVER_USER}
        password: ${JUMP_SERVER_USER_PW}
        groups:
        - wheel
        append: yes
- name: App Server 1
  hosts: app1
  become: yes
  - tasks:
    - name: Create App server 1 user
      user:
        name: ${APP_SERVER_1_USER}
        password: ${APP_SERVER_1_USER_PW}
        groups:
        - wheel
        append: yes
- name: App Server 2
  hosts: app2
  become: yes
  - tasks:
    - name: Create App server 2 user
      user:
        name: ${APP_SERVER_2_USER}
        password: ${APP_SERVER_2_USER_PW}
        groups:
        - wheel
        append: yes
- name: LB Server
  hosts: lb
  become: yes
  - tasks:
    - name: Create LB server user
      user:
        name: ${LB_SERVER_USER}
        password: ${LB_SERVER_USER_PW}
        groups:
        - wheel
        append: yes
- name: DB Server
  hosts: db
  become: yes
  - tasks:
    - name: Create DB Server user
      user:
        name: ${DB_SERVER_USER}
        password: ${DB_SERVER_USER_PW}
        groups:
        - wheel
        append: yes
- name: Create Users
  hosts: store
  become: yes
  - tasks:
    - name: Create storage server user
      user:
        name: ${STORAGE_SERVER_USER}
        password: ${STORAGE_SERVER_USER_PW}
        groups:
        - wheel
        append: yes
- name: Jenkins Server
  hosts: jenkins
  become: yes
  - tasks
    - name: Create Jenkins user
      user:
        name: ${JENKINS_SERVER_USER}
        password: ${JENKINS_SERVER_USER_PW}
        groups:
        - wheel
        append: yes
EOF
ansible all -i inventory -m shell -a 'whoami' &2> /etc/ansible_answer.txt;
ansible-playbook -i inventory gather-facts.yml;
ansible-playbook -i inventory create-user.yml;






