#! /bin/bash

yum update

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
DB_NAME=${DB_NAME}
DB_USER_NAME=${DB_USER_NAME}
DB_USER_PASS=${DB_USER_PASS}
DB_PORT=${DB_PORT}

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

#ANSIBLE_CONFIG

# Wait for puppet server to apply copyssh.pp
#PUPPET_WAIT_2
