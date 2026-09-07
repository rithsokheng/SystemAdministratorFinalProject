#!/bin/bash
# run as root on VM 3 (File Server)

# Update and install Samba and SSH
apt update && apt upgrade -y
apt install -y samba openssh-server

# Enable SSH
systemctl enable --now ssh

# Create the shared directory and set open permissions for demo purposes
mkdir -p /srv/samba/team_share
chmod 2777 /srv/samba/team_share
chown nobody:nogroup /srv/samba/team_share

# Append the share configuration to the Samba config file
cat <<EOF >> /etc/samba/smb.conf

[TeamProject_Share]
   path = /srv/samba/team_share
   browsable = yes
   read only = no
   guest ok = yes
   create mask = 0777
   directory mask = 0777
   force user = nobody
EOF

# Restart and enable Samba services
systemctl restart smbd
systemctl enable --now smbd

echo "File Server setup complete!"