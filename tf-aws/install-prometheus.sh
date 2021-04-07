#! /bin/bash

yum update -y;
yum install wget -y;
cd /tmp/;
wget https://github.com/prometheus/prometheus/releases/download/v2.26.0/prometheus-2.26.0.linux-amd64.tar.gz;
useradd --no-create-home --shell /bin/false prometheus;
mkdir /etc/prometheus;
mkdir /var/lib/prometheus;
chown prometheus:prometheus /etc/prometheus;
chown prometheus:prometheus /var/lib/prometheus;
tar -xvzf prometheus-2.26.0.linux-amd64.tar.gz;
mv prometheus-2.26.0.linux-amd64 prometheuspackage;
cp prometheuspackage/{promtool,prometheus} /usr/local/bin/;
chown prometheus:prometheus /usr/local/bin/{prometheus,promtool};
cp -r prometheuspackage/{consoles,console_libraries} /etc/prometheus/;
chown -R prometheus:prometheus /etc/prometheus/{console_libraries,consoles};

SERVER_IP_ADDRESS=$(ip a | grep inet | awk -F' '  '/brd/ { print $4 }');

cat > /etc/prometheus/prometheus.yml <<EOF
global:
  scrape_interval: 10s

scrape_configs:
  - job_name: 'prometheus_master'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']

EOF

chown prometheus:prometheus /etc/prometheus/prometheus.yml;

## Create systemd Unit for prometheus
cat > /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
--config.file /etc/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/promethues/console_libraries

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload;
systemctl start prometheus;

# Add firewall rule to allow port 9090 for prometheus web UI
#firewall-cmd --zone=public --add-port=9090/tcp --permanent;
#systemctl reload firewalld;
## Now access the web UI at http://SERVERIP:9090

## Install and configure Node Exporter
cd /tmp/;
wget https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-amd64.tar.gz;
tar -xvzf node_exporter-1.1.2.linux-amd64.tar.gz;
useradd -rs /bin/false nodeusr;
mv node_exporter-1.1.2.linux-amd64/node_exporter  /usr/local/bin/;

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

## Enable firewall access on port 9100 for node exporter
# firewall-cmd --zone=public --add-port=9100/tcp --permanent;
# systemctl restart firewalld;

## Access node export at http://SERVERIP:9100/metrics

## On the prometheus server add configuration for the node exporter
cat >> /etc/prometheus/prometheus.yml <<EOF
  - job_name: 'node_exporter_centos'
    scrape_interval: 5s
    static_configs:
      - targets: ["$SERVER_IP_ADDRESS:9100"]
EOF

systemctl restart prometheus;

## Install and configure mysqlexporter
# Assum mysql is not already install
systemctl status mariadb;
if [ $? -eq 4 ]; then
  yum install mariadb-server -y;
  systemctl start mariadb;
fi

wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.12.1/mysqld_exporter-0.12.1.linux-amd64.tar.gz
tar -xvzf mysqld_exporter-0.12.1.linux-amd64.tar.gz;
useradd -rs /bin/false mysqld_exporter;
mv mysqld_exporter-0.12.1.linux-amd64/mysqld_exporter /usr/bin/;
chown mysqld_exporter:mysqld_exporter /usr/bin/mysqld_exporter;
mkdir -p /etc/mysql_exporter;

cat > grant.sql <<EOF
CREATE USER 'mysqlexporter'@'localhost' IDENTIFIED BY 'mysqlexporter';
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* to 'mysqlexporter'@'localhost';
FLUSH PRIVILEGES;
EOF

# Execute sql to grant mysqld_exporter db access
mysql -u root < grant.sql

cat > /etc/mysql_exporter/.my.cnf <<EOF 
[client]
user=mysqlexporter
password=mysqlexporter
EOF

chown -R mysqld_exporter:mysqld_exporter /etc/mysql_exporter;
chmod 600 /etc/mysql_exporter/.my.cnf;

cat >  /etc/systemd/system/mysqld_exporter.service <<EOF 
[Unit]
Description=Mysql server exporter
After=Network.target

[Service]
User=mysqld_exporter
Group=mysqld_exporter
Type=simple
ExecStart=/usr/bin/mysqld_exporter --config.my-cnf="/etc/mysql_exporter/.my.cnf"
StartLimitInterval=0
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload;
systemctl start mysqld_exporter;

# If there is problem running the systemd unit, start the exporter manually
# /usr/bin/mysqld_exporter --config.my-cnf="/etc/mysql_exporter/.my.cnf";

cat >> /etc/prometheus/prometheus.yml <<EOF
  - job_name: 'mysqld_exporter_fosslinux'
    scrape_interval: 5s
    static_configs:
      - targets: ["$SERVER_IP_ADDRESS:9104"]
EOF

systemctl restart prometheus;
