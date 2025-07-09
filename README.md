# Privilege Escalation Patterns DB

A structured collection of privilege escalation techniques across Linux, Windows, and macOS. Each entry includes:

- Technique overview and context
- Proof-of-concept (PoC) where applicable
- Detection and logging guidance
- Suggested mitigations
- References for further reading

---

## Structure

Techniques are organized by platform and category:


Each folder contains a `README.md` describing the pattern and optionally:
- PoC scripts (`poc.sh`, `exploit.py`, etc.)
- Detection rules (`sigma/`, `auditd/`)
- Mitigation examples

---

## Purpose

This project is meant to serve:
- Red teamers exploring local escalation paths
- Blue teamers building detection logic
- Learners studying common privilege escalation methods
- Engineers reviewing OS hardening coverage

---

## Contributing

Pull requests are welcome. Please follow the existing folder structure and pattern format. See `CONTRIBUTING.md` for details.

---

## License

MIT License. See `LICENSE` for full terms.
