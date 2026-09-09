#!/bin/bash
# run as root on VM 2 (DNS Server + Nginx Reverse Proxy)

# Update and install BIND9, Nginx, and SSH
apt update && apt upgrade -y
apt install -y bind9 bind9utils bind9-doc nginx openssh-server

# Enable SSH
systemctl enable --now ssh

# ===========================
# BIND9 DNS Configuration
# ===========================

# Configure the local DNS zone (only add if not already present)
if ! grep -q 'zone "groupproject.local"' /etc/bind/named.conf.local 2>/dev/null; then
    cat <<'EOF' > /etc/bind/named.conf.local

zone "groupproject.local" {
    type master;
    file "/etc/bind/db.groupproject.local";
};
EOF
    echo "DNS zone added to named.conf.local"
else
    echo "DNS zone already exists in named.conf.local — skipping"
fi

# Create the forward lookup zone file mapping to the Web Server (10.69.116.11)
cat <<'EOF' > /etc/bind/db.groupproject.local
\$TTL    604800
@       IN      SOA     ns1.groupproject.local. admin.groupproject.local. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns1.groupproject.local.
ns1     IN      A       10.69.116.12
@       IN      A       10.69.116.11
www     IN      A       10.69.116.11
EOF

# Restart and enable BIND9 (named.service is the real unit on Ubuntu 25.04+)
systemctl restart named
systemctl enable --now named

# ===========================
# Nginx Reverse Proxy Setup
# ===========================

# Remove the default Nginx site so it does not conflict
rm -f /etc/nginx/sites-enabled/default

# Create a reverse proxy virtual host that forwards to the Apache Web Server
cat <<'EOF' > /etc/nginx/sites-available/reverse-proxy
server {
    listen 80;
    server_name groupproject.local www.groupproject.local;

    location / {
        proxy_pass         http://10.69.116.11;
        proxy_set_header   Host              $host;
        proxy_set_header   X-Real-IP         $remote_addr;
        proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
    }
}
EOF

# Enable the reverse proxy site
ln -sf /etc/nginx/sites-available/reverse-proxy /etc/nginx/sites-enabled/reverse-proxy

# Test the Nginx configuration and start the service
nginx -t
systemctl restart nginx
systemctl enable --now nginx

echo "DNS Server + Nginx Reverse Proxy setup complete!"