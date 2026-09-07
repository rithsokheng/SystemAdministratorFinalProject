# Prerequisites (All 3 Members)

Before configuring the services, all members must manually set up their Static IPs.

1. Run `ip a` to find the network interface name (e.g., `ens33` or `enp0s3`).
```bash
ip a
```
2. Run `sudo nano /etc/netplan/00-installer-config.yaml` (filename may vary).
```bash
sudo nano /etc/netplan/00-installer-config.yaml
```
3. Update it to match the assigned IP (Member 1 gets `.11`, Member 2 gets `.12`, Member 3 gets `.13`), save (`Ctrl+O`, `Enter`), and exit (`Ctrl+X`).
4. Apply it: `sudo netplan apply`
```bash
sudo netplan apply
```

---





