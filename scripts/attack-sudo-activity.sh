#!/bin/bash
# Case 003: Sudo Privilege Escalation (T1548.003)

echo "[*] Running suspicious sudo commands as testuser..."
su - testuser -c "sudo -l"
su - testuser -c "sudo ls /root"
su - testuser -c "sudo cat /etc/shadow"
su - testuser -c "sudo su -"

echo "[+] Done. Check Wazuh for rules 5403, 5404, 5405."