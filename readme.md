# NGINX ACME Module Auto-Builder

[![Build and Release NGINX ACME Module](https://github.com/hzbd/nginx-acme-build/actions/workflows/release-acme-module.yml/badge.svg)](https://github.com/hzbd/nginx-acme-build/actions/workflows/release-acme-module.yml)

This repository uses GitHub Actions to automatically build the official [Nginx-ACME](https://github.com/nginx/nginx-acme) dynamic module, **optimized specifically for the latest Debian Stable release**.

The workflow runs on every `push` to the `master` branch or when triggered manually. It automatically detects the latest stable version of NGINX, compiles a module that is fully compatible with Debian's official NGINX package, and publishes it to a GitHub Release with versioned naming and a SHA256 checksum.

## ✨ Features

-   **Automatic Version Tracking**: Detects and builds against the latest stable NGINX version.
-   **Manual Version Override**: Supports manually triggering the workflow for any specific NGINX version.
-   **High Compatibility**: Uses the exact same build parameters as the official **Debian package** to ensure binary compatibility.
-   **Automated Releases**: Automatically creates a new GitHub Release upon successful compilation.
-   **Versioned Naming**: Artifacts are clearly named with the NGINX version (e.g., `ngx1.28.0_http_acme_module.so`).
-   **Security Checksums**: Each release includes a SHA256 checksum for file integrity verification.

## 🚀 Usage

### Step 1: Download the Module

1.  Go to this repository's **[Releases Page](https://github.com/hzbd/nginx-acme-build/releases)**.
2.  Find the release corresponding to your NGINX version (e.g., `nginx-1.28.0`).
3.  Download the `ngx<VERSION>_http_acme_module.so` file from the "Assets" section.
4.  Place the downloaded `.so` file into your server's NGINX modules directory.
    -   On Debian/Ubuntu, this path is typically `/usr/lib/nginx/modules/`.
    -   You can confirm the exact `modules-path` on your system by running `nginx -V`.

### Step 2: Configure NGINX

The following configuration example is for `nginx-acme` module **v0.1.1 and later**, which uses the new `acme_issuer` and `acme_certificate` directives.

```nginx
# /etc/nginx/nginx.conf

# Load the dynamic module at the top level
# Replace <VERSION> with the actual version number, e.g., ngx1.28.0_http_acme_module.so
load_module modules/ngx<VERSION>_http_acme_module.so;

http {
    # NGINX needs a DNS resolver to connect to the Let's Encrypt API
    resolver 8.8.8.8;

    # Define a certificate issuer named "letsencrypt"
    acme_issuer letsencrypt {
        uri         https://acme-v02.api.letsencrypt.org/directory;
        contact     mailto:your-email@example.com;
        state_path  /var/lib/nginx/acme/letsencrypt; # Ensure the nginx user has write permissions to this directory
        accept_terms_of_service;
    }

    # Define a shared memory zone for ACME state
    acme_shared_zone zone=acme_shared:1M;

    # Your HTTPS website server
    server {
        listen 443 ssl http2;
        server_name your-domain.com www.your-domain.com;

        # Tell the module to issue a certificate for this server block
        # using the "letsencrypt" issuer defined above.
        acme_certificate letsencrypt;

        # Use the variables automatically provided by the module
        ssl_certificate         $acme_certificate;
        ssl_certificate_key     $acme_certificate_key;

        # Required for NGINX 1.27.4+ to optimize certificate caching
        # ssl_certificate_cache   max=2;    # required ngx 1.27.4+

        # ... other SSL settings ...

        location / {
            # ... your website configuration ...
        }
    }

    # A server to handle all HTTP traffic and redirect it to HTTPS.
    # The ACME HTTP-01 challenge is handled automatically without extra config.
    server {
        listen 80 default_server;
        server_name _;

        location / {
            return 301 https://$host$request_uri;
        }
    }
}
