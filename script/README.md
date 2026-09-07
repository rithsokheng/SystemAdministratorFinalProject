# Setting Static IPs (Netplan)
1. Find your network interface name (usually enp0s3 or ens33 on VMware) by typing: 
```bash
ip a
```
2. Edit the netplan file: 
```bash
sudo nano /etc/netplan/00-installer-config.yaml
``` 
3. Modify it to look like this (example for the Web Server):
```bash
network:
  ethernets:
    ens33:                  # Replace with your actual interface name
      dhcp4: false
      addresses:
        - 192.168.10.11/24  # Change to .12 for DNS, .13 for File Server
      routes:
        - to: default
          via: 192.168.10.1 # Your HotSpot Gateway IP
      nameservers:
        addresses:
          - 192.168.10.12   # Point ALL servers to your DNS Server
          - 8.8.8.8
  version: 2
```
4. Apply the changes: 
```bash
sudo netplan apply
```