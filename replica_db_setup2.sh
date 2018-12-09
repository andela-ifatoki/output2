#!/bin/bash


# tell slave to coninously pull data from the master
# sudo vi /etc/postgresql/9.6/main/postgresql.conf # set hot_standby = on

sudo sed -i -e "s/#hot_standby = off/hot_standby = on/" /etc/postgresql/9.6/main/postgresql.conf

# create recovery configuration file
cat << 'EOF' | sudo tee -a /var/lib/postgresql/9.6/main/recovery.conf >> /dev/null
standby_mode = 'on'
primary_conninfo = 'host=10.0.0.2 port=5432 user=replication password=password'
trigger_file = '/var/lib/postgresql/9.6/trigger'
restore_command = 'cp /var/lib/postgresql/9.6/archive/%f "%p"'
EOF

sudo systemctl start postgresql
sudo systemctl restart postgresql