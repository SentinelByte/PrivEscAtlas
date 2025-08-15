# Windows Unquoted Service Path – Privilege Escalation via Service Misconfiguration

## Description

Windows services run executables specified by a path in the service configu. If this executable path contains **spaces but is not enclosed in quotes**, and one or more directories in the path are **writable by a non-admin user**, Windows may mistakenly execute an attacker-controlled executable placed earlier in the path.

This vuln allows local users to escalate privileges to **NT AUTHORITY\SYSTEM** by planting malicious binaries that are executed when the service starts.

---

## Privilege Escalation Vector

* **Initial Access Requirement**: Local user account with write permissions on at least one directory in the unquoted service path
* **Escalation Impact**: Execution of attacker-controlled code as **SYSTEM** (highest Windows privilege)
* **Typical Abuse Case**: Post-exploitation privilege escalation or unauthorized privilege gains from local user accounts

> 🧠 **MITRE ATT\&CK mapping**:
> T1543.003 – [Create or Modify System Process: Windows Service](https://attack.mitre.org/techniques/T1543/003/)

---

## Requirements

* Presence of a service configured with an unquoted executable path containing spaces
* At least one directory in that path writable by the current user
* Ability to start or restart the vulnerable service (or wait for automatic restart)

---

## Exploitation Steps

1. **Identify vulnerable services**
   Enumerate services with unquoted paths containing spaces that start automatically:

   ```powershell
   wmic service get name,displayname,pathname,startmode | findstr /i "Auto" | findstr /v /i "\""
   ```

2. **Check folder permissions**
   For each vulnerable path, check if any directory in the path is writable:

   ```powershell
   icacls "C:\Path\To\Folder"
   ```

3. **Plant malicious executable**
   Name the executable to match the truncated path Windows would execute due to lack of quotes. For example, if the path is:

   ```
   C:\Program Files\Vulnerable Service\service.exe
   ```

   You may place:

   * `C:\Program.exe`
     or
   * `C:\Program Files\Vulnerable.exe`
     depending on the service path parsing.

4. **Trigger service execution**
   Start or restart the service manually if permitted:

   ```cmd
   sc start <ServiceName>
   ```

   or wait for service restart on reboot.

---

## Detection

* Audit services for unquoted paths containing spaces:

  ```powershell
  Get-WmiObject win32_service | Where-Object { $_.PathName -match ' ' -and $_.PathName -notmatch '^".*"$' }
  ```

* Use Sysmon or Windows Event logs to monitor unexpected service start failures or binary execution in suspicious folders.

* Implement detection rules such as Sigma or osquery (examples below).

---

## Mitigation

* Always quote service executable paths when creating or configuring services:

  ```cmd
  sc config <ServiceName> binPath= "\"C:\Program Files\MyApp\service.exe\""
  ```

* Restrict write permissions on folders in service paths to administrators only.

* Regularly audit services for unquoted paths with spaces.

---

## References

* [Microsoft Docs: CreateServiceA](https://learn.microsoft.com/en-us/windows/win32/api/winsvc/nf-winsvc-createservicea)
* [GTFOBins: Unquoted Service Path](https://gtfobins.github.io/#+windows)
* [FuzzySecurity: Windows Service Privilege Escalation](https://www.fuzzysecurity.com/tutorials/16.html)
* [HackTricks: Windows Privilege Escalation](https://book.hacktricks.xyz/windows-hardening/windows-local-privilege-escalation#unquoted-service-path)

---

## Disclaimer

This documentation is for **educational and authorized penetration testing purposes only**. Unauthorized use is illegal and unethical.
