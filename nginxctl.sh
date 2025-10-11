#!/bin/bash

# ==============================================================================
# NGINX Portable Instance Control Script
#
# Description: A simple script to manage a self-contained NGINX instance.
# Author:      Generated for user
# ==============================================================================

# --- Configuration ---
# Set the absolute path to your NGINX installation directory.
# IMPORTANT: Do not use trailing slashes.
NGINX_HOME="/data/nginx_acme"


# --- Script Body (Do not edit below this line) ---
set -e # Exit immediately if a command exits with a non-zero status.

# Check if the NGINX home directory exists
if [ ! -d "$NGINX_HOME" ]; then
    echo "Error: NGINX home directory not found at '$NGINX_HOME'"
    exit 1
fi

# Change to the NGINX directory
cd "$NGINX_HOME" || exit 1

# Define the NGINX executable path
NGINX_BIN="./sbin/nginx"
NGINX_CONF="nginx.conf"

# Check if the NGINX binary exists and is executable
if [ ! -x "$NGINX_BIN" ]; then
    echo "Error: NGINX binary not found or not executable at '$NGINX_BIN'"
    exit 1
fi

# Function to display usage information
usage() {
    echo "Usage: $0 {start|stop|quit|reload|test|status}"
    echo "Commands:"
    echo "  start   - Start NGINX (tests config first)"
    echo "  stop    - Stop NGINX immediately (fast shutdown)"
    echo "  quit    - Stop NGINX gracefully"
    echo "  reload  - Reload configuration (tests config first)"
    echo "  test    - Test NGINX configuration"
    echo "  status  - Show NGINX process status"
    exit 1
}

# Ensure an argument is provided
if [ -z "$1" ]; then
    usage
fi

# Main control logic
case "$1" in
    start)
        echo "Testing NGINX configuration..."
        if "$NGINX_BIN" -p "$(pwd)" -t -c "$NGINX_CONF"; then
            echo "Configuration is OK. Starting NGINX..."
            "$NGINX_BIN" -p "$(pwd)" -c "$NGINX_CONF"
            echo "NGINX started."
        else
            echo "Error: Configuration test failed. NGINX not started."
            exit 1
        fi
        ;;
    stop)
        echo "Stopping NGINX (fast shutdown)..."
        "$NGINX_BIN" -p "$(pwd)" -s stop
        echo "NGINX stopped."
        ;;
    quit)
        echo "Stopping NGINX gracefully..."
        "$NGINX_BIN" -p "$(pwd)" -s quit
        echo "NGINX stopped gracefully."
        ;;
    reload)
        echo "Testing NGINX configuration..."
        if "$NGINX_BIN" -p "$(pwd)" -t -c "$NGINX_CONF"; then
            echo "Configuration is OK. Reloading NGINX..."
            "$NGINX_BIN" -p "$(pwd)" -s reload
            echo "NGINX reloaded."
        else
            echo "Error: Configuration test failed. NGINX not reloaded."
            exit 1
        fi
        ;;
    test)
        echo "Testing NGINX configuration..."
        "$NGINX_BIN" -p "$(pwd)" -t -c "$NGINX_CONF"
        ;;
    status)
        echo "Checking NGINX process status..."
        # The `|| true` prevents the script from exiting if grep finds nothing
        ps -ef | grep nginx | grep -v grep || true
        ;;
    *)
        usage
        ;;
esac

exit 0
