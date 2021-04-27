#! /bin/bash

START=$(date +%s)

METRIC_SERVER_HOSTNAME=${METRIC_SERVER_HOSTNAME}
METRIC_SERVER_IP=${METRIC_SERVER_IP}
JENKINS_SERVER_HOSTNAME=${JENKINS_SERVER_HOSTNAME}
JENKINS_SERVER_IP=${JENKINS_SERVER_IP}
JUMP_SERVER_IP=${JUMP_SERVER_IP}
JUMP_SERVER_HOSTNAME=${JUMP_SERVER_HOSTNAME}
DB_SERVER_HOSTNAME=${DB_SERVER_HOSTNAME}
DB_SERVER_IP=${DB_SERVER_IP}
DB_NAME=${DB_NAME}
DB_USER_NAME=${DB_USER_NAME}
DB_USER_PASS=${DB_USER_PASS}
DB_PORT=${DB_PORT}
VPC_CIDR_BLOCK=${VPC_CIDR_BLOCK}

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

if [ DB_SERVER_HOSTNAME ]; then
  hostnamectl set-hostname $DB_SERVER_HOSTNAME
fi;

cat >> /etc/hosts <<EOF
$JUMP_SERVER_IP             $JUMP_SERVER_HOSTNAME jump puppet
$JENKINS_SERVER_IP          $JENKINS_SERVER_HOSTNAME jenkins
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

## Install and configure postgresql DB
yum install postgresql-server postgresql-contrib -y;

if [ $? != 0 ]; then
  sleep 3;
  echo RUNNING ALTERNATE INSTALL
  yum install postgresql-server postgresql-contrib -y;
fi;

postgresql-setup initdb;
sed -i "/# \x22local\x22 is for Unix domain socket connections only/a local    $DB_NAME        $DB_USER_NAME           md5" /var/lib/pgsql/data/pg_hba.conf;
sed -i "/# IPv4 local connections:/a host    $DB_NAME        $DB_USER_NAME         $VPC_CIDR_BLOCK           md5" /var/lib/pgsql/data/pg_hba.conf;
sed -i "/#listen_addresses = 'localhost'/a listen_addresses = \x27*\x27" /var/lib/pgsql/data/postgresql.conf;
systemctl enable --now postgresql;

cat << END >> setup.sql
CREATE USER "$DB_USER_NAME" with PASSWORD '$DB_USER_PASS';
CREATE DATABASE $DB_NAME;
GRANT ALL ON DATABASE $DB_NAME to $DB_USER_NAME;
END

cat setup.sql;

sudo -i -u postgres psql < setup.sql;

# psql -U todoapp -d todoapp -h localhost -p 5432 manaully connect to db

sed -i "/# \x22local\x22 is for Unix domain socket connections only/a local    todoapp        todoapp           md5" /var/lib/pgsql/data/pg_hba.conf;
sed -i "/# IPv4 local connections:/a host    todoapp        todoapp         10.0.0.0/16           md5" /var/lib/pgsql/data/pg_hba.conf;

# Script execution end
END_TIME=$(date +%s)
DURATION=$(echo "$END_TIME - $START" | bc)
echo Execution complete in $DURATION | tee /tmp/duration.txt
