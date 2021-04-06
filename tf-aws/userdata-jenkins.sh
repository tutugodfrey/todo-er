#! /bin/bash

yum install java-1.8.0 -y;
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo;
rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key;
yum install jenkins -y;
yum install postgresql -y # needed to connect to db during test
systemctl enable jenkins;
systemctl start jenkins;

JENKINS_SERVER_HOSTNAME=${JENKINS_SERVER_HOSTNAME}
JENKINS_SERVER_IP=${JENKINS_SERVER_IP}


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
SERVER_IP=${JENKINS_SERVER_IP}
NAGIOS_ADMIN_PASSWD=${NAGIOS_ADMIN_PASSWD}

if [ $JENKINS_SERVER_HOSTNAME ]; then
  hostnamectl set-hostname $JENKINS_SERVER_HOSTNAME;
fi;

cat >> /etc/hosts <<EOF
$APP_SERVER_1_IP            $APP_SERVER_1_HOSTNAME app1
$APP_SERVER_2_IP            $APP_SERVER_2_HOSTNAME app2
$LB_SERVER_IP               $LB_SERVER_HOSTNAME lb
$JENKINS_SERVER_IP          $JENKINS_SERVER_HOSTNAME jenkins
$STORAGE_SERVER_IP          $STORAGE_SERVER_HOSTNAME store
$JUMP_SERVER_IP             $JUMP_SERVER_HOSTNAME jump puppet
$DB_SERVER_IP               $DB_SERVER_HOSTNAME db
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

## Install and configure Nagios for monitoring
curl https://assets.nagios.com/downloads/nagiosci/install.sh | sh;
yum install -y gcc glibc glibc-common wget \
    unzip httpd php gd gd-devel perl make postfix \
    gettext automake autoconf wget openssl openssl-devel \
    net-snmp net-snmp-utils epel-release perl-Net-SNMP -y;
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
cat > /usr/local/nagios/etc/objects/servers/hosts.cfg <<EOF
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
    contact_groups              admins
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
  contact_groups                admins
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
  contactgroup_name     admins
  alias                 admins
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
      - targets ["$LB_SERVER_IP:9100"]
  - job_name: 'DB Server'
    scrape_interval: 5s
    static_configs:
      - targets: ["$DB_SERVER_IP:9100"]
  - job_name: 'Storage Server'
    scrape_interval: 5s
    static_configs:
      - targets: ["$STORAGE_SERVER_IP:9100"]
  

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
