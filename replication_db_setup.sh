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
  
# Stop the postgres server
sudo systemctl stop postgresql

sudo chown postgres.postgres /var/lib/postgresql/9.6/main/

# remove the data in the slave database
sudo rm -rf /var/lib/postgresql/9.6/main/*

# login with postgres user
sudo su postgres

# take a backup of the master
pg_basebackup -h 35.207.140.100 -D /var/lib/postgresql/9.6/main -P -U replication --xlog-method=stream

# tell slave to coninously pull data from the master
sudo vi /etc/postgresql/9.6/main/postgresql.conf # set hot_standby = on

sudo vi /var/lib/postgresql/9.6/main/recovery.conf
# standby_mode = 'on'
# primary_conninfo = 'host=52.90.248.191 port=5432 user=replication password=password'
# trigger_file = '/var/lib/postgresql/9.6/trigger'
# restore_command = 'cp /var/lib/postgresql/9.6/archive/%f "%p"'
  
