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
nginx_acme/
├── acme/           # For ACME account keys, certificates, and challenges
├── logs/           # Stores access.log and error.log
├── modules/        # Contains the ngx_http_acme_module.so dynamic module
├── run/            # Stores the nginx.pid file
├── sbin/           # Contains the nginx executable binary
├── temp/           # For proxy, FastCGI, and other temporary files
├── vhost/        # [IMPORTANT] Place your website server block configs here
├── mime.types      # Default MIME type definitions
├── nginx.conf      # Main configuration file
└── README.txt      # A quick start guide included in the package
```

## 🚀 Usage Guide

The downloaded package is designed to be managed entirely through the included `nginxctl.sh` script.

### Step 1: Download and Unpack

1.  Go to this repository's **[Releases Page](https://github.com/hzbd/nginx-acme-build/releases)**.
2.  Download the archive that matches your server's Debian version (e.g., `...-debian12.tar.gz`).
3.  Unpack the archive on your server:
    ```bash
    tar -xzf <archive-name>.tar.gz
    cd nginx_acme
    ```

### Step 2: Configure Your Website

1.  **Review `nginx.conf`**: The main configuration file is already included. You may need to enable the `load_module` directive inside it.
2.  **Set up your site**: Copy the vhost template to create your website's configuration file.
    ```bash
    cp vhost/default.conf.example vhost/your_site.conf
    ```
3.  **Edit the config**: Open `vhost/your_site.conf` and update it with your domain, paths, and other settings.

### Step 3: Manage NGINX with `nginxctl.sh`

This script is your primary tool for controlling the NGINX service.

1.  **Make the script executable (only needed once)**:
    ```bash
    chmod +x nginxctl.sh
    ```

2.  **Use the script's commands**:
    -   **Test configuration:** The script will automatically test the configuration before starting or reloading to prevent errors.
        ```bash
        ./nginxctl.sh test
        ```
    -   **Start NGINX:**
        ```bash
        ./nginxctl.sh start
        ```
    -   **Check status:**
        ```bash
        ./nginxctl.sh status
        ```
    -   **Reload configuration (after changing config files):**
        ```bash
        ./nginxctl.sh reload
        ```
    -   **Stop gracefully (waits for connections to finish):**
        ```bash
        ./nginxctl.sh quit
        ```
    -   **Stop immediately:**
        ```bash
        ./nginxctl.sh stop
        ```

## ⚠️ Portability Disclaimer

This package is designed as a standalone, "green" application. It **cannot and should not** be used to replace the `/usr/sbin/nginx` binary installed by system package managers like `apt`.

Attempting to do so will lead to critical issues, including path conflicts, module incompatibility, and a broken system package state. Please use this package as a complete, self-contained service.

## 🔧 Build Your Own Version

If you require a package for a specific (or even an older, nginx 1.25.0 or later.) version of NGINX, or if you wish to customize the compile-time parameters, you can easily fork this repository and build it yourself.

1.  **Fork this Repository**: Click the 'Fork' button in the top-right corner of this page.
2.  **Enable Actions**: In your forked repository, navigate to the 'Actions' tab and click the button to enable workflows.
3.  **Manually Trigger the Workflow**:
    *   In the left sidebar, click on the 'Build and Release NGINX with ACME Module Package' workflow.
    *   Click the 'Run workflow' dropdown button that appears on the right.
    *   In the 'Optional: Specify an NGINX version to build' input field, enter the exact NGINX version you want to build (e.g., `1.26.1`).
    *   Click the green 'Run workflow' button to start the build.
4.  **Download Your Artifact**: Once the workflow is complete, a new release will be automatically published on your fork's 'Releases' page. You can download your custom-built package from there.
