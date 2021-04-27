#! /bin/bash

START=$(date +%s)

METRIC_SERVER_HOSTNAME=${METRIC_SERVER_HOSTNAME}
METRIC_SERVER_IP=${METRIC_SERVER_IP}
JENKINS_SERVER_HOSTNAME=${JENKINS_SERVER_HOSTNAME}
JENKINS_SERVER_IP=${JENKINS_SERVER_IP}
JUMP_SERVER_IP=${JUMP_SERVER_IP}
JUMP_SERVER_HOSTNAME=${JUMP_SERVER_HOSTNAME}
LB_SERVER_HOSTNAME=${LB_SERVER_HOSTNAME}
LB_SERVER_IP=${LB_SERVER_IP}
APP_SERVER_1_IP=${APP_SERVER_1_IP}
APP_SERVER_2_IP=${APP_SERVER_2_IP}
APP_SERVER_1_HOSTNAME=${APP_SERVER_1_HOSTNAME} 
APP_SERVER_2_HOSTNAME=${APP_SERVER_2_HOSTNAME}
STORAGE_SERVER_HOSTNAME=${STORAGE_SERVER_HOSTNAME}
STORAGE_SERVER_IP=${STORAGE_SERVER_IP}

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
if [ $LB_SERVER_HOSTNAME ]; then
  hostnamectl set-hostname $LB_SERVER_HOSTNAME;
fi;

cat >> /etc/hosts <<EOF
$APP_SERVER_1_IP          $APP_SERVER_1_HOSTNAME
$APP_SERVER_2_IP          $APP_SERVER_2_HOSTNAME
$JUMP_SERVER_IP           $JUMP_SERVER_HOSTNAME jump puppet
$STORAGE_SERVER_IP        $STORAGE_SERVER_HOSTNAME store
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

git clone https://github.com/tutugodfrey/todo-er;
cd todo-er;
npm install;
cp .env.example .env;
IP_ADDRESS=$(wget -qO - http://ipecho.net/plain);
sed -i "s/IP/$IP_ADDRESS/" .env;
sed -i 's/8080/80/' .env; # will remove after modify after update content of .env file
# sed -i 's/APPPORT/80/' .env;
npm run build;

# cat >> /etc/nginx/conf.d/app.conf <<EOF
cat > /etc/nginx/nginx.conf <<EOF
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  _;
        root         /usr/share/nginx/html;
        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location /api {
          proxy_pass http://backends;
        }

        location / {
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

#    server {
#        listen       443 ssl http2 default_server;
#        listen       [::]:443 ssl http2 default_server;
#        server_name  _;
#        root         /usr/share/nginx/html;
#
#        ssl_certificate "/etc/pki/nginx/server.crt";
#        ssl_certificate_key "/etc/pki/nginx/private/server.key";
#        ssl_session_cache shared:SSL:1m;
#        ssl_session_timeout  10m;
#        ssl_ciphers HIGH:!aNULL:!MD5;
#        ssl_prefer_server_ciphers on;
#
#        # Load configuration files for the default server block.
#        include /etc/nginx/default.d/*.conf;
#
#        location / {
#        }
#
#        error_page 404 /404.html;
#        location = /404.html {
#        }
#
#        error_page 500 502 503 504 /50x.html;
#        location = /50x.html {
#        }
#    }

}

EOF

systemctl enable --now nginx;
cp -r public /usr/share/nginx/html/;
cp public/{index.html,bundle.js} /usr/share/nginx/html/;

mkdir /data
echo "store:/data /data   nfs _netdev 0 0" >> /etc/fstab
until mount -a; do echo "waiting for nfs mount to succeed"; done;

# ln -s /data/* /usr/share/nginx/html/;

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