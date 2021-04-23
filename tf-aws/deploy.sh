#! /bin/bash

# This script will be used to execute the terraform deployment
# To ensure the idempotent and keep the files the same
# changes made during the execution of the script will be reversed 
# after successful execution. For example when changing variables in devars.tfvars file.

# envfile should be prevent in the terraform directory
# and should contain values for the listed below 
. ./envfile

# Substitute variable values in
DB_NAME=${DB_NAME}
DB_USERNAME=${DB_USERNAME}
DB_PASSWD=${DB_PASSWD}
ANSIBLE_PASSWD=${ANSIBLE_PASSWD}
NAGIOS_ADMIN_PASSWD=${NAGIOS_ADMIN_PASSWD}
ZABBIX_USERNAME=${ZABBIX_USERNAME}
ZABBIX_DB=${ZABBIX_DB}
ZABBIX_PS=${ZABBIX_PS}

sed -i -e "s/DB_NAME/${DB_NAME}/" devars.tfvars
sed -i -e "s/DB_USERNAME/${DB_USERNAME}/" devars.tfvars
sed -i -e "s/DB_PASSWD/${DB_PASSWD}/" devars.tfvars
sed -i -e "s/ANSIBLE_PASSWD/${ANSIBLE_PASSWD}/" devars.tfvars
sed -i -e "s/NAGIOS_ADMIN_PASSWD/${NAGIOS_ADMIN_PASSWD}/" devars.tfvars

# Username and password for our servers
sed -i -e "s/JUMP_SERVER_USERNAME/${JUMP_SERVER_USERNAME}/" devars.tfvars
sed -i -e "s/JUMP_SERVER_PW/${JUMP_SERVER_PW}/" devars.tfvars
sed -i -e "s/APP_SERVER_1_USERNAME/${APP_SERVER_1_USERNAME}/" devars.tfvars
sed -i -e "s/APP_SERVER_1_PW/${APP_SERVER_1_PW}/" devars.tfvars
sed -i -e "s/APP_SERVER_2_USERNAME/${APP_SERVER_2_USERNAME}/" devars.tfvars
sed -i -e "s/APP_SERVER_2_PW/${APP_SERVER_2_PW}/" devars.tfvars
sed -i -e "s/LB_SERVER_USERNAME/${LB_SERVER_USERNAME}/" devars.tfvars
sed -i -e "s/LB_SERVER_PW/${LB_SERVER_PW}/" devars.tfvars
sed -i -e "s/DB_SERVER_USERNAME/${DB_SERVER_USERNAME}/" devars.tfvars
sed -i -e "s/DB_SERVER_PW/${DB_SERVER_PW}/" devars.tfvars
sed -i -e "s/STORAGE_SERVER_USERNAME/${STORAGE_SERVER_USERNAME}/" devars.tfvars
sed -i -e "s/STORAGE_SERVER_PW/${STORAGE_SERVER_PW}/" devars.tfvars
sed -i -e "s/JENKINS_SERVER_USERNAME/${JENKINS_SERVER_USERNAME}/" devars.tfvars
sed -i -e "s/JENKINS_SERVER_PW/${JENKINS_SERVER_PW}/" devars.tfvars
sed -i -e "s/METRIC_SERVER_USERNAME/${METRIC_SERVER_USERNAME}/" devars.tfvars
sed -i -e "s/METRIC_SERVER_PW/${METRIC_SERVER_PW}/" devars.tfvars
sed -i -e "s/ZABBIX_USERNAME/${ZABBIX_USERNAME}/" devars.tfvars
sed -i -e "s/ZABBIX_DB/${ZABBIX_DB}/" devars.tfvars
sed -i -e "s/ZABBIX_PS/${ZABBIX_PS}/" devars.tfvars

cat > puppet <<EOF
rpm -Uvh https://yum.puppet.com/puppet/puppet-release-el-7.noarch.rpm; \
yum install puppet-agent -y; \
yum install bind-utils -y; \
echo export PATH=/opt/puppetlabs/bin/:$PATH >> /root/.bash_profile; \
source /root/.bash_profile; \
puppet config set server "puppet" --section main; \
puppet config set runinterval 10 --section main; \
puppet resource service puppet ensure=running enable=true; \
systemctl enable --now puppet;
EOF

# Script to configure Ansible on slave nodes
cat > ansible <<EOF
useradd -G wheel ansible -m; \
echo $ANSIBLE_PASSWD \| passwd --stdin ansible; \
sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config; \
sed -i "s/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/" /etc/ssh/sshd_config; \
systemctl restart sshd; \
echo 'ansible ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/ansible; \
mkdir /home/ansible/.ssh; \
touch /home/ansible/.ssh/authorized_keys; \
chmod 600 /home/ansible/.ssh/authorized_keys; \
chmod 700 /home/ansible/.ssh; \
chown ansible:ansible /home/ansible/.ssh; \
chown ansible:ansible /home/ansible/.ssh/authorized_keys;
EOF

