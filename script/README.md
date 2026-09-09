# Setting Static IPs (Netplan)

- [Main project README](../README.md)
- [VM 1: Web Server script](vm1.sh) | [manual](../manual/Member1.md)
- [VM 2: DNS Server script](vm2.sh) | [manual](../manual/Member2.md)
- [VM 3: File Server script](vm3.sh) | [manual](../manual/Member3.md)
- [Manual directory index](../manual/README.md)

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
        - 10.69.116.11/24  # Change to .12 for DNS, .13 for File Server
      routes:
        - to: default
          via: 10.69.116.1 # Your HotSpot Gateway IP
      nameservers:
        addresses:
          - 10.69.116.12   # Point ALL servers to your DNS Server
          - 8.8.8.8
  version: 2
```
4. Apply the changes: 
```bash
sudo netplan apply
```