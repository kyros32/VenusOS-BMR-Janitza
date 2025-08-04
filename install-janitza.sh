#!/bin/sh
set -euo pipefail

DATA_DIR="/data/janitza"
RAW_URL="https://raw.githubusercontent.com/kyros32/VenusOS-Janitza/main/JanitzaUmg96RM.py"
TARGET_DIR="/opt/victronenergy/dbus-modbus-client"
CLIENT_PY="$TARGET_DIR/dbus-modbus-client.py"
DRIVER_DST="$TARGET_DIR/JanitzaUmg96RM.py"
LOCAL_DRIVER="$DATA_DIR/JanitzaUmg96RM.py"

# 1) Ensure data directory exists
mkdir -p "$DATA_DIR"

# 2) Wait for network to be up
echo "Waiting for network connectivity…"
until connmanctl state | grep -q 'State = ready'; do
    sleep 15
done
echo "Network is up, proceeding with download."

# 3) Always fetch latest
echo "Downloading driver to $LOCAL_DRIVER…"
if command -v wget >/dev/null; then
    wget -q -O "$LOCAL_DRIVER" "$RAW_URL"
elif command -v curl >/dev/null; then
    curl -fsSL "$RAW_URL" -o "$LOCAL_DRIVER"
else
    echo "Error: neither wget nor curl is available." >&2
    exit 1
fi

# 4) Verify target dir
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: target directory $TARGET_DIR not found." >&2
    exit 1
fi

# 5) Install driver
echo "Installing driver to $TARGET_DIR…"
cp -f "$LOCAL_DRIVER" "$DRIVER_DST"
chmod 644 "$DRIVER_DST"

# 6) Cleanup old bytecode
echo "Cleaning up old bytecode…"
find "$TARGET_DIR" -type d -name "__pycache__" -exec rm -rf {} +

# 7) Inject import if missing
IMPORT_LINE="import JanitzaUmg96RM"
if ! grep -qF "$IMPORT_LINE" "$CLIENT_PY"; then
    # Insert after the last existing import
    sed -i "/^import /a $IMPORT_LINE" "$CLIENT_PY"
    echo "Injected import into dbus-modbus-client.py"
fi

# 8) Restart service (using sv/svc if available)
if command -v sv >/dev/null 2>&1; then
    sv restart dbus-modbus-client
elif command -v svc >/dev/null 2>&1; then
    svc -t /service/dbus-modbus-client
elif command -v systemctl >/dev/null 2>&1; then
    systemctl restart dbus-modbus-client.service || echo "Warning: systemctl restart failed" >&2
elif command -v supervisorctl >/dev/null 2>&1; then
    supervisorctl restart dbus-modbus-client || echo "Warning: supervisorctl restart failed" >&2
else
    echo "Warning: no known service manager found; please restart dbus-modbus-client manually." >&2
fi

echo "Janitza driver update complete."
