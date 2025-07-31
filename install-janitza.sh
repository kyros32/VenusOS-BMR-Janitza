#!/bin/sh
set -euo pipefail

DATA_DIR="/data/janitza"
RAW_URL="https://raw.githubusercontent.com/kyros32/VenusOS-Janitza/main/JanitzaUmg96RM.py"
TARGET_DIR="/opt/victronenergy/dbus-modbus-client"
CLIENT_PY="$TARGET_DIR/dbus-modbus-client.py"
DRIVER_DST="$TARGET_DIR/JanitzaUmg96RM.py"
LOCAL_DRIVER="$DATA_DIR/JanitzaUmg96RM.py"

mkdir -p "$DATA_DIR"

# Always fetch latest
echo "Downloading driver to $LOCAL_DRIVER…"
if command -v wget >/dev/null; then
    wget -q -O "$LOCAL_DRIVER" "$RAW_URL"
elif command -v curl >/dev/null; then
    curl -fsSL "$RAW_URL" -o "$LOCAL_DRIVER"
else
    echo "Error: neither wget nor curl is available." >&2
    exit 1
fi

# Verify target dir
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: target directory $TARGET_DIR not found." >&2
    exit 1
fi

echo "Installing driver to $TARGET_DIR…"
cp -f "$LOCAL_DRIVER" "$DRIVER_DST"
chmod 644 "$DRIVER_DST"

echo "Cleaning up old bytecode…"
find "$TARGET_DIR" -type d -name "__pycache__" -exec rm -rf {} +

IMPORT_LINE="import JanitzaUmg96RM"
if ! grep -qF "$IMPORT_LINE" "$CLIENT_PY"; then
    # Insert after the last existing import
    sed -i "/^import /a $IMPORT_LINE" "$CLIENT_PY"
    echo "Injected import into dbus-modbus-client.py"
fi

# Restart service
if command -v systemctl >/dev/null 2>&1; then
    systemctl restart dbus-modbus-client.service || echo "Warning: failed to restart via systemctl" >&2
elif command -v supervisorctl >/dev/null 2>&1; then
    supervisorctl restart dbus-modbus-client || echo "Warning: failed to restart via supervisorctl" >&2
fi

echo "Janitza driver update complete."
