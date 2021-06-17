#! /bin/bash

. ./envfile
sed -i -e "s/${AWS_PROFILE}/AWS_PROFILE/" devars.tfvars
sed -i -e "s/${AWS_REGION}/AWS_REGION/" devars.tfvars
sed -i -e "s/${INSTANCE_TYPE}/INSTANCE_TYPE/" devars.tfvars
sed -i -e "s/${EC2_KEYPAIR}/EC2_KEYPAIR/" devars.tfvars

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
