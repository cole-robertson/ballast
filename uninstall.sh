#!/bin/bash
set -e

echo "Uninstalling ballast..."

# Stop and disable service
systemctl is-active --quiet ballast 2>/dev/null && sudo systemctl stop ballast || true
systemctl is-enabled --quiet ballast 2>/dev/null && sudo systemctl disable ballast || true

# Remove binary and service
sudo rm -f /usr/local/bin/ballast
sudo rm -f /etc/systemd/system/ballast.service
sudo systemctl daemon-reload 2>/dev/null || true

echo ""
echo "Ballast uninstalled."
echo ""
echo "Config and data were kept. To remove manually:"
echo "  sudo rm /etc/ballast.conf"
echo "  sudo rm -rf /var/lib/ballast"
