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
SERVER_IP=${JENKINS_SERVER_IP}
NAGIOS_ADMIN_PASSWD=${NAGIOS_ADMIN_PASSWD}
ZABBIX_USERNAME=${ZABBIX_USERNAME}
ZABBIX_DB=${ZABBIX_DB}
ZABBIX_PS=${ZABBIX_PS}

# Renaming because nrpe requires this name for multiple scripts files
# refer to ./deploy.sh script
SERVER_IP=$METRIC_SERVER_IP

# Add epel repository if not already install
#ADD_EPEL_REPO

# Install yum config manager if not present
#YUM_CONFIG_MANAGER

yum update -y;

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

if [ $METRIC_SERVER_HOSTNAME ]; then 
  hostnamectl set-hostname $METRIC_SERVER_HOSTNAME;
fi;

# ./deploy script will replace the line below with puppet configuration during run
# and reverse it after terraform has finished deploying
#PUPPET_CONFIG

# Wait for puppet server to sign CA
#PUPPET_WAIT_1

# Add configuration for Ansible user
#ANSIBLE_CONFIG

# Wait for puppet server to apply copyssh.pp
#PUPPET_WAIT_2

## Install and configure Nagios for monitoring
curl https://assets.nagios.com/downloads/nagiosci/install.sh | sh;
yum install -y gcc glibc glibc-common wget \
    unzip httpd php gd gd-devel perl make postfix \
    gettext automake autoconf wget openssl openssl-devel \
    net-snmp net-snmp-utils perl-Net-SNMP -y;
cd /tmp;
wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.6.tar.gz;
wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.2.1.tar.gz;
tar xzf nagioscore.tar.gz;
tar zxf nagios-plugins.tar.gz;
cd /tmp/nagioscore-nagios-4.4.6;
./configure;
useradd nagios;
usermod -a -G nagios apache;
make all;
make install;
make install-init;
make install-commandmode;
make install-config;
make install-webconf;
htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin $NAGIOS_ADMIN_PASSWD;
systemctl enable --now httpd;
systemctl enable --now nagios;
cd /tmp/nagios-plugins-release-2.2.1/;
./tools/setup;
./configure;
make;
make install;

# Install Nagios NRPE Pligin
cd /tmp/;
wget https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-3.2.1/nrpe-3.2.1.tar.gz;
tar zxvf nrpe-3.2.1.tar.gz;
cd nrpe-3.2.1;
./configure --enable-command-args --with-nrpe-user=nagios --with-nrpe-group=nagios;
make all;
make install-plugin;
systemctl restart nagios;

sed -i '/# You can specify individual object config files as shown below:/a cfg_dir=/usr/local/nagios/etc/objects/servers/' /usr/local/nagios/etc/nagios.cfg;
mkdir /usr/local/nagios/etc/objects/servers/
cd /usr/local/nagios/etc/objects/servers/
cat > hosts.cfg <<EOF
define host {
  use                 manage-hosts
  host_name           $APP_SERVER_1_HOSTNAME
  alias               $APP_SERVER_1_HOSTNAME
  address             $APP_SERVER_1_IP
}

define host {
  use                 manage-hosts
  host_name           $APP_SERVER_2_HOSTNAME
  alias               $APP_SERVER_2_HOSTNAME
  address             $APP_SERVER_2_IP
}

define host {
  use                 manage-hosts
  host_name           $LB_SERVER_HOSTNAME
  alias               $LB_SERVER_HOSTNAME
  address             $LB_SERVER_IP
}

define host {
  use                 manage-hosts
  host_name           $STORAGE_SERVER_HOSTNAME
  alias               $STORAGE_SERVER_HOSTNAME
  address             $STORAGE_SERVER_IP
}

define host {
  use                 manage-hosts
  host_name           $DB_SERVER_HOSTNAME
  alias               $DB_SERVER_HOSTNAME
  address             $DB_SERVER_IP
  # contact_groups admins
}

define host {
  use                 manage-hosts
  host_name           $JENKINS§_SERVER_HOSTNAME
  alias               $JENKINS§_SERVER_HOSTNAME
  address             $JENKINS§_SERVER_IP
  # contact_groups admins
}
EOF

cat > hostgroups.cfg <<EOF
define hostgroup {
  hostgroup_name appservers
  alias     Linux Server
  members   $APP_SERVER_1_HOSTNAME,$APP_SERVER_2_HOSTNAME
}
EOF

cat > hosts-service-template.cfg  <<EOF
define host {
  name                      manage-hosts
  notifications_enabled         1
  event_handler_enabled         1
  flap_detection_enabled        1
  process_perf_data             1
  retain_status_information     1
  retain_nonstatus_information  1
    check_command                check-host-alive
    check_interval              5
    max_check_attempts          2
    notification_interval       0
    notification_period         24x7
    notification_options        d,u,r
    register                    0
    contact_groups              todo-app-admins
}


# Define a service template

define service {
  name                  my-hosts-service
  active_checks_enabled 1
  passive_checks_enabled        1
  parallelize_check             1
  obsess_over_service           1
  check_freshness               0
  notifications_enabled         1
  event_handler_enabled         1
  flap_detection_enabled        1
  process_perf_data             1
  retain_status_information     1
  retain_nonstatus_information  1
  notification_interval         0
  is_volatile                   0
  check_period                  24x7
  check_interval                5
  retry_interval                1
  max_check_attempts            2
  notification_period           24x7
  notification_options          w,u,c,r
  contact_groups                todo-app-admins
  register                      0
}
EOF

