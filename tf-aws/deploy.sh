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

sed -i -e "s/DB_NAME/${DB_NAME}/" devars.tfvars
sed -i -e "s/DB_USERNAME/${DB_USERNAME}/" devars.tfvars
sed -i -e "s/DB_PASSWD/${DB_PASSWD}/" devars.tfvars
# cat devars.tfvars

# execute terraform apply
terraform apply --auto-approve -var-file devars.tfvars

sleep 3

# Reverse the change after terraform successful deploy
sed -i -e "s/${DB_NAME}/DB_NAME/" devars.tfvars
sed -i -e "s/${DB_USERNAME}/DB_USERNAME/" devars.tfvars
sed -i -e "s/${DB_PASSWD}/DB_PASSWD/" devars.tfvars
# cat devars.tfvars