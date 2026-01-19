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

# Config and data removal (use flags or prompt if interactive)
REMOVE_CONFIG=false
REMOVE_DATA=false

# Check for flags
for arg in "$@"; do
    case "$arg" in
        --all) REMOVE_CONFIG=true; REMOVE_DATA=true ;;
        --keep-config) REMOVE_CONFIG=false ;;
        --keep-data) REMOVE_DATA=false ;;
    esac
done

# If interactive (not piped), ask
if [[ -t 0 && "$#" -eq 0 ]]; then
    read -p "Remove config (/etc/ballast.conf)? [y/N]: " answer </dev/tty
    [[ "${answer,,}" == "y" ]] && REMOVE_CONFIG=true

    read -p "Remove ballast file (/var/lib/ballast/)? [y/N]: " answer </dev/tty
    [[ "${answer,,}" == "y" ]] && REMOVE_DATA=true
fi

if $REMOVE_CONFIG; then
    sudo rm -f /etc/ballast.conf
    echo "Removed config"
fi

if $REMOVE_DATA; then
    sudo rm -rf /var/lib/ballast
    echo "Removed ballast data"
fi

echo ""
echo "Ballast uninstalled."
[[ -f /etc/ballast.conf ]] && echo "Config kept at /etc/ballast.conf"
[[ -d /var/lib/ballast ]] && echo "Data kept at /var/lib/ballast/"
