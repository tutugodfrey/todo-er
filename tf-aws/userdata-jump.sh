#! /bin/bash

yum update
yum install git -y

# Install node.js
yum install -y gcc-c++ make;
curl -sL https://rpm.nodesource.com/setup_15.x | sudo -E bash -;
yum install nodejs -y;
echo "Version of node install is $(node --version)";

# Clone, install dependencies, build the frontend of the application
git clone https://github.com/tutugodfrey/todo-er;
cd todo-er;
npm install;
cp .env.example .env;
IP_ADDRESS=$(wget -qO - http://ipecho.net/plain);
sed -i "s/IP/$IP_ADDRESS/" .env;
sed -i 's/APPPORT/8080/' .env;
npm run build;
npm test;

J
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

cat >> /etc/hosts <<EOF

$APP_SERVER_1_IP            $APP_SERVER_1_HOSTNAME
$APP_SERVER_2_IP            $APP_SERVER_2_HOSTNAME
$LB_SERVER_IP               $LB_SERVER_HOSTNAME
$JENKINS_SERVER_IP          $JENKINS_SERVER_HOSTNAME
$STORAGE_SERVER_IP          $STORAGE_SERVER_HOSTNAME
$DB_SERVER_IP               $DB_SERVER_HOSTNAME
EOF

if [ $JENKINS_SERVER_HOSTNAME ]; then 
  hostnamectl set-hostname $JUMP_SERVER_HOSTNAME;
fi;
