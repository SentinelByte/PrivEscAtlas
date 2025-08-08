# macOS LaunchDaemons – Privilege Escalation via Root-Level Persistence

## Description

LaunchDaemons are system-wide background services on macOS, defined via `.plist` files placed in `/Library/LaunchDaemons/`. These daemons are executed **as root** during system boot or when explicitly loaded via `launchctl`.

If an attacker has root or `sudo` access, they can:
- Drop a malicious `.plist` file
- Trigger it using `launchctl load`
- Achieve **privileged persistence** or execute arbitrary commands as root

LaunchDaemons are a classic post-exploitation technique for establishing long-lived privileged footholds on macOS.

---

## Privilege Escalation Vector

- **Initial Access Requirement**: root privileges or sudo
- **Escalation Impact**: Persistence and reliable code execution as **root**
- **Typical Abuse Case**: Post-exploitation or privilege retention after an initial user-level compromise

> 🧠 **MITRE ATT&CK mapping**:  
> T1543.004 – [Create or Modify System Process: Launch Daemon](https://attack.mitre.org/techniques/T1543/004/)

---

## Requirements

- Ability to write to `/Library/LaunchDaemons/` (i.e., root access)
- A payload binary or command to execute
- Proper permissions and ownership:
  - `chown root:wheel`
  - `chmod 644`

---

## Exploitation Steps

1. Craft a `.plist` file specifying the payload (e.g., reverse shell, script, binary)
2. Copy it to `/Library/LaunchDaemons/`
3. Set ownership and permissions:
   ```bash
   sudo chown root:wheel <file>
   sudo chmod 644 <file>
