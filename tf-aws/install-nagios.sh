curl https://assets.nagios.com/downloads/nagiosci/install.sh | sh;
yum install -y gcc glibc glibc-common wget unzip httpd php gd gd-devel perl make postfix -y;
cd /tmp;
wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.6.tar.gz;
tar xzf nagioscore.tar.gz;
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
htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin NAGIOS_ADMIN_PASSWD;
systemctl enable --now httpd;
systemctl enable --now nagios;
yum install -y gcc glibc glibc-common make gettext automake autoconf wget openssl-devel net-snmp net-snmp-utils epel-release perl-Net-SNMP;
cd /tmp;
wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.2.1.tar.gz;
tar zxf nagios-plugins.tar.gz;
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
  host_name lcsa-centos
  alias lcsa-centos
  address 35.238.18.234
}
EOF
systemctl restart nagios;
