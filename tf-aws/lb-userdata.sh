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

NEW_HOSTNAME=${NEW_HOSTNAME}
if [ $NEW_HOSTNAME ]; then
  hostnamectl set-hostname $NEW_HOSTNAME;
fi;

APP_SERVER_1_IP=${APP_SERVER_1_IP}
APP_SERVER_2_IP=${APP_SERVER_2_IP}
APP_SERVER_1_HOSTNAME=${APP_SERVER_1_HOSTNAME} 
APP_SERVER_2_HOSTNAME=${APP_SERVER_2_HOSTNAME}

cat >> /etc/hosts <<EOF

$APP_SERVER_1_IP          $APP_SERVER_1_HOSTNAME
$APP_SERVER_2_IP          $APP_SERVER_2_HOSTNAME

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