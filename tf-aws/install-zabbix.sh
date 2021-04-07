#! /bin/bash

## Install zabbix
yum -y install httpd;
systemctl enable --now httpd;
yum -y install epel-release;
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

cat > zabbixdb.sql <<EOF
Create database zabbixdb;
create user 'zabbixuser'@'localhost' identified BY 'zabbixps';
grant all privileges on zabbixdb.* to zabbixuser@localhost;
alter database zabbixdb character set utf8 collate utf8_bin;
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
user=zabbixuser
password=zabbixps
EOF
# zcat create.sql.gz | mysql --defaults-extra-file=/etc/zabbix/.my.cnf -D zabbixdb;
zcat create.sql.gz | mysql -u root -D zabbixdb;

# Add database configuration to zabbix config file
sed -i 's/DBHost=localhost/DBHost=myhost/' /etc/zabbix/zabbix_server.conf;
sed -i 's/DBName=zabbix/DBName=zabbixdb/' /etc/zabbix/zabbix_server.conf;
sed -i 's/# DBPassword=/DBPassword=zabbixps/' /etc/zabbix/zabbix_server.conf;
sed -i 's/DBUser=zabbix/DBUser=zabbixuser/' /etc/zabbix/zabbix_server.conf;

# Update php config to zabbix requirement
sed -i 's/post_max_size = 8M/post_max_size = 16M/' /etc/php.ini;
sed -i 's/max_execution_time = 30/max_execution_time = 300/' /etc/php.ini;
sed -i 's/max_input_time = 60/max_input_time = 300/' /etc/php.ini;

sed -i 's|PidFile=/var/run/zabbix/zabbix_server.pid|PidFile=/run/zabbix/zabbix_server.pid|' /etc/zabbix/zabbix_server.conf

systemctl restart zabbix-server;
systemctl enable --now zabbix-agent;
systemctl restart httpd;


# https://www.zabbix.com/documentation/current/manual/appendix/install/db_charset_coll
# SELECT @@character_set_database, @@collation_database;
# alter database zabbixdb character set utf8 collate utf8_bin;
# wget https://support.zabbix.com/secure/attachment/113858/113858_utf8_convert.sql

# Troubleshooting selinux issue with zabbix
# https://catonrug.blogspot.com/2014/08/zabbix-server-is-not-running-information-displayed-may-not-be-current.html
# https://gist.github.com/gnh1201/5910a041ac7bc592cd521cfc0e93ddf3
# grep zabbix /var/log/audit/audit.log | grep  denied
# sesearch -T -s zabbix_t -t tmp_t
# getsebool httpd_can_network_connect
# setsebool httpd_can_network_connect on
# tail -f /var/log/audit/audit.log |grep -i avc
# yum install policycoreutils-python
# grep zabbix_t /var/log/audit/audit.log | audit2allow -M zabbix_server_custom
# semodule -i zabbix_server_custom.pp
# systemctl status zabbix-server
# getsebool -a | grep zabbix
# setsebool -P zabbix_can_network=1