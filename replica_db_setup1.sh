#!/usr/bin/env bash

# add the Postgres 9.6 repository to the source.list.d directory
echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' | sudo tee -a /etc/apt/sources.list.d/postgresql.list

# Dowload PostgresSQL key to the system
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
  
# Update the system repository
sudo apt-get update
  
# Install the PostgresSQL 9.6 package
sudo apt-get install -y postgresql-9.6

# Edit the postgres configuration file
# echo "listen_addresses = '*'" | sudo tee -a /etc/postgresql/9.6/main/postgresql.conf
sudo sed -i -e "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/9.6/main/postgresql.conf

# Edit the /etc/postgresql/9.6/main/pg_hba.conf inorder to allow the IP that can connect to it
# find the 127.0.0.1/32 and change it to the IP range that can connect to the database
sudo sed -i -e "s/127.0.0.1\/32/10.0.0.0\/24/" /etc/postgresql/9.6/main/pg_hba.conf

# Restart the postgres server
sudo systemctl restart postgresql
  
# Stop the postgres server
sudo systemctl stop postgresql

sudo chown postgres.postgres /var/lib/postgresql/9.6/main/

# remove the data in the slave database
sudo su -c "rm -rf /var/lib/postgresql/9.6/main/*; exit"

# Create a .pgpass file in the ~ home directory
## With the following data 
##  *:*:*:replication:password

# change the permissions of the .pgpass file 
## chmod 0600 ~/.pgpass

# Manual step
## login with postgres user and take a backup of the master
# sudo su postgres -c "pg_basebackup -h 10.0.0.2 -D /var/lib/postgresql/9.6/main -P -U replication --xlog-method=stream;"

