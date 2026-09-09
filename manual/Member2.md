# Member 2: DNS Server + Nginx Reverse Proxy (IP: 10.69.116.12)

**Task:** Install BIND9, Nginx, and SSH. Configure DNS to map the domain name to Member 1's Web Server, and set up Nginx as a reverse proxy that forwards HTTP traffic to the Apache Web Server on VM1.

---

## Part 1 — DNS Server (BIND9)

1. **Update and install services:**
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y bind9 bind9utils bind9-doc nginx openssh-server
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
ns1     IN      A       10.69.116.12
@       IN      A       10.69.116.11
www     IN      A       10.69.116.11
```


Save and exit.
4. **Restart DNS:**
```bash
sudo systemctl restart named
sudo systemctl enable --now named
```

---

## Part 2 — Nginx Reverse Proxy

Nginx will listen on port 80 on this server and forward all HTTP requests to the Apache Web Server on VM1 (`10.69.116.11`).

5. **Remove the default Nginx site:**
```bash
sudo rm -f /etc/nginx/sites-enabled/default
```


6. **Create the reverse proxy configuration:**
```bash
sudo nano /etc/nginx/sites-available/reverse-proxy
```


Paste the following:
```nginx
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
```


Save and exit.

7. **Enable the site and restart Nginx:**
```bash
sudo ln -sf /etc/nginx/sites-available/reverse-proxy /etc/nginx/sites-enabled/reverse-proxy
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable --now nginx
```

---

## Verification

From the **Client** machine, you can test the reverse proxy by browsing to `http://10.69.116.12`. The page served should be the same website hosted on VM1 (`10.69.116.11`), confirming that Nginx is correctly proxying traffic to the Apache backend.

---