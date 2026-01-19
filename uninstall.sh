#!/bin/bash
set -e

echo "Uninstalling ballast..."

# Stop and disable service
if systemctl is-active --quiet ballast 2>/dev/null; then
    sudo systemctl stop ballast
fi
if systemctl is-enabled --quiet ballast 2>/dev/null; then
    sudo systemctl disable ballast
fi

# Remove files
sudo rm -f /usr/local/bin/ballast
sudo rm -f /etc/systemd/system/ballast.service
sudo systemctl daemon-reload 2>/dev/null || true

# Ask about config and data
read -p "Remove config (/etc/ballast.conf)? [y/N]: " rm_config
if [[ "${rm_config,,}" == "y" ]]; then
    sudo rm -f /etc/ballast.conf
fi

read -p "Remove ballast file (/var/lib/ballast/)? [y/N]: " rm_data
if [[ "${rm_data,,}" == "y" ]]; then
    sudo rm -rf /var/lib/ballast
fi

echo "Done. Ballast uninstalled."
