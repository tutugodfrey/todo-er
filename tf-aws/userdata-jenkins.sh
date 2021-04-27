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
SERVER_IP=${JENKINS_SERVER_IP}
NAGIOS_ADMIN_PASSWD=${NAGIOS_ADMIN_PASSWD}
ZABBIX_USERNAME=${ZABBIX_USERNAME}
ZABBIX_DB=${ZABBIX_DB}
ZABBIX_PS=${ZABBIX_PS}

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
if [ $JENKINS_SERVER_HOSTNAME ]; then
  hostnamectl set-hostname $JENKINS_SERVER_HOSTNAME;
fi;

cat >> /etc/hosts <<EOF
$APP_SERVER_1_IP            $APP_SERVER_1_HOSTNAME app1
$APP_SERVER_2_IP            $APP_SERVER_2_HOSTNAME app2
$LB_SERVER_IP               $LB_SERVER_HOSTNAME lb
$JENKINS_SERVER_IP          $JENKINS_SERVER_HOSTNAME jenkins
$STORAGE_SERVER_IP          $STORAGE_SERVER_HOSTNAME store
$JUMP_SERVER_IP             $JUMP_SERVER_HOSTNAME jump puppet
$DB_SERVER_IP               $DB_SERVER_HOSTNAME db
$METRIC_SERVER_IP           $METRIC_SERVER_HOSTNAME metrics
EOF

# ./deploy script will replace the line below with puppet configuration during run
# and reverse it after terraform has finished deploying
#PUPPET_CONFIG

# Wait for puppet server to sign CA
#PUPPET_WAIT_1

# Add configuration for Ansible user
#ANSIBLE_CONFIG

# Wait for puppet server to apply copyssh.pp
#PUPPET_WAIT_2

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

## Install Jenkins
yum install java-1.8.0 -y;
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo;
rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key;
yum install jenkins -y;
yum install postgresql -y # needed to connect to db during test
systemctl enable jenkins;
systemctl start jenkins;

# Script execution end
END_TIME=$(date +%s)
DURATION=$(echo "$END_TIME - $START" | bc)
echo Execution complete in $DURATION | tee /tmp/duration.txt