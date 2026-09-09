
# System Administration - Final Project

This repository contains the architecture, configuration requirements, and expected outcomes for our virtualized server environment for our team members.

## Network Topology

All servers and the client machine are connected via a shared Wireless HotSpot.

```text
+----------+     +-----------------+
| INTERNET |-----| WIRELESS HOTSPOT|
+----------+     +--------+--------+
                          |
        +-----------------+-----------------+-----------------+
        |                 |                 |                 |
  +-----+-----+     +-----+-----+     +-----+-----+     +-----+-----+
  | VMWare    |     | VMWare    |     | CLIENT    |     | FILE      |
  | WEB       |     | DNS       |     |           |     | SERVER    |
  | SERVER    |     | SERVER    |     |           |     |           |
  +-----------+     +-----------+     +-----------+     +-----------+

```

### IP Addressing Scheme

All machines operate on a static IP configuration within the same subnet.

| Device | Role | OS | Static IP |
| --- | --- | --- | --- |
| **HotSpot** | Gateway / Router | N/A | `10.69.116.1` |
| **Server 1** | Web Server (Apache) | Ubuntu Server | `10.69.116.11` |
| **Server 2** | DNS Server (BIND9) + Nginx Reverse Proxy | Ubuntu Server | `10.69.116.12` |
| **Server 3** | File Server (Samba) | Ubuntu Server | `10.69.116.13` |
| **Client** | Demo / Testing Node | Windows/Linux | `10.69.116.50` |

---

##  Configuration Instructions

Use the dedicated documentation and setup scripts instead of repeating the complete configuration here:

1. Follow the shared [global prerequisites](manual/README.md), including the Netplan static IP setup.
2. Use the [Member 1 manual](manual/Member1.md) for the Web Server or run [`script/vm1.sh`](script/vm1.sh).
3. Use the [Member 2 manual](manual/Member2.md) for the DNS Server or run [`script/vm2.sh`](script/vm2.sh).
4. Use the [Member 3 manual](manual/Member3.md) for the File Server or run [`script/vm3.sh`](script/vm3.sh).

The setup scripts are intended to be run as `root` on their corresponding virtual machine. Review each script before execution and complete the manual prerequisite steps first.

---

##  Expected Outcomes

Once the configuration is complete, the following results can be verified from the **Client** computer:

1. **Remote Access:** Successfully connect remotely to all three Servers via SSH (using PuTTY or terminal).
2. **Web Hosting & DNS:** Successfully load the custom website using **both** the server's IP Address (`10.69.116.11`) and the configured Domain Name (`www.groupproject.local`).
3. **Reverse Proxy:** Successfully load the same website by browsing to the DNS Server's IP (`10.69.116.12`), confirming Nginx is proxying traffic to the Apache backend.
4. **File Sharing:** Successfully read, write, upload, and download files from the File Server via the network directory.


