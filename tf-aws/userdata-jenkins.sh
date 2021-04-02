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

#ANSIBLE_CONFIG

# Wait for puppet server to apply copyssh.pp
#PUPPET_WAIT_2

## Install and configure Nagios for monitoring
curl https://assets.nagios.com/downloads/nagiosci/install.sh | sh;
yum install -y gcc glibc glibc-common wget \
    unzip httpd php gd gd-devel perl make postfix \
    gettext automake autoconf wget openssl-devel \
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
sed -i '/# You can specify individual object config files as shown below:/a cfg_dir=/usr/local/nagios/etc/servers' /usr/local/nagios/etc/nagios.cfg;
mkdir /usr/local/nagios/etc/servers
cat > /usr/local/nagios/etc/servers/centos.cfg <<EOF
define host {
  use linux-server
  host_name $APP_SERVER_1_HOSTNAME
  alias $APP_SERVER_1_HOSTNAME
  address $APP_SERVER_1_IP
}

define host {
  use linux-server
  host_name $APP_SERVER_2_HOSTNAME
  alias $APP_SERVER_2_HOSTNAME
  address $APP_SERVER_2_IP
}

define host {
  use linux-server
  host_name $LB_SERVER_HOSTNAME
  alias $LB_SERVER_HOSTNAME
  address $LB_SERVER_IP
}

define host {
  use linux-server
  host_name $STORAGE_SERVER_HOSTNAME
  alias $STORAGE_SERVER_HOSTNAME
  address $STORAGE_SERVER_IP
}

define host {
  use linux-server
  host_name $DB_SERVER_HOSTNAME
  alias $DB_SERVER_HOSTNAME
  address $DB_SERVER_IP
}
EOF
systemctl restart nagios;
