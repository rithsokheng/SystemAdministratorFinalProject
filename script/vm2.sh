#!/bin/bash
# run as root on VM 2 (DNS Server)

# Update and install BIND9 and SSH
apt update && apt upgrade -y
apt install -y bind9 bind9utils bind9-doc openssh-server

# Enable SSH
systemctl enable --now ssh

# Configure the local DNS zone
cat <<EOF >> /etc/bind/named.conf.local

zone "groupproject.local" {
    type master;
    file "/etc/bind/db.groupproject.local";
};
EOF

# Create the forward lookup zone file mapping to the Web Server (192.168.10.11)
cat <<EOF > /etc/bind/db.groupproject.local
\$TTL    604800
@       IN      SOA     ns1.groupproject.local. admin.groupproject.local. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns1.groupproject.local.
ns1     IN      A       192.168.10.12
@       IN      A       192.168.10.11
www     IN      A       192.168.10.11
EOF

# Restart and enable BIND9
systemctl restart bind9
systemctl enable --now bind9

echo "DNS Server setup complete!"