cat > nrpe <<EOF
yum install -y wget gcc glibc glibc-common openssl openssl-devel make gettext automake autoconf net-snmp net-snmp-utils epel-release; \
yum install -y perl-Net-SNMP; \
cd /tmp/; \
wget https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-3.2.1/nrpe-3.2.1.tar.gz; \
tar zxvf nrpe-3.2.1.tar.gz; \
cd nrpe-3.2.1; \
./configure --enable-command-args --with-nrpe-user=nagios --with-nrpe-group=nagios; \
make install-groups-users; \
make all; \
make install; \
make install-config; \
make install-init; \
echo "nrpe            5666/tcp                # NRPE service" >> /etc/services; \
systemctl enable --now nrpe; \
cd /tmp; \
wget https://nagios-plugins.org/download/nagios-plugins-2.2.1.tar.gz; \
tar zxvf nagios-plugins-2.2.1.tar.gz; \
cd nagios-plugins-2.2.1; \
./configure; \
make; \
make install; \
systemctl restart nrpe; \
sed -i 's/server_address=127.0.0.1/#server_address=127.0.0.1/' /usr/local/nagios/etc/nrpe.cfg; \
sed -i "/#server_address=127.0.0.1/a server_address=\$SERVER_IP" /usr/local/nagios/etc/nrpe.cfg; \
sed -i "s/allowed_hosts=127.0.0.1,::1/allowed_hosts=127.0.0.1,::1,\$SERVER_IP,\${METRIC_SERVER_IP}/" /usr/local/nagios/etc/nrpe.cfg; \
sed -i 's/dont_blame_nrpe=0/dont_blame_nrpe=1/' /usr/local/nagios/etc/nrpe.cfg;
EOF

cat > nodeexporter <<EOF
cd /tmp; \
wget https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-amd64.tar.gz; \
tar -xvzf node_exporter-1.1.2.linux-amd64.tar.gz; \
useradd -rs /bin/false nodeusr; \
mv node_exporter-1.1.2.linux-amd64/node_exporter  /usr/local/bin/;
EOF

cat > zabbixagent <<EOF
rpm -ivh https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm; \
yum install zabbix-agent -y; \
sed -i "s/ServerActive=127.0.0.1/ServerActive=\$SERVER_IP/" /etc/zabbix/zabbix_agentd.conf; \
sed -i "s/Server=127.0.0.1/Server=\$SERVER_IP/" /etc/zabbix/zabbix_agentd.conf; \
sed -i "s/Hostname=Zabbix server/Hostname=master/" /etc/zabbix/zabbix_agentd.conf; \
systemctl enable --now zabbix-agent;
EOF

ADD_SWAP_FILE='fallocate -l 512M /swapfile; chmod 600 /swapfile; mkswap /swapfile; swapon /swapfile;'
ADD_EPEL_REPO='ls \/etc\/yum.repos.d\/ | grep epel; if [ $? -ne 0 ]; then  amazon-linux-extras install epel -y;  fi;'
YUM_CONFIG_MANAGER='yum-config-manager > \/dev\/null; if [ $? -ne 0 ]; then yum install yum-utils -y; fi; yum-config-manager enable epel;'
PUPPET_WAIT_1='counter=0; until puppet agent -t || [ $counter -gt 15 ] ; do echo Wait for puppet CA Signing; sleep 3; ((counter++)); done;'
PUPPET_WAIT_2='counter=0; until puppet agent -t || [ $counter -gt 15 ] ; do echo Attempting pull for ansible ssh key; sleep 3; ((counter++)); done;'

# Inject the setup script to the various userdata scripts
sed -i -e "s|#ADD_SWAP_FILE|&\n$(echo $ADD_SWAP_FILE)|" {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage,userdata-jump,userdata-metrics}.sh
sed -i -e "s/#ADD_EPEL_REPO/&\n$(echo $ADD_EPEL_REPO)/" {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage,userdata-jump,userdata-metrics}.sh
sed -i -e "s/#YUM_CONFIG_MANAGER/&\n$(echo $YUM_CONFIG_MANAGER)/" {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage,userdata-jump,userdata-metrics}.sh
sed -i -e "s|#PUPPET_CONFIG|$(cat puppet)|" {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage,userdata-jump,userdata-metrics}.sh
# Not include the jump server to avoid block the execution
# sed -i -e "/#PUPPET_WAIT_1/a $(echo $PUPPET_WAIT_1)" {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage}.sh
sed -i -e "s/PUPPET_WAIT_1/&\n$(echo $PUPPET_WAIT_1)/" {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage,userdata-metrics}.sh
sed -i -e "s|#ANSIBLE_CONFIG|$(cat ansible)|" {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage,userdata-metrics}.sh
sed -i -e "s/#PUPPET_WAIT_2/&\n$(echo $PUPPET_WAIT_2)/" {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage,userdata-metrics}.sh
sed -i -e "s|#NRPE|$(cat nrpe)|" {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage,userdata-jump}.sh
sed -i -e "s|#NODEEXPORTER|$(cat nodeexporter)|" {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage,userdata-jump}.sh
sed -i -e "s|#ZABBIXAGENT|$(cat zabbixagent)|" {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage,userdata-jump}.sh

