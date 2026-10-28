# GoAdmio

**A comprehensive, free Linux web hosting control panel** — a powerful and easy-to-use cPanel alternative for managing servers, websites, and hosting accounts.

GoAdmio gives you root-level server administration, security hardening, and per-user website, email, and database management — all from one modern panel. It runs on AlmaLinux, Rocky Linux, Debian, and Ubuntu, and is designed to be fast, stable, and simple to use.

**Quick links:** [Website](https://goadmio.com) · [Live Demo](https://demo.goadmio.com/go) · [Features](https://goadmio.com/feature.php) · [Commands](https://goadmio.com/command.php) · [API](https://goadmio.com/api.php) · [Support](https://goadmio.com/support.php)

---

## Screenshots

| Admin Panel | User Panel |
|---|---|
| ![GoAdmio Admin Panel](screenshots/admin.png) | ![GoAdmio User Panel](screenshots/user.png) |

---

## Table of Contents

- [Features](#features)
  - [1. Server Management](#1-server-management)
  - [2. User-Level Features](#2-user-level-features)
  - [3. Additional Features](#3-additional-features)
  - [4. Integrations](#4-integrations)
- [Screenshots](#screenshots)
- [Installation](#installation)
- [Requirements](#requirements)
- [Support](#support)

---

## Features

GoAdmio is a comprehensive web hosting control panel that provides a wide range of features for managing servers, websites, and hosting accounts. Below is a categorized list of its key features:

### 1. Server Management

#### Administration & Configuration

- **Root Access Control** – Full server management via root.
- **Service Configuration** – Manage Apache, PHP, DNS, FTP, etc.
- **Server Status & Monitoring** – Real-time resource usage (CPU, RAM, disk, etc.).
- **MultiPHP Manager** – Configure PHP versions per domain.
- **Apache Configuration** – Customize Apache settings.
- **Backup & Restoration** – Full server backups (local/remote).
- **Package Manager** – Install software via RPM or YUM.
- **Firewall (CSF)** – ConfigServer Security & Firewall integration.
- **IP Blocker** – Block IPs to prevent abuse.
- **SSL/TLS Management** – Install Let's Encrypt or custom SSLs.
- **ModSecurity Manager** – Configure web application firewall rules.

#### Security & Hardening

- **Two-Factor Authentication (2FA)** – Secure GoAdmio logins.
- **SMTP Restrictions** – Prevent email abuse.
- **PHP-FPM & suExec** – Isolate PHP processes for security.
- **SSH Access Management** – Control shell access.
- **Security Advisor** – Scan for vulnerabilities.
- **Hotlink Protection** – Prevent image/content theft.

#### Account & Resource Management

- **Create/Modify Accounts** – Manage hosting accounts.
- **Resource Limits (CPU, RAM, I/O)** – Allocate server resources.
- **Suspension/Termination** – Disable abusive accounts.
- **Quota Management** – Disk space limits.
- **Bandwidth Monitoring** – Track data usage.

#### Networking & DNS

- **DNS Cluster** – Sync DNS across servers.
- **Nameserver Management** – Configure custom nameservers.
- **IPv6 Support** – Assign IPv6 addresses.
- **Zone Editor** – Manage DNS records (A, MX, CNAME, etc.).

### 2. User-Level Features

#### Website & Domain Management

- **Domain Management** – Addon domains, subdomains, aliases.
- **File Manager** – Browser-based file editing/upload.
- **FTP Accounts** – Create/manage FTP users.
- **Backup Wizard** – Download/restore backups.
- **Snapshot** – Point-in-time copy of your server's entire state (files, databases, and mail).
- **Site Publisher** – Quick HTML website setup.
- **GoAdmio Apps Installer** – 1-click installs (WordPress, Joomla, etc.).
- **Git Version Control** – Manage repositories.

#### Email Management

- **Email Accounts** – Create `@yourdomain` emails.
- **Webmail** (Roundcube, SnappyMail, SquirrelMail) – Access emails online.
- **Spam Filters (SpamAssassin)** – Reduce spam.
- **Auto-Responders** – Set vacation/out-of-office emails.
- **Forwarders & Aliases** – Redirect emails.
- **DKIM/SPF/DMARC** – Email authentication.

#### Databases

- **MySQL/MariaDB Management** – Create/modify databases.
- **Remote MySQL** – Allow external DB connections.
- **phpMyAdmin** – Manage databases via GUI.
- **Adminer** – Manage databases via GUI.
- **PostgreSQL Management** – Create/modify databases.
- **SQLite Management** – Create/modify databases.

#### Security

- **SSL/TLS Certificates** – Install free (Let's Encrypt) or paid SSLs.
- **Password Protected Directories** – Restrict access.
- **IP Deny Manager** – Block specific IPs.
- **ModSecurity Rules** – Enable/disable WAF rules.

#### Metrics & Analytics

- **AWStats/Webalizer** – Website traffic statistics.
- **Raw Access/Bandwidth Logs** – Download logs.
- **CPU/Disk Usage** – Monitor resource consumption.

#### Advanced Features

- **Cron Jobs** – Schedule automated tasks.
- **API & UAPI** – Automate tasks via GoAdmio's API.
- **Ruby on Rails Support** – Some hosts support this.
- **Node.js Manager** – Run Node.js apps.

### 3. Additional Features

- **NGINX Web Server (Optional)** – Faster alternative to Apache.
- **CloudLinux (Optional)** – Isolate accounts for stability.
- **Imunify360 (Optional)** – Advanced security suite.
- **GoAdmio Themes** (Light Mode, Dark Mode) – Customize UI.

### 4. Integrations

- **Cloudflare** – CDN/DNS integration.
- **AutoSSL** – Free SSL certificate provisioning.
- **API & CLI Access** – Automate tasks via scripts.

---

## Installation

> ⚠️ **Requirements:** Linux server with **root access** on a clean OS install. See <a href="#requirements">Requirements</a> for supported distributions.

**Full install** (run as root via SSH):

```bash
curl -s -o latest -L https://download.goadmio.com && chmod +x latest && ./latest
```

<a id="requirements"></a>
## Requirements

### Operating System

**Primary Recommended OS:** AlmaLinux

| Distribution | Supported Versions (64-bit) |
|---|---|
| **AlmaLinux** | 9.x, 10.x |
| **Rocky Linux** | 9.x, 10.x |
| **Debian** | 11, 12, 13 |
| **Ubuntu** | 22, 23, 24, 25, 26 |

### Minimum System Requirements

- **Architecture:** x86_64 (64-bit)
- **RAM:** 2 GB minimum (4 GB+ recommended for production)
- **Disk:** 20 GB minimum free space
- **Access:** Root SSH access
- **Network:** Public IP with ports 80 and 443 open
- **Clean OS install** — not compatible with servers already running cPanel, Plesk, or another control panel
