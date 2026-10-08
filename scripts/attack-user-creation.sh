#!/bin/bash
# Case 002: Suspicious User Creation (T1136.001)

echo "[*] Creating suspicious user..."
sudo useradd -m -s /bin/bash attacker
echo "attacker:P@ssw0rd123" | sudo chpasswd
sudo usermod -aG sudo attacker
echo "attacker:NewP@ssw0rd456" | sudo chpasswd

echo "[+] User created. Check Wazuh for rules 5902, 40501."