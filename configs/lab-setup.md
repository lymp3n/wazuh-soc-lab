## Настройка Wazuh Agent на Debian 13 (Live USB)

Агент установлен из .deb-пакета версии 4.8.0 (для совместимости с менеджером):

\`\`\`bash
wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.8.0-1_amd64.deb
sudo WAZUH_MANAGER='192.168.0.X' dpkg -i ./wazuh-agent_4.8.0-1_amd64.deb
sudo systemctl enable --now wazuh-agent
\`\`\`

### Сбор логов SSH

Debian 13 использует systemd-journald вместо классического syslog.
Wazuh 4.8.0 не поддерживает `log_format=journald` (это появилось в 4.9.0),
поэтому я использовал обходной путь через rsyslog:

1. Установлен rsyslog:
   \`\`\`bash
   sudo apt install -y rsyslog
   \`\`\`

2. В `/etc/systemd/journald.conf` включена пересылка:
   \`\`\`
   ForwardToSyslog=yes
   \`\`\`

3. В `/etc/rsyslog.conf` раскомментирована строка:
   \`\`\`
   auth,authpriv.*   /var/log/auth.log
   \`\`\`

4. В конфиге Wazuh-агента (`/var/ossec/etc/ossec.conf`) добавлен блок:
   \`\`\`xml
   <localfile>
     <log_format>syslog</log_format>
     <location>/var/log/auth.log</location>
   </localfile>
   \`\`\`

После этого SSH-события начали попадать в Wazuh и генерировать алерты 5760, 5557, 5763 и др.