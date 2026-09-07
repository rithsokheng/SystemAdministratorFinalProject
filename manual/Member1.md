# Member 1: Web Server Configuration (IP: 192.168.10.11)

**Task:** Install Apache, configure SSH, and set up a custom website to meet the "default website not acceptable" requirement.

1. **Update and install services:**
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y apache2 openssh-server
```


2. **Start and enable services:**
```bash
sudo systemctl enable --now ssh
sudo systemctl enable --now apache2
```


3. **Replace the default website:**
Open the index file:
```bash
sudo nano /var/www/html/index.html
```


Delete everything inside and paste this simple custom HTML:
```html
<!DOCTYPE html>
<html>
<head><title>SysAdmin Team Project</title></head>
<body>
    <h1>Welcome to Our Web Server!</h1>
    <p>Successfully hosted by our 3-member team.</p>
</body>
</html>
```


Save (`Ctrl+O`, `Enter`) and exit (`Ctrl+X`).

---