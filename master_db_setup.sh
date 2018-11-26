#!/usr/bin/env bash

set -o errexit
# add the Postgres 9.6 repository to the source.list.d directory
echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' | sudo tee -a /etc/apt/sources.list.d/postgresql.list
# Dowload PostgresSQL key to the system
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
# Update the system repository
sudo apt-get update
# Install the PostgresSQL 9.6 package
sudo apt-get install -y postgresql-9.6

# Edit the postgres configuration file
echo "listen_addresses = '*'" | sudo tee -a /etc/postgresql/9.6/main/postgresql.conf

## Manual step
# Edit the /etc/postgresql/9.6/main/pg_hba.conf inorder to allow the IP that can connect to it
# find the 127.0.0.1/32 and change it to the IP range that can connect to the database
## sudo vi /etc/postgresql/9.6/main/pg_hba.conf 

# Restart the postgres server
sudo systemctl restart postgresql

# Create a replication Role so that the slave can use it to connect to the master
sudo su postgres 
psql -c "CREATE ROLE replication WITH REPLICATION PASSWORD 'password' LOGIN;"
exit

# Stop the postgres service, else replication will not work
sudo systemctl stop postgresql


cat << EOF | sudo tee -a vi /etc/postgresql/9.6/main/postgresql.conf
wal_level = hot_standby
max_wal_senders = 5
wal_keep_segment = 32
archive_mode = on
archive_command = 'cp %p /var/lib/postgresql/9.6/archive/%f'
EOF

# make archive directory
sudo mkdir /var/lib/postgresql/9.6/archive

# change the owner and group od the archive to postgres
sudo chown postgres.postgres /var/lib/postgresql/9.6/archive/

# Add the replication user to the pg_hba.conf
cat << EOF | sudo tee -a /etc/postgresql/9.6/main/pg_hba.conf
host replication replication 35.207.138.100/32 md5
host replication replication 35.207.128.195/32 md5
EOF

# Restart the postgres 
sudo systemctl start postgresql
sudo systemctl restart postgresql

# Check whether a nubered folder is created in the archive directory
ls /var/lib/postgresql/9.6/archive/


# To check if streaming replication is working
sudo su postgres
psql 


# To create a database on master
sudo su postgres
psql -c 'CREATE DATABASE test1'
\l
