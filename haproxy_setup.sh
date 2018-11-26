# Add the repository
sudo add-apt-repository ppa:vbernat/haproxy-1.8 -y
# Update sources list
sudo apt update
# Install haproxy
sudo apt install -y haproxy

# Edit the /etc/haproxy/haproxy.cfg file to add new configuration

cat << EOL | sudo tee /etc/haproxy/haproxy.cfg
global
    maxconn 100

defaults
    log global
    mode tcp
    retries 2
    timeout client 30m
    timeout connect 4s
    timeout server 30m
    timeout check 5s
    
listen stats
    mode http
    bind *:7000
    stats enable
    stats uri /

listen postgres
    bind *:5000
    option httpchk
    http-check expect status 200
    default-server inter 3s fall 3 rise 2 on-marked-down shutdown-sessions
    server postgresql_10.0.0.2_5432 10.0.0.2:5432 maxconn 100 check port 5432
    server postgresql_10.0.0.3_5432 10.0.0.3:5432 maxconn 100 check port 5432
    server postgresql_10.0.0.4_5432 10.0.0.4:5432 maxconn 100 check port 5432
EOL

# Restart haproxy
sudo systemctl restart haproxy