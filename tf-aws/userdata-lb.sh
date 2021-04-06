#! /bin/bash

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
cd todo-er;
npm install;
cp .env.example .env;
IP_ADDRESS=$(wget -qO - http://ipecho.net/plain);
sed -i "s/IP/$IP_ADDRESS/" .env;
sed -i 's/8080/80/' .env; # will remove after modify after update content of .env file
# sed -i 's/APPPORT/80/' .env;
npm run build;

LB_SERVER_HOSTNAME=${LB_SERVER_HOSTNAME}
LB_SERVER_IP=${LB_SERVER_IP}
APP_SERVER_1_IP=${APP_SERVER_1_IP}
APP_SERVER_2_IP=${APP_SERVER_2_IP}
APP_SERVER_1_HOSTNAME=${APP_SERVER_1_HOSTNAME} 
APP_SERVER_2_HOSTNAME=${APP_SERVER_2_HOSTNAME}
JUMP_SERVER_IP=${JUMP_SERVER_IP}
JUMP_SERVER_HOSTNAME=${JUMP_SERVER_HOSTNAME}
STORAGE_SERVER_HOSTNAME=${STORAGE_SERVER_HOSTNAME}
STORAGE_SERVER_IP=${STORAGE_SERVER_IP}

# Renaming because nrpe requires this name for multiple scripts files
# refer to ./deploy.sh script
SERVER_IP=$LB_SERVER_IP

if [ $LB_SERVER_HOSTNAME ]; then
  hostnamectl set-hostname $LB_SERVER_HOSTNAME;
fi;

cat >> /etc/hosts <<EOF

$APP_SERVER_1_IP          $APP_SERVER_1_HOSTNAME
$APP_SERVER_2_IP          $APP_SERVER_2_HOSTNAME
$JUMP_SERVER_IP           $JUMP_SERVER_HOSTNAME jump puppet
$STORAGE_SERVER_IP        $STORAGE_SERVER_HOSTNAME store

EOF

cat >> /etc/nginx/conf.d/app.conf <<EOF
server {
    listen       80;
    listen       [::]:80;
    server_name  _;
    root         /usr/share/nginx/html;
    # Load configuration files for the default server block.
    include /etc/nginx/default.d/*.conf;

    location /api {
      proxy_pass http://backends;
    }

    error_page 404 /404.html;
        location = /40x.html {
    }

    error_page 500 502 503 504 /50x.html;
        location = /50x.html {
    }
}

upstream backends {
  server app1.todo.com:8080;
  server app2.todo.com:8080;
}
EOF

systemctl enable --now nginx;
cp -r public /usr/share/nginx/html/;
cp public/{index.html,bundle.js} /usr/share/nginx/html/;

mkdir /data
echo "store:/data /data   nfs _netdev 0 0" >> /etc/fstab
until mount -a; do echo "waiting for nfs mount to succeed"; done;

# ln -s /data/* /usr/share/nginx/html/;

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