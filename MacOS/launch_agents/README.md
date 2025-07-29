# macOS LaunchAgents – Privilege Escalation via User-Space Persistence

## Description

macOS uses `LaunchAgents` to start background tasks when a user logs in. These tasks are defined using `.plist` (XML format) files and stored in:

- `~/Library/LaunchAgents/` → Loaded automatically when the user logs in (non-root)
- `/Library/LaunchAgents/` → System-wide user-space agents (may run elevated)
- `/Library/LaunchDaemons/` → System-wide daemons (run as root)

If an attacker can write to any of these directories — especially the system-level ones — they can create a `LaunchAgent` or `LaunchDaemon` that executes arbitrary code at login or system boot.

Even when limited to user space, `LaunchAgents` are commonly abused for stealthy persistence and lateral movement.

## PrivEsc Potential

While `~/Library/LaunchAgents/` alone does **not** grant elevated privileges, the technique becomes a **privilege escalation vector** if:

- The attacker can write to `/Library/LaunchAgents/` or `/Library/LaunchDaemons/`
- A privileged `LaunchDaemon` loads a user-controlled binary
- The agent indirectly triggers sensitive actions (e.g. misconfigured binaries, credential theft)

> 🧠 **MITRE ATT&CK mapping**:  
> T1543.001 – [Create or Modify System Process: Launch Agent](https://attack.mitre.org/techniques/T1543/001)

## Requirements

- Write access to `~/Library/LaunchAgents/` (default for user accounts)
- A script or binary to execute (e.g. reverse shell, privilege escalator)
- Optional: ability to escalate via `/Library/Launch*` misconfiguration

## Exploitation Steps

1. Craft a malicious `.plist` file that points to a payload
2. Place it in `~/Library/LaunchAgents/`
3. Load it immediately using `launchctl load`, or wait for user login
4. The system automatically runs the payload as the current user

## PoC

See [`poc.sh`](./poc.sh) for:
- A basic example using `whoami`
- An alternate version using a reverse shell payload. See [`poc_reverse_shell.sh`](./poc_reverse_shell.sh)
- Instructions for persistent execution and cleanup

## Detection

- Monitor for new/modified `.plist` files in:
  - `~/Library/LaunchAgents/`
  - `/Library/LaunchAgents/`
  - `/Library/LaunchDaemons/`
- Audit use of `launchctl load/unload`
- Use EDR or osquery to flag:
  - Non-standard agent labels
  - Unexpected payload paths
  - Unsigned launch binaries

## Mitigation

- Enforce least privilege (limit writable paths)
- Disable or restrict unnecessary LaunchAgent functionality
- Monitor plist and agent behavior using endpoint controls
- Enable SIP (System Integrity Protection) and code signing
- Use file integrity monitoring for LaunchAgent and LaunchDaemon directories

## References

- https://attack.mitre.org/techniques/T1543/001/
- https://objective-see.org/blog/blog_0x26.html
- https://github.com/hackedteam/core-osx/blob/master/launch_daemon_persistence.md


_Created by SentinelByte_
