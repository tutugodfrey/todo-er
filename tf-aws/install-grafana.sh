#! /bin/bash

## Grafana runs on port 3000, ensure firewall is not blocking
cat > /etc/yum.repos.d/grafana.repo <<EOF
[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF

yum install grafana -y;
yum install urw-base35-fonts-20170801-10.el7 -y;
yum install freetype* -y;
systemctl enable --now grafana-server;
grafana-cli plugins install alexanderzobnin-zabbix-app;
systemctl restart grafana-server;
