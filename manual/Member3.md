# Member 3: File Server Configuration (IP: 192.168.10.13)

**Task:** Install Samba, configure SSH, and create a public folder for easy upload/download during the live demo.

1. **Update and install services:**
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y samba openssh-server
sudo systemctl enable --now ssh
```


2. **Create the shared directory:**
```bash
sudo mkdir -p /srv/samba/team_share
sudo chmod 2777 /srv/samba/team_share
sudo chown nobody:nogroup /srv/samba/team_share
```


3. **Configure Samba:**
Open the Samba configuration file:
```bash
sudo nano /etc/samba/smb.conf
```


Scroll all the way to the bottom and paste this:
```text
[TeamProject_Share]
   path = /srv/samba/team_share
   browsable = yes
   read only = no
   guest ok = yes
   create mask = 0777
   directory mask = 0777
   force user = nobody
```


Save and exit.
4. **Restart Samba:**
```bash
sudo systemctl restart smbd
sudo systemctl enable --now smbd
```

