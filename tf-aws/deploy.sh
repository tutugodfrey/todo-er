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

sed -i -e "s/DB_NAME/${DB_NAME}/" devars.tfvars
sed -i -e "s/DB_USERNAME/${DB_USERNAME}/" devars.tfvars
sed -i -e "s/DB_PASSWD/${DB_PASSWD}/" devars.tfvars
sed -i -e "s/ANSIBLE_PASSWD/${ANSIBLE_PASSWD}/" devars.tfvars
sed -i -e "s/NAGIOS_ADMIN_PASSWD/${NAGIOS_ADMIN_PASSWD}/" devars.tfvars

cat > puppet <<EOF
rpm -Uvh https://yum.puppet.com/puppet/puppet-release-el-7.noarch.rpm; \
yum install puppet-agent -y; \
yum install bind-utils -y; \
echo export PATH=/opt/puppetlabs/bin:\$PATH >> .bash_profile; \
. .bash_profile; \
puppet config set server "puppet" --section main; \
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

PUPPET_WAIT_1='counter=0; until puppet agent -t || [ $counter -gt 15 ] ; do echo Wait for puppet CA Signing; sleep 3; ((counter++)); done;'
PUPPET_WAIT_2='counter=0; until puppet agent -t || [ $counter -gt 15 ] ; do echo Attempting pull for ansible ssh key; sleep 3; ((counter++)); done;'

# Inject the setup script to the various userdata scripts
sed -i -e "s|#PUPPET_CONFIG|$(cat puppet)|" {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage,userdata-jump}.sh
# Not include the jump server to avoid block the execution
sed -i -e "s/#PUPPET_WAIT_1/$(echo $PUPPET_WAIT_1)/" {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage}.sh
sed -i -e "s|#ANSIBLE_CONFIG|$(cat ansible)|" {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage}.sh
sed -i -e "s/#PUPPET_WAIT_2/$(echo $PUPPET_WAIT_2)/" {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage}.sh

# execute terraform
terraform apply --auto-approve -var-file devars.tfvars

sleep 5

echo $PUPPET_WAIT_1

echo $PUPPET_WAIT_2

# Reverse the changes after terraform successful deploy
sed -i -e "s/${DB_NAME}/DB_NAME/" devars.tfvars
sed -i -e "s/${DB_USERNAME}/DB_USERNAME/" devars.tfvars
sed -i -e "s/${DB_PASSWD}/DB_PASSWD/" devars.tfvars
sed -i -e "s/${ANSIBLE_PASSWD}/ANSIBLE_PASSWD/" devars.tfvars
sed -i -e "s/${NAGIOS_ADMIN_PASSWD}/NAGIOS_ADMIN_PASSWD/" devars.tfvars

# Reverse the content of the userdata scripts to their original state
sed -i -e "s|$(cat puppet)|#PUPPET_CONFIG|" {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage,userdata-jump}.sh
sed -i -e "s/$(echo $PUPPET_WAIT_1)/#PUPPET_WAIT_1/" {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage}.sh
sed -i -e "s|$(cat ansible)|#ANSIBLE_CONFIG|" {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage}.sh
sed -i -e "s/$(echo $PUPPET_WAIT_2)/#PUPPET_WAIT_2/" {userdata,userdata-jenkins,userdata-db,userdata-lb,userdata-storage}.sh

# Were are not keeping the files
rm {puppet,ansible}
