#!/bin/sh
set -e

# Configuration
DATA_DIR="/data/janitza"
RAW_URL="https://raw.githubusercontent.com/patrick-dmxc/VenusOS-Janitza/main/JanitzaUmg96RM.py"
TARGET_DIR="/opt/victronenergy/dbus-modbus-client"
CLIENT_PY="$TARGET_DIR/dbus-modbus-client.py"
DRIVER_DST="$TARGET_DIR/JanitzaUmg96RM.py"
LOCAL_DRIVER="$DATA_DIR/JanitzaUmg96RM.py"

# 1) Ensure data directory exists
mkdir -p "$DATA_DIR"

# 2) Download fresh copy of the driver only if missing
if [ ! -f "$LOCAL_DRIVER" ]; then
    echo "Fetching JanitzaUmg96RM.py…"
    wget -q -O "$LOCAL_DRIVER" "$RAW_URL"
else
    echo "Driver already exists in $DATA_DIR, skipping download."
fi

# 3) Copy it into Victron’s modbus-client folder
echo "Installing to $TARGET_DIR…"
cp -f "$LOCAL_DRIVER" "$DRIVER_DST"

# 4) Remove stale bytecode
if [ -d "$TARGET_DIR/__pycache__" ]; then
    echo "Cleaning __pycache__…"
    rm -rf "$TARGET_DIR/__pycache__"
fi

# 5) Inject import if missing
IMPORT_LINE="import JanitzaUmg96RM"
if ! grep -qF "$IMPORT_LINE" "$CLIENT_PY"; then
    echo "Adding import to dbus-modbus-client.py…"
    sed -i "/import carlo_gavazzi/a $IMPORT_LINE" "$CLIENT_PY"
fi

# 6) (Optional) restart the service so changes take effect immediately
if command -v supervisorctl >/dev/null 2>&1; then
    echo "Restarting dbus-modbus-client…"
    supervisorctl restart dbus-modbus-client || true
fi

echo "Janitza driver update complete."
