# Member 2: DNS Server Configuration (IP: 192.168.10.12)

**Task:** Install BIND9, configure SSH, and map the domain name to Member 1's Web Server.

1. **Update and install services:**
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y bind9 bind9utils bind9-doc openssh-server
sudo systemctl enable --now ssh
```


2. **Configure the local DNS zone:**
Open the named config file:
```bash
sudo nano /etc/bind/named.conf.local
```


Add this to the bottom:
```text
zone "groupproject.local" {
    type master;
    file "/etc/bind/db.groupproject.local";
};
```


Save and exit.
3. **Create the zone record file:**
Open a new file:
```bash
sudo nano /etc/bind/db.groupproject.local
```


Paste the following configuration (pointing to `.11`):
```text
$TTL    604800
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
```


Save and exit.
4. **Restart DNS:**
```bash
sudo systemctl restart bind9
sudo systemctl enable --now bind9
```
---