cat > contacts.cfg <<EOF
define contact {
  contact_name          godfrey
  use                   generic-contact
  alias                 Tutu Godfrey
  email                 godfrey_tutu@yahoo.com
}

define contact {
  contact_name          tutu
  use                   generic-contact
  alias                 Godfrey Tutu
  email                 tutugodfrey@gmail.com
}

# Define contact group
define contactgroup {
  contactgroup_name     todo-app-admins
  alias                 todo-app-admins
  members               tutu,godfrey
}
EOF

systemctl restart nagios;

## Setup install and configure prometheus
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

cat > /etc/prometheus/prometheus.yml <<EOF
global:
  scrape_interval: 10s

scrape_configs:
  - job_name: 'prometheus_master'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'Jump Server'
    scrape_interval: 5s
    static_configs:
      - targets: ["$JUMP_SERVER_IP:9100"]
  - job_name: 'App Server 1'
    scrape_interval: 5s
    static_configs:
      - targets: ["$APP_SERVER_1_IP:9100"]
  - job_name: 'App Server 2'
    scrape_interval: 5s
    static_configs:
      - targets: ["$APP_SERVER_2_IP:9100"]
  - job_name: 'LB Server'
    scrape_interval: 5s
    static_configs:
      - targets: ["$LB_SERVER_IP:9100"]
  - job_name: 'DB Server'
    scrape_interval: 5s
    static_configs:
      - targets: ["$DB_SERVER_IP:9100"]
  - job_name: 'Storage Server'
    scrape_interval: 5s
    static_configs:
      - targets: ["$STORAGE_SERVER_IP:9100"]
  - job_name: 'Storage Server'
    scrape_interval: 5s
    static_configs:
      - targets: ["$JENKINS_SERVER_IP:9100"]
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

## Install zabbix
yum -y install httpd;
systemctl enable --now httpd;
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y;

# yum-config-manager: command not found; install yum-utils
yum install yum-utils -y;
yum-config-manager --disable remi-php54;
yum-config-manager --enable remi-php72;
yum install php php-pear php-cgi php-common php-mbstring php-snmp php-gd php-pecl-mysql php-xml php-mysql php-gettext php-bcmath -y;
sed -i '/;date.timezone =/a date.timezone = UTC' /etc/php.ini;
yum --enablerepo=remi install mariadb-server -y;
systemctl start mariadb.service;
systemctl enable mariadb;


useradd -s /bin/false -M $ZABBIX_USERNAME;
cat > zabbixdb.sql <<EOF
Create database ${ZABBIX_DB};
create user '${ZABBIX_USERNAME}'@'localhost' identified BY '${ZABBIX_PS}';
grant all privileges on ${ZABBIX_DB}.* to ${ZABBIX_USERNAME}@localhost;
alter database ${ZABBIX_DB} character set utf8 collate utf8_bin;
flush privileges;
EOF

cat > /root/.my.cnf <<EOF
[client]
user=root
#password=myroot
EOF
# mysql --defaults-extra-file=/root/.my.cnf < zabbixdb.sql;
mysql -u root < zabbixdb.sql;
rpm -ivh https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm;
yum install zabbix-server-mysql  zabbix-web-mysql zabbix-agent zabbix-get -y;
sed -i '/# php_value date.timezone/a \        php_value date.timezone UTC' /etc/httpd/conf.d/zabbix.conf;
cd /usr/share/doc/zabbix-server-mysql-4.0.30/;

cat > /etc/zabbix/.my.cnf <<EOF
[client]
user=$ZABBIX_USERNAME
password=$ZABBIX_PS
EOF
# zcat create.sql.gz | mysql --defaults-extra-file=/etc/zabbix/.my.cnf -D zabbixdb;
zcat create.sql.gz | mysql -u root -D $ZABBIX_DB;

# Add database configuration to zabbix config file
# sed -i 's/DBHost=localhost/DBHost=myhost/' /etc/zabbix/zabbix_server.conf;
sed -i 's/DBName=zabbix/DBName=${ZABBIX_DB}/' /etc/zabbix/zabbix_server.conf;
sed -i 's/# DBPassword=/DBPassword=${ZABBIX_PS}/' /etc/zabbix/zabbix_server.conf;
sed -i 's/DBUser=zabbix/DBUser=${ZABBIX_USERNAME}/' /etc/zabbix/zabbix_server.conf;

# Update php config to zabbix requirement
sed -i 's/post_max_size = 8M/post_max_size = 16M/' /etc/php.ini;
sed -i 's/max_execution_time = 30/max_execution_time = 300/' /etc/php.ini;
sed -i 's/max_input_time = 60/max_input_time = 300/' /etc/php.ini;

sed -i 's|PidFile=/var/run/zabbix/zabbix_server.pid|PidFile=/run/zabbix/zabbix_server.pid|' /etc/zabbix/zabbix_server.conf

systemctl restart zabbix-server;
systemctl enable --now zabbix-agent;
systemctl restart httpd;
