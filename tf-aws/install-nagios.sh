curl https://assets.nagios.com/downloads/nagiosci/install.sh | sh;
yum install gcc glibc glibc-common wget gettext automake autoconf unzip httpd php gd gd-devel perl make postfix openssl-devel net-snmp net-snmp-utils epel-release perl-Net-SNMP -y;
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
# Install NRPE Pligin
cd /tmp/;
wget https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-3.2.1/nrpe-3.2.1.tar.gz;
tar zxvf nrpe-3.2.1.tar.gz;
cd nrpe-3.2.1;
./configure --enable-command-args --with-nrpe-user=nagios --with-nrpe-group=nagios;
make all;
make install-plugin;
systemctl restart nagios;

## commands below can be use to test if the install and config is successful
# /usr/local/nagios/libexec/check_nrpe -h;
# /usr/local/nagios/libexec/check_nrpe -H 10.20.10.15 -c 'check_users' -a '5 10

## INSTALL NRPE ON MANAGED HOSTS
## Be mind that NRPE run on port 5666, so ensure firewall is not blocking the port
yum install -y wget gcc glibc glibc-common openssl openssl-devel make gettext automake autoconf net-snmp net-snmp-utils epel-release;
yum install -y perl-Net-SNMP;
cd /tmp/;
wget https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-3.2.1/nrpe-3.2.1.tar.gz;
tar zxvf nrpe-3.2.1.tar.gz;
./configure --enable-command-args --with-nrpe-user=nagios --with-nrpe-group=nagios;
make install-groups-users;
make all;
make install;
make install-config;
make install-init;
echo "nrpe            5666/tcp                # NRPE service" >> /etc/services;
systemctl enable --now nrpe;

# Install Nagios plugins
cd /tmp;
wget https://nagios-plugins.org/download/nagios-plugins-2.2.1.tar.gz;
tar zxvf nagios-plugins-2.2.1.tar.gz;
cd nagios-plugins-2.2.1;
./configure;
make;
make install;
systemctl restart nrpe;

sed -i 's/server_address=127.0.0.1/#server_address=127.0.0.1/' /usr/local/nagios/etc/nrpe.cfg;
sed -i '/#server_address=127.0.0.1/a server_address=10.20.10.15' /usr/local/nagios/etc/nrpe.cfg;
sed -i 's/allowed_hosts=127.0.0.1,::1/allowed_hosts=127.0.0.1,::1,10.20.10.14,10.20.10.15/' /usr/local/nagios/etc/nrpe.cfg;
sed -i 's/dont_blame_nrpe=0/dont_blame_nrpe=1/' /usr/local/nagios/etc/nrpe.cfg;

## Configure the server to enable checking and report to the master

## Run the following checks to confirm the configuration is working
# /usr/local/nagios/libexec/check_nrpe -H
# /usr/local/nagios/libexec/check_nrpe -H 10.20.10.15 -c check_total_procs
# /usr/local/nagios/libexec/check_nrpe -H 10.20.10.15 -c check_users
