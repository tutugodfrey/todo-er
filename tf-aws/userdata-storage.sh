#! /bin/bash
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
DB_NAME=${DB_NAME}
DB_USER_NAME=${DB_USER_NAME}
DB_USER_PASS=${DB_USER_PASS}
DB_PORT=${DB_PORT}

# Renaming because nrpe requires this name for multiple scripts files
# refer to ./deploy.sh script
SERVER_IP=$STORAGE_SERVER_IP

yum update -y;
# Add epel repository if not already install
#ADD_EPEL_REPO

# Install yum config manager if not present
#YUM_CONFIG_MANAGER

if [ $STORAGE_SERVER_HOSTNAME ]; then
  hostnamectl set-hostname $STORAGE_SERVER_HOSTNAME
fi

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

yum install git -y;
yum install nginx -y;
if [ $? -ne 0 ]; then
  amazon-linux-extras install nginx1 -y;
fi

yum install -y gcc-c++ make;
curl -sL https://rpm.nodesource.com/setup_15.x | sudo -E bash -;
yum install nodejs -y;
echo "Version of node install is $(node --version)";

git clone https://github.com/tutugodfrey/todo-er;
git clone https://github.com/tutugodfrey/modela;
cd /modela;
npm install;
npm test;

cd /todo-er;
npm install;
cp .env.example .env;
IP_ADDRESS=$(wget -qO - http://ipecho.net/plain);
sed -i "s/IP/$IP_ADDRESS/" .env;
sed -i 's/APPPORT/8080/' .env;
echo USE_DB=1 >> .env;
echo DATABASE_URL=postgres://$DB_USER_NAME:$DB_USER_PASS@$DB_SERVER_HOSTNAME:$DB_PORT/$DB_NAME >> .env;

npm run build;

# Set up nfs file server
yum install nfs-utils -y # assume its not already installed
systemctl enable --now  nfs-server
mkdir /data # dir to share
# echo "/data $APP_SERVER_1_HOSTNAME $APP_SERVER_2_HOSTNAME $LB_SERVER_HOSTNAME (rw, no_root_squash)" >> /etc/exports; # mount the share dir
echo "/todo-er $APP_SERVER_1_HOSTNAME $APP_SERVER_2_HOSTNAME (rw,no_root_squash,sync)" >> /etc/exports; # mount the share dir
echo "/data $APP_SERVER_1_HOSTNAME $APP_SERVER_2_HOSTNAME $LB_SERVER_HOSTNAME (rw,no_root_squash,sync)" >> /etc/exports;
echo "/modela $APP_SERVER_1_HOSTNAME $APP_SERVER_2_HOSTNAME $LB_SERVER_HOSTNAME (rw,no_root_squash,sync)" >> /etc/exports;

mount -a
exportfs -av

cd /;

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
