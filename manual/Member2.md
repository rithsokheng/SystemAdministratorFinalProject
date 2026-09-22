# Member 2: DNS Server + Nginx Reverse Proxy (IP: 192.168.1.252)

**Task:** Install BIND9, Nginx, SSH, and UFW. Configure authoritative DNS resolution for `m2g10.istad` pointing to the Nginx reverse proxy (or Web Server), and configure Nginx as a reverse proxy that forwards HTTP traffic to the Apache Web Server on VM1 (`192.168.1.251:80`).

---

## Part 1 — Packages & Firewall

1. **Update and install services:**
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y bind9 bind9utils bind9-doc nginx openssh-server ufw
sudo systemctl enable --now ssh
```

2. **Configure firewall rules:**
```bash
sudo ufw allow 22/tcp
sudo ufw allow 53/tcp
sudo ufw allow 53/udp
sudo ufw allow 80/tcp
```

---

## Part 2 — DNS Server Configuration (BIND9)

3. **Configure DNS options and forwarders:**
Open the options configuration file:
```bash
sudo nano /etc/bind/named.conf.options
```

Replace its contents or configure the `options` block:
```text
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
```

4. **Configure the local DNS zone:**
Open the local zones configuration file:
```bash
sudo nano /etc/bind/named.conf.local
```

Add the master zone definition for `m2g10.istad` to the bottom:
```text
zone "m2g10.istad" {
    type master;
    file "/etc/bind/db.m2g10.istad";
};
```

5. **Create the forward lookup zone file:**
Open the new zone file:
```bash
sudo nano /etc/bind/db.m2g10.istad
```

Paste the following configuration (points to `192.168.1.252` so traffic routes through the Nginx reverse proxy):
```text
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
```
> **Note:** If grading strictly requires the DNS A records to resolve directly to Apache (`192.168.1.251`), change `.252` to `.251`.

6. **Validate BIND9 configuration:**
```bash
sudo named-checkconf
sudo named-checkzone m2g10.istad /etc/bind/db.m2g10.istad
```

7. **Restart and enable BIND9:**
```bash
sudo systemctl restart named
sudo systemctl enable --now named
```

---

## Part 3 — Nginx Reverse Proxy Setup

Nginx listens on port 80 of this server (`192.168.1.252`) and forwards all incoming HTTP requests to the Apache Web Server on VM1 (`192.168.1.251:80`).

8. **Remove the default Nginx site:**
```bash
sudo rm -f /etc/nginx/sites-enabled/default
```

9. **Create the reverse proxy configuration:**
```bash
sudo nano /etc/nginx/sites-available/reverse-proxy
```

Paste the following configuration:
```nginx
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
```

10. **Enable the site, test syntax, and restart Nginx:**
```bash
sudo ln -sf /etc/nginx/sites-available/reverse-proxy /etc/nginx/sites-enabled/reverse-proxy
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable --now nginx
```

---

## Part 4 — Verification

From the **Client** machine (`192.168.1.50` with DNS configured to `192.168.1.252`):

1. **Verify DNS Name Resolution:**
```bash
nslookup www.m2g10.istad 192.168.1.252
nslookup m2g10.istad 192.168.1.252
```
It should resolve to `192.168.1.252`.

2. **Verify Reverse Proxy & Web Access:**
- Open browser to `http://192.168.1.252`
- Open browser to `http://www.m2g10.istad` or `http://m2g10.istad`

Both should load the custom web application hosted on VM1 (`192.168.1.251`), confirming that BIND9 resolves the domain and Nginx forwards traffic properly.

---