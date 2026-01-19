#!/bin/bash
set -e

REPO="cole-robertson/ballast"
INSTALL_DIR="/usr/local/bin"
CONFIG_FILE="/etc/ballast.conf"
DATA_DIR="/var/lib/ballast"
SYSTEMD_DIR="/etc/systemd/system"

echo "Installing ballast..."

# Check for required tools
for cmd in curl df stat; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: Required command '$cmd' not found" >&2
        exit 1
    fi
done

TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

# Download files
echo "Downloading..."
curl -fsSL "https://raw.githubusercontent.com/$REPO/master/ballast" -o "$TMP/ballast"
curl -fsSL "https://raw.githubusercontent.com/$REPO/master/ballast.service" -o "$TMP/ballast.service"
curl -fsSL "https://raw.githubusercontent.com/$REPO/master/config.example.conf" -o "$TMP/config.example.conf"

# Install
sudo install -m 755 "$TMP/ballast" "$INSTALL_DIR/ballast"
sudo mkdir -p "$DATA_DIR"
sudo cp "$TMP/ballast.service" "$SYSTEMD_DIR/"

if [[ ! -f "$CONFIG_FILE" ]]; then
    sudo cp "$TMP/config.example.conf" "$CONFIG_FILE"
    echo "Installed example config to $CONFIG_FILE"
fi

# Reload systemd
if command -v systemctl &>/dev/null; then
    sudo systemctl daemon-reload
fi

echo ""
echo "Installation complete!"
echo ""
echo "Next steps:"
echo "  sudo ballast init                    # Create ballast file"
echo "  sudo systemctl enable --now ballast  # Start daemon"
echo ""
echo "Configure alerts: sudo nano /etc/ballast.conf"
