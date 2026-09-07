# System Administrator - Final Project

This document outlines the architecture, configuration requirements, and expected outcomes for our virtualized server environment for our team members.

## Network Topology

```
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

---

## Configuration Instructions

Based on the project requirements, please install and configure the servers to operate as follows:

1. **Network Configuration:** Set **Static IP Addresses** for all Client computers and Servers. All devices must be in the same network range (you are free to define the specific IP range yourself).
2. **Remote Access (SSH):** Enable the **SSH service** on all three servers so the Client computer can access them remotely using the PuTTY application.
3. **Web Server Setup:** Install the Web Server on VMWare on the *first* computer. It must host the group's custom website (**Note:** The default web server landing page is not acceptable).
4. **DNS Server Setup:** Install the DNS Server on VMWare on the *second* computer. Configure it to map a DNS domain name to the Web Server (located on the first computer). This will allow the Client computer to access the group's website via the custom domain name.
5. **File Server Setup:** Install and configure a File Server using **SAMBA**. This must allow the Client computer to upload and download files to and from the server.
6. **Client Configuration:** Install the **PuTTY** (Alternative: SSH via terminal) application on the Client computer to establish remote connections to the three servers. This Client machine will be used to present and demonstrate the entire project.
7. **Network Connectivity:** Ensure the Client computer and all three Servers are connected to each other using the shared Wireless HotSpot.

---

## Expected Outcomes

Once the configuration is complete, you must be able to verify the following results from the **Client** computer:

+ Successfully connect remotely to all three Servers via SSH.
+ Successfully load the custom website using **both** the server's IP Address and the configured Domain Name.

