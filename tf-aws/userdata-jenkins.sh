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
if [ $JENKINS_SERVER_HOSTNAME ]; then
  hostnamectl set-hostname $JENKINS_SERVER_HOSTNAME;
fi;
