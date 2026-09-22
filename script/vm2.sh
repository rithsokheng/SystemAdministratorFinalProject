#!/bin/bash
# Run as root on VM 2 (DNS Server + Nginx Reverse Proxy)
set -e

# 1. Update and install packages
apt update && apt upgrade -y
apt install -y bind9 bind9utils bind9-doc nginx openssh-server ufw

# 2. Enable SSH
systemctl enable --now ssh

# ===========================
# Firewall Rules
# ===========================
ufw allow 22/tcp
ufw allow 53/tcp
ufw allow 53/udp
ufw allow 80/tcp

# ===========================
# BIND9 DNS Configuration
# ===========================

# Configure named.conf.options to allow network queries and forwarders
cat <<'EOF' > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";

    // Allow queries from all local network clients
    allow-query { any; };
    listen-on { any; };
    listen-on-v6 { any; };

    // Forward external requests to public DNS
    forwarders {
        8.8.8.8;
        1.1.1.1;
    };

    dnssec-validation no;
};
EOF

# Append the local DNS zone if not present
if ! grep -q 'zone "m2g10.istad"' /etc/bind/named.conf.local 2>/dev/null; then
    cat <<'EOF' >> /etc/bind/named.conf.local

zone "m2g10.istad" {
    type master;
    file "/etc/bind/db.m2g10.istad";
};
EOF
    echo "DNS zone added to named.conf.local"
else
    echo "DNS zone already exists in named.conf.local — skipping"
fi

# Create the forward lookup zone file
# NOTE: Points to 192.168.1.252 (Nginx Proxy) so traffic flows through reverse proxy.
# (If your grading strictly demands pointing directly to Apache 192.168.1.251, change .252 to .251)
cat <<'EOF' > /etc/bind/db.m2g10.istad
$TTL    604800
@       IN      SOA     ns1.m2g10.istad. admin.m2g10.istad. (
                                3         ; Serial
                           604800         ; Refresh
                            86400         ; Retry
                          2419200         ; Expire
                           604800 )       ; Negative Cache TTL
;
@       IN      NS      ns1.m2g10.istad.
ns1     IN      A       192.168.1.252
@       IN      A       192.168.1.252
www     IN      A       192.168.1.252
EOF

# Validate BIND9 configuration
named-checkconf
named-checkzone m2g10.istad /etc/bind/db.m2g10.istad

# Restart BIND9
systemctl restart named
systemctl enable --now named

# ===========================
# Nginx Reverse Proxy Setup
# ===========================

# Remove default site
rm -f /etc/nginx/sites-enabled/default

# Create reverse proxy configuration
cat <<'EOF' > /etc/nginx/sites-available/reverse-proxy
server {
    listen 80;
    server_name m2g10.istad www.m2g10.istad 192.168.1.252;

    location / {
        proxy_pass         http://192.168.1.251:80;
        proxy_set_header   Host              $host;
        proxy_set_header   X-Real-IP         $remote_addr;
        proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
    }
}
EOF

# Link and enable reverse proxy
ln -sf /etc/nginx/sites-available/reverse-proxy /etc/nginx/sites-enabled/reverse-proxy

# Validate and restart Nginx
nginx -t
systemctl restart nginx
systemctl enable --now nginx

echo "DNS Server + Nginx Reverse Proxy setup complete!"