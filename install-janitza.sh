#!/bin/sh
set -euo pipefail

DATA_DIR="/data/janitza"
RAW_URL="https://raw.githubusercontent.com/kyros32/VenusOS-Janitza/main/JanitzaUmg96RM.py"
TARGET_DIR="/opt/victronenergy/dbus-modbus-client"
CLIENT_PY="$TARGET_DIR/dbus-modbus-client.py"
DRIVER_DST="$TARGET_DIR/JanitzaUmg96RM.py"
LOCAL_DRIVER="$DATA_DIR/JanitzaUmg96RM.py"

# URL of your custom rc.local
RC_LOCAL_URL="https://raw.githubusercontent.com/kyros32/VenusOS-Janitza/main/rc.local"
RC_LOCAL="/data/rc.local"
TMP_RCL="/data/rc.local.tmp"

# 1) Ensure data directory exists
mkdir -p "$DATA_DIR"

# 2) Wait for network to be up
echo "Waiting for network connectivity…"
until connmanctl state | grep -q 'State = ready'; do
    sleep 15
done
echo "Network is up, proceeding…"

# 3) Always fetch latest driver
echo "Downloading driver to $LOCAL_DRIVER…"
if command -v wget >/dev/null; then
    wget -q -O "$LOCAL_DRIVER" "$RAW_URL"
elif command -v curl >/dev/null; then
    curl -fsSL "$RAW_URL" -o "$LOCAL_DRIVER"
else
    echo "Error: neither wget nor curl is available." >&2
    exit 1
fi

# 4) Download & merge rc.local (but don’t abort on failure)
echo "Updating /data/rc.local from $RC_LOCAL_URL…"
# temp‐disable “exit on error” for this block
set +e
if command -v wget >/dev/null; then
    wget -q -O "$TMP_RCL" "$RC_LOCAL_URL"
elif command -v curl >/dev/null; then
    curl -fsSL "$RC_LOCAL_URL" -o "$TMP_RCL"
else
    echo "Warning: no downloader for rc.local; skipping." >&2
    TMP_RCL=""
fi
set -e

# merge/create only if we got a non-empty file
if [ -n "${TMP_RCL}" ] && [ -s "$TMP_RCL" ]; then
    if [ -f "$RC_LOCAL" ]; then
        echo "Appending to existing $RC_LOCAL…"
        cat "$TMP_RCL" >>"$RC_LOCAL"
        rm -f "$TMP_RCL"
    else
        echo "Creating new $RC_LOCAL…"
        mv "$TMP_RCL" "$RC_LOCAL"
    fi
    chmod +x "$RC_LOCAL"
    echo "→ /data/rc.local is now executable."
else
    [ -f "$TMP_RCL" ] && rm -f "$TMP_RCL"
    echo "Skipped rc.local update."
fi

# 5) Verify target dir
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: target directory $TARGET_DIR not found." >&2
    exit 1
fi

# 6) Install driver
echo "Installing driver to $TARGET_DIR…"
cp -f "$LOCAL_DRIVER" "$DRIVER_DST"
chmod 644 "$DRIVER_DST"

# 7) Cleanup old bytecode
echo "Cleaning up old bytecode…"
find "$TARGET_DIR" -type d -name "__pycache__" -exec rm -rf {} +

# 8) Inject import if missing
IMPORT_LINE="import JanitzaUmg96RM"
if ! grep -qF "$IMPORT_LINE" "$CLIENT_PY"; then
    sed -i "/^import /a $IMPORT_LINE" "$CLIENT_PY"
    echo "Injected import into dbus-modbus-client.py"
fi

# 9) Restart service (sv/svc or fallback)
if command -v sv >/dev/null 2>&1; then
    sv restart dbus-modbus-client
elif command -v svc >/dev/null 2>&1; then
    svc -t /service/dbus-modbus-client
elif command -v systemctl >/dev/null 2>&1; then
    systemctl restart dbus-modbus-client.service || echo "Warning: systemctl restart failed" >&2
elif command -v supervisorctl >/dev/null 2>&1; then
    supervisorctl restart dbus-modbus-client || echo "Warning: supervisorctl restart failed" >&2
else
    echo "Warning: no known service manager; please restart dbus-modbus-client manually." >&2
fi

echo "Janitza driver update complete."

# 10) Ensure this installer script itself is executable
chmod +x "$0"