# EXECUTE TERRAFORM APPLY
terraform apply --auto-approve -var-file devars.tfvars

sleep 5

# Reverse the changes after terraform successful deploy
sed -i -e "s/${DB_NAME}/DB_NAME/" devars.tfvars
sed -i -e "s/${DB_USERNAME}/DB_USERNAME/" devars.tfvars
sed -i -e "s/${DB_PASSWD}/DB_PASSWD/" devars.tfvars
sed -i -e "s/${ANSIBLE_PASSWD}/ANSIBLE_PASSWD/" devars.tfvars
sed -i -e "s/${NAGIOS_ADMIN_PASSWD}/NAGIOS_ADMIN_PASSWD/" devars.tfvars

sed -i -e "s/${JUMP_SERVER_USERNAME}/JUMP_SERVER_USERNAME/" devars.tfvars
sed -i -e "s/${JUMP_SERVER_PW}/JUMP_SERVER_PW/" devars.tfvars
sed -i -e "s/${APP_SERVER_1_USERNAME}/APP_SERVER_1_USERNAME/" devars.tfvars
sed -i -e "s/${APP_SERVER_1_PW}/APP_SERVER_1_PW/" devars.tfvars
sed -i -e "s/${APP_SERVER_2_USERNAME}/APP_SERVER_2_USERNAME/" devars.tfvars
sed -i -e "s/${APP_SERVER_2_PW}/APP_SERVER_2_PW/" devars.tfvars
sed -i -e "s/${LB_SERVER_USERNAME}/LB_SERVER_USERNAME/" devars.tfvars
sed -i -e "s/${LB_SERVER_PW}/LB_SERVER_PW/" devars.tfvars
sed -i -e "s/${DB_SERVER_USERNAME}/DB_SERVER_USERNAME/" devars.tfvars
sed -i -e "s/${DB_SERVER_PW}/DB_SERVER_PW/" devars.tfvars
sed -i -e "s/${STORAGE_SERVER_USERNAME}/STORAGE_SERVER_USERNAME/" devars.tfvars
sed -i -e "s/${STORAGE_SERVER_PW}/STORAGE_SERVER_PW/" devars.tfvars
sed -i -e "s/${JENKINS_SERVER_USERNAME}/JENKINS_SERVER_USERNAME/" devars.tfvars
sed -i -e "s/${JENKINS_SERVER_PW}/JENKINS_SERVER_PW/" devars.tfvars
sed -i -e "s/${METRIC_SERVER_USERNAME}/METRIC_SERVER_USERNAME/" devars.tfvars
sed -i -e "s/${METRIC_SERVER_PW}/METRIC_SERVER_PW/" devars.tfvars
sed -i -e "s/${ZABBIX_USERNAME}/ZABBIX_USERNAME/" devars.tfvars
sed -i -e "s/${ZABBIX_DB}/ZABBIX_DB/" devars.tfvars
sed -i -e "s/${ZABBIX_PS}/ZABBIX_PS/" devars.tfvars

# Reverse the content of the userdata scripts to their original state
sed -i -e '/#ADD_SWAP_FILE/{n;d;}' {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage,userdata-jump,userdata-metrics}.sh
sed -i -e '/#ADD_EPEL_REPO/{n;d;}' {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage,userdata-jump,userdata-metrics}.sh
sed -i -e '/#YUM_CONFIG_MANAGER/{n;d;}' {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage,userdata-jump,userdata-metrics}.sh
sed -i -e "s|$(cat puppet)|#PUPPET_CONFIG|" {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage,userdata-jump,userdata-metrics}.sh
sed -i -e '/#PUPPET_WAIT_1/{n;d;}' {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage,userdata-metrics}.sh
sed -i -e "s|$(cat ansible)|#ANSIBLE_CONFIG|" {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage,userdata-metrics}.sh
sed -i -e '/#PUPPET_WAIT_2/{n;d;}' {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage,userdata-metrics}.sh
sed -i -e "s|$(cat nrpe)|#NRPE|" {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage,userdata-jump}.sh
sed -i -e "s|$(cat nodeexporter)|#NODEEXPORTER|" {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage,userdata-jump}.sh
sed -i -e "s|$(cat zabbixagent)|#ZABBIXAGENT|" {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage,userdata-jump}.sh

# sed -i -e '/#PUPPET_WAIT_2/{n;d;}' exclusive
# sed -i -e '/#PUPPET_WAIT_2/{N;d;}' example of inclusive delete

# Were are not keeping the files
rm {puppet,ansible,nrpe,nodeexporter,zabbixagent}
