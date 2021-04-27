#! /bin/bash

START=$(date +%s)

METRIC_SERVER_HOSTNAME=${METRIC_SERVER_HOSTNAME}
METRIC_SERVER_IP=${METRIC_SERVER_IP}
JENKINS_SERVER_HOSTNAME=${JENKINS_SERVER_HOSTNAME}
JENKINS_SERVER_IP=${JENKINS_SERVER_IP}
JUMP_SERVER_IP=${JUMP_SERVER_IP}
JUMP_SERVER_HOSTNAME=${JUMP_SERVER_HOSTNAME}
STORAGE_SERVER_IP=${STORAGE_SERVER_IP}
STORAGE_SERVER_HOSTNAME=${STORAGE_SERVER_HOSTNAME}
DB_SERVER_HOSTNAME=${DB_SERVER_HOSTNAME}
DB_SERVER_IP=${DB_SERVER_IP}
APP_SERVER_1_IP=${APP_SERVER_1_IP}
APP_SERVER_1_HOSTNAME=${APP_SERVER_1_HOSTNAME}
APP_SERVER_2_IP=${APP_SERVER_2_IP}
APP_SERVER_2_HOSTNAME=${APP_SERVER_2_HOSTNAME} 
DB_NAME=${DB_NAME}
DB_USER_NAME=${DB_USER_NAME}
DB_USER_PASS=${DB_USER_PASS}
DB_PORT=${DB_PORT}

yum update -y;
SERVER_PRIVATE_IP=$(ip a | grep inet | awk -F' ' '/brd/ { print $2 }' | awk -F/ '{ print $1 }');
SERVER_PRIVATE_IP=$(echo $SERVER_PRIVATE_IP | cut -d' ' -f 2);
echo $SERVER_PRIVATE_IP > /tmp/server-ip.txt;

if [ $SERVER_PRIVATE_IP == $APP_SERVER_1_IP  ]; then
  hostnamectl set-hostname $APP_SERVER_1_HOSTNAME;
elif [ $SERVER_PRIVATE_IP == $APP_SERVER_2_IP  ]; then
  hostnamectl set-hostname $APP_SERVER_2_HOSTNAME;
fi;

# Add epel repository if not already install
#ADD_EPEL_REPO

# Install yum config manager if not present
#YUM_CONFIG_MANAGER

# Add swap file
#ADD_SWAP_FILE

cat >> /etc/hosts <<EOF
$STORAGE_SERVER_IP       $STORAGE_SERVER_HOSTNAME store
$DB_SERVER_IP            $DB_SERVER_HOSTNAME db-server
$JUMP_SERVER_IP          $JUMP_SERVER_HOSTNAME jump puppet
$METRIC_SERVER_IP           $METRIC_SERVER_HOSTNAME metrics
EOF

# ./deploy script will replace the line below with puppet configuration during run
# and reverse it after terraform has finished deploying
#PUPPET_CONFIG

# Wait for puppet server to sign CA
#PUPPET_WAIT_1

yum install git -y;
yum install nginx -y;
if [ $? -ne 0 ]; then
  amazon-linux-extras install nginx1 -y;
fi

yum install -y gcc-c++ make;
curl -sL https://rpm.nodesource.com/setup_15.x | sudo -E bash -;
yum install nodejs -y;
echo "Version of node install is $(node --version)";

systemctl enable --now nfs
mkdir /todo-er /data /modela
echo "store:/todo-er /todo-er nfs _netdev 0 0" >> /etc/fstab;
echo "store:/data /data nfs _netdev 0 0" >> /etc/fstab;
echo "store:/modela /modela nfs _netdev 0 0" >> /etc/fstab;
until mount -a; do echo "waiting for nfs mount to succeed"; done

# wait until db is fully set up
until ping -c 3 $DB_SERVER_HOSTNAME; do echo "Waiting for DB Server to be reachable"; done;

# set up systemd units to manage node app behavior
cat >> /etc/systemd/system/todoapp.service <<EOF
[Unit]
Description=Todo-er app
After=network.target
[Service]
PIDFile=/run/todo-er.pid
ExecStartPre=/usr/bin/rm -f /run/todo-er.pid
WorkingDirectory=/todo-er
ExecStart=/bin/npm start
ExecStop=/bin/kill -2 '$MAINPID'
Restart=on-failure
RestartUSec=500ms
StartLimitInterval=0
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=process
PrivateTmp=true
[Install]
WantedBy=multi-user.target
EOF

# Create a service to monitor file changes on the todo-er directory
cat >> /etc/systemd/system/todoapp-watcher.service <<EOF
[Unit]
Description=srv restarter
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/systemctl restart todoapp.service

[Install]
WantedBy=multi-user.target
EOF

# restart the todoapp service when files change
cat >> etc/systemd/system/todoapp-watcher.path <<EOF
[Path]
PathModified=/todo-er/**/*

[Install]
WantedBy=multi-user.target
EOF

# Start the systemd units
systemctl enable todoapp.service
systemctl start todoapp.service
systemctl enable todoapp-watcher.{path,service}
systemctl start todoapp-watcher.{path,service}

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

# Script execution end
END_TIME=$(date +%s)
DURATION=$(echo "$END_TIME - $START" | bc)
echo Execution complete in $DURATION | tee /tmp/duration.txt