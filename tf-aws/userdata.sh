#! /bin/bash

yum install git -y;
yum install nginx -y;
if [ $? -ne 0 ]; then
  amazon-linux-extras install nginx1 -y;
fi

APP_SERVER_HOSTNAME=${APP_SERVER_HOSTNAME}
APP_SERVER_IP=${APP_SERVER_IP}
STORAGE_SERVER_IP=${STORAGE_SERVER_IP}
STORAGE_SERVER_HOSTNAME=${STORAGE_SERVER_HOSTNAME}
JUMP_SERVER_IP=${JUMP_SERVER_IP}
JUMP_SERVER_HOSTNAME=${JUMP_SERVER_HOSTNAME}
DB_SERVER_HOSTNAME=${DB_SERVER_HOSTNAME}
DB_SERVER_IP=${DB_SERVER_IP}
DB_NAME=${DB_NAME}
DB_USER_NAME=${DB_USER_NAME}
DB_USER_PASS=${DB_USER_PASS}
DB_PORT=${DB_PORT}

# Renaming because nrpe requires this name for multiple scripts files
# refer to ./deploy.sh script
SERVER_IP=$APP_SERVER_IP

if [ $APP_SERVER_HOSTNAME ]; then
  hostnamectl set-hostname $APP_SERVER_HOSTNAME;
fi;

cat >> /etc/hosts <<EOF
$STORAGE_SERVER_IP       $STORAGE_SERVER_HOSTNAME store
$DB_SERVER_IP            $DB_SERVER_HOSTNAME db-server
$JUMP_SERVER_IP          $JUMP_SERVER_HOSTNAME jump puppet
EOF

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

cd /modela;
npm link; # create an npm link

cd /todo-er;
npm link data-modela; # Link cloned data modela to todo-er project

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
