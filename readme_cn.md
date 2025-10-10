# NGINX with ACME Module Auto-Builder

[English](./readme.md)

[![Build and Release NGINX Package](https://github.com/hzbd/nginx-acme-build/actions/workflows/release-with-acme-module.yml/badge.svg)](https://github.com/hzbd/nginx-acme-build/actions/workflows/release-with-acme-module.yml)

本项目使用 GitHub Actions 自动构建一个**完全可移植、自包含的 NGINX 软件包**。该软件包内置了官方的 [Nginx-ACME](https://github.com/nginx/nginx-acme) 模块，并在最新的 Debian Stable 环境下编译，以确保最佳的兼容性。

这个工作流的核心设计理念是**“零系统依赖”**。它通过在编译时指定**相对路径**，创建了一个不依赖于系统目录结构（如 `/etc/nginx` 或 `/var/log/nginx`）的 NGINX 环境。您无需在服务器上安装 NGINX，下载解压后即可直接运行。

## ✨ 核心特性

-   **完全可移植**: 零依赖！所有路径（日志、PID、临时文件）在编译时都设为相对路径，所有文件都包含在一个目录中。
-   **自动版本跟踪**: 自动检测并基于最新的 NGINX 稳定版进行构建。
-   **手动版本指定**: 支持手动触发工作流，以构建任何特定的 NGINX 版本。
-   **开箱即用**: 包含清晰的 `nginx.conf` 和 `vhost` 示例，大大简化了配置过程。
-   **自动化发布**: 编译成功后，自动创建包含 `.tar.gz` 压缩包的 GitHub Release。
-   **安全与校验**: 每个版本都提供 SHA256 校验和，确保文件完整性。

## 📁 软件包目录结构

下载并解压后，您会得到一个结构清晰、立即可用的 NGINX 环境：

```
nginx-acme-package/
├── acme/           # 用于存放 ACME 账户密钥、证书和挑战文件
├── logs/           # 存放 access.log 和 error.log
├── modules/        # 存放 ngx_http_acme_module.so 动态模块
├── run/            # 存放 nginx.pid 文件
├── sbin/           # 存放 nginx 二进制可执行文件
├── temp/           # 存放代理、FastCGI 等临时文件
├── vhost/        # 【重要】存放您的网站配置文件
├── mime.types      # MIME 类型定义文件
├── nginx.conf      # 主配置文件
└── README.txt      # 包含在此处的快速入门指南
```

## 🚀 使用指南

### 第一步：下载并解压

1.  访问本仓库的 **[Releases 页面](https://github.com/hzbd/nginx-acme-build/releases)**。
2.  找到与您需要的 NGINX 版本对应的 Release (例如 `nginx-1.28.0`)。
3.  从 "Assets" 区域下载 `.tar.gz` 压缩包。
4.  在您的服务器上解压文件：
    ```bash
    tar -xzf nginx-1.28.0-acme-debian-stable.tar.gz
    cd nginx-acme-package
    ```
    **注意**: 如果您的系统上已通过 `apt` 安装了 NGINX，请先停止并禁用它 (`sudo systemctl stop nginx`)，以释放 80 和 443 端口。

### 第二步：配置 NGINX

1.  **启用 ACME 模块**:
    打开主配置文件 `nginx.conf`，找到文件顶部的这行注释：
    ```nginx
    # load_module modules/ngx_http_acme_module.so;
    ```
    去掉 `#` 号以启用它。

2.  **配置您的网站**:
    `vhost` 目录是存放您所有网站配置的地方。
    a. 首先，复制并重命名示例文件：
    ```bash
    cp vhost/default.conf.example vhost/your_domain.conf
    ```
    b. 编辑 `vhost/your_domain.conf`，将其中的 `your_domain.com`、`mail@your_domain.com` 等占位符替换为您自己的信息。
    c. 根据示例文件中的提示，创建 ACME 挑战所需的目录：
    ```bash
    mkdir -p acme/challenge-root
    ```

### 第三步：启动并管理 NGINX

**重要**: 所有命令都应在 `nginx-acme-package` 目录下执行。

1.  **测试配置**: 在启动前，务必检查配置文件语法是否正确。
    ```bash
    # -p $(pwd) 参数告诉 NGINX 使用当前目录作为其工作根目录
    # -c nginx.conf 指定了配置文件的相对路径
    ./sbin/nginx -p $(pwd) -c nginx.conf -t
    ```
    如果看到 `syntax is ok` 和 `test is successful`，说明配置无误。

2.  **启动 NGINX**:
    ```bash
    ./sbin/nginx -p $(pwd) -c nginx.conf
    ```

3.  **常用管理命令**:
    -   **重新加载配置**: `./sbin/nginx -p $(pwd) -s reload`
    -   **平滑停止服务**: `./sbin/nginx -p $(pwd) -s quit`
    -   **立即停止服务**: `./sbin/nginx -p $(pwd) -s stop`

## ⚠️ 重要提示：关于可移植性

本软件包被设计为一个独立的“绿色软件”，**不能**用于替换由 Debian/Ubuntu 官方 `apt` 包安装的 `/usr/sbin/nginx` 文件。

直接替换会导致路径冲突、模块不兼容和系统包管理器损坏等严重问题。请将此软件包作为一个完整的、自包含的服务来运行。

## 🔧 构建您自己的版本

如果您需要一个特定（甚至是旧的，但至少是1.25.0以后的版本）NGINX 版本，或者想要自定义编译参数，您可以轻松地 fork 本仓库并自行构建。

1.  **Fork 本仓库**: 点击页面右上角的 'Fork' 按钮。
2.  **启用 Actions**: 在您 fork 后的仓库页面，进入 'Actions' 标签页，并按提示启用 GitHub Actions。
3.  **手动触发构建**:
    *   在左侧边栏点击 'Build and Release NGINX with ACME Module Package' 工作流。
    *   点击右侧的 'Run workflow' 下拉按钮。
    *   在 'Optional: Specify an NGINX version to build' 输入框中，填入您想要构建的 NGINX 版本号（例如 `1.26.1`）。
    *   点击绿色的 'Run workflow' 按钮开始构建。
4.  **获取产物**: 构建完成后，一个新的 Release 将会自动创建在您自己仓库的 'Releases' 页面，您可以从中下载您的定制软件包。
