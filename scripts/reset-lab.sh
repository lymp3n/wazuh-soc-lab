#!/bin/bash
# Reset lab to clean state before each case study

echo "[*] Stopping Wazuh agent..."
sudo systemctl stop wazuh-agent

echo "[*] Truncating agent logs..."
sudo truncate -s 0 /var/ossec/logs/ossec.log

echo "[*] Cleaning auth.log..."
sudo truncate -s 0 /var/log/auth.log

echo "[*] Starting agent..."
sudo systemctl start wazuh-agent

echo "[+] Lab reset. Alerts in Wazuh need to be cleared via dashboard."
echo "    Dashboard > Stack Management > Index Management > wazuh-alerts-* > Delete"