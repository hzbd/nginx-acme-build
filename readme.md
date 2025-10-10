# Portable NGINX with ACME Module - Auto-Builder

[中文](./readme_cn.md)

[![Build and Release NGINX ACME Module](https://github.com/hzbd/nginx-acme-build/actions/workflows/release-with-acme-module.yml/badge.svg)](https://github.com/hzbd/nginx-acme-build/actions/workflows/release-with-acme-module.yml)

This repository uses GitHub Actions to automatically build a **fully portable, self-contained NGINX package**. It comes bundled with the official [Nginx-ACME](https://github.com/nginx/nginx-acme) module and is compiled on the latest Debian Stable release to ensure optimal compatibility.

The core design principle is **zero system dependencies**. By compiling NGINX with **relative paths**, this workflow produces a package that does not rely on standard system directories (like `/etc/nginx` or `/var/log/nginx`). You can run it on any compatible Linux system without installing NGINX first.

## ✨ Core Features

-   **Fully Portable**: Zero dependencies! All paths (logs, PID, temp files) are compiled to be relative, keeping everything inside a single directory.
-   **Automatic Version Tracking**: Automatically detects and builds against the latest stable NGINX version.
-   **Manual Build Triggers**: Supports manually triggering the workflow for any specific NGINX version.
-   **Ready-to-Use**: Includes a clean `nginx.conf` and a `vhost` example to get you started in minutes.
-   **Automated Releases**: Automatically creates a new GitHub Release with a `.tar.gz` archive upon a successful build.
-   **Security Checksums**: Each release includes a SHA256 checksum for verifying file integrity.

## 📁 Package Directory Structure

After downloading and unpacking the archive, you will have a clean, ready-to-run NGINX environment:

```
nginx-acme-package/
├── acme/           # For ACME account keys, certificates, and challenges
├── logs/           # Stores access.log and error.log
├── modules/        # Contains the ngx_http_acme_module.so dynamic module
├── run/            # Stores the nginx.pid file
├── sbin/           # Contains the nginx executable binary
├── temp/           # For proxy, FastCGI, and other temporary files
├── vhost.d/        # [IMPORTANT] Place your website server block configs here
├── mime.types      # Default MIME type definitions
├── nginx.conf      # Main configuration file
└── README.txt      # A quick start guide included in the package
```

## 🚀 Usage Guide

### Step 1: Download and Unpack

1.  Go to this repository's **[Releases Page](https://github.com/hzbd/nginx-acme-build/releases)**.
2.  Find the release corresponding to your desired NGINX version (e.g., `nginx-1.28.0`).
3.  Download the `.tar.gz` archive from the "Assets" section.
4.  Unpack the archive on your server:
    ```bash
    tar -xzf nginx-1.28.0-acme-debian-stable.tar.gz
    cd nginx-acme-package
    ```
    **Note**: If you have an existing NGINX instance installed via `apt`, stop and disable it (`sudo systemctl stop nginx`) to free up ports 80 and 443.

### Step 2: Configure NGINX

1.  **Enable the ACME Module**:
    Open the main configuration file `nginx.conf` and uncomment the `load_module` directive at the top of the file:
    ```nginx
    # load_module modules/ngx_http_acme_module.so;
    ```
    Remove the leading `#` to enable it.

2.  **Configure Your Website**:
    The `vhost.d` directory is where all your site configurations live.
    a. First, copy the example file to create your own config:
    ```bash
    cp vhost.d/default.conf.example vhost.d/your_domain.conf
    ```
    b. Edit `vhost.d/your_domain.conf`, replacing placeholders like `your_domain.com` and `mail@your_domain.com` with your actual information.
    c. As instructed in the example config, create the directory needed for the ACME challenge:
    ```bash
    mkdir -p acme/challenge-root
    ```

### Step 3: Start and Manage NGINX

**Important**: All commands must be run from within the `nginx-acme-package` directory.

1.  **Test Configuration**: Before starting, always check your configuration for syntax errors.
    ```bash
    # The -p $(pwd) flag tells NGINX to use the current directory as its prefix path.
    # The -c nginx.conf flag specifies the relative path to the config file.
    ./sbin/nginx -p $(pwd) -c nginx.conf -t
    ```
    If you see `syntax is ok` and `test is successful`, you are ready to start.

2.  **Start NGINX**:
    ```bash
    ./sbin/nginx -p $(pwd) -c nginx.conf
    ```

3.  **Common Management Commands**:
    -   **Reload Configuration**: `./sbin/nginx -p $(pwd) -s reload`
    -   **Graceful Shutdown**: `./sbin/nginx -p $(pwd) -s quit`
    -   **Fast Shutdown**: `./sbin/nginx -p $(pwd) -s stop`

## ⚠️ Portability Disclaimer

This package is designed as a standalone, "green" application. It **cannot and should not** be used to replace the `/usr/sbin/nginx` binary installed by system package managers like `apt`.

Attempting to do so will lead to critical issues, including path conflicts, module incompatibility, and a broken system package state. Please use this package as a complete, self-contained service.
