#! /bin/bash


# Update server hostname
DB_SERVER_HOSTNAME=${DB_SERVER_HOSTNAME}
DB_SERVER_IP=${DB_SERVER_IP}
DB_NAME=${DB_NAME}
DB_USER_NAME=${DB_USER_NAME}
DB_USER_PASS=${DB_USER_PASS}
DB_PORT=${DB_PORT}
VPC_CIDR_BLOCK=${VPC_CIDR_BLOCK}

if [ DB_SERVER_HOSTNAME ]; then
  hostnamectl set-hostname $DB_SERVER_HOSTNAME
fi;

# Install postgresql server
yum install postgresql-server postgresql-contrib -y;
postgresql-setup initdb;
sed -i "/# \x22local\x22 is for Unix domain socket connections only/a local    $DB_NAME        $DB_USER_NAME           md5" /var/lib/pgsql/data/pg_hba.conf;
sed -i "/# IPv4 local connections:/a host    $DB_NAME        $DB_USER_NAME         $VPC_CIDR_BLOCK           md5" /var/lib/pgsql/data/pg_hba.conf;
sed -i "/#listen_addresses = 'localhost'/a listen_addresses = \x27*\x27" /var/lib/pgsql/data/postgresql.conf;
systemctl enable --now postgresql;

cat << END >> setup.sql
CREATE USER "$DB_USER_NAME" with PASSWORD '$DB_USER_PASS';
CREATE DATABASE $DB_NAME;
GRANT ALL ON DATABASE $DB_NAME to $DB_USER_NAME;
END

cat setup.sql;

sudo -i -u postgres psql < setup.sql;

# psql -U todoapp -d todoapp -h localhost -p 5432 manaully connect to db

sed -i "/# \x22local\x22 is for Unix domain socket connections only/a local    todoapp        todoapp           md5" /var/lib/pgsql/data/pg_hba.conf;
sed -i "/# IPv4 local connections:/a host    todoapp        todoapp         10.0.0.0/16           md5" /var/lib/pgsql/data/pg_hba.conf;