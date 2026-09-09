# Prerequisites (All 3 Members)

- [Main project README](../README.md)
- [VM 1: Web Server manual](Member1.md) | [automation script](../script/vm1.sh)All machines operate on a static IP configuration within the same subnet.

| Device | Role | OS | Static IP |
| --- | --- | --- | --- |
| **HotSpot** | Gateway / Router | N/A | `10.69.116.1` |
| **Server 1** | Web Server (Apache) | Ubuntu Server | `10.69.116.11` |
| **Server 2** | DNS Server (BIND9) + Nginx Reverse Proxy | Ubuntu Server | `10.69.116.12` |
| **Server 3** | File Server (Samba) | Ubuntu Server | `10.69.116.13` |
| **Client** | Demo / Testing Node | Windows/Linux | `10.69.116.50` |
- [VM 2: DNS Server manual](Member2.md) | [automation script](../script/vm2.sh)
- [VM 3: File Server manual](Member3.md) | [automation script](../script/vm3.sh)
- [Script directory index](../script/README.md)

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





