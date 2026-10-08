# Case Study 003: Suspicious Sudo Activity

## Metadata
| Field | Value |
|---|---|
| Date | 2026-10-09 |
| Detection rules | Wazuh 5402 (L3), **5403 (L4)**, 5404 (L5), 5501/5502 |
| Victim host | Debian (192.168.0.9) |
| Suspicious user | testuser |
| MITRE ATT&CK | **T1548.003 — Abuse Elevation Control Mechanism: Sudo and Sudo Caching** |
| Additional tactics | Privilege Escalation, Discovery |

## Description
Пользователь `testuser` (с ограниченными sudo-правами) выполнил серию
подозрительных действий:
- Разведка разрешённых sudo-команд (`sudo -l`)
- Попытка чтения `/etc/shadow` (запрещено)
- Попытка открыть root-shell (`sudo su -`, запрещено)
- Попытка редактирования sudoers (`sudo visudo`, запрещено)

Wazuh зафиксировал правило 5403 (First time user executed sudo) —
признак того, что учётка ранее не использовала sudo, и её активность
требует проверки. Также сработали правила 5404 (Unsuccessful sudo)
на запрещённые команды.

## Evidence
- `rule.id`: 5403, 5404, 5402
- `data.srcuser`: testuser
- `data.dstuser`: root
- `full_log`: `sudo: testuser : command not allowed ; TTY=pts/0 ; PWD=/home/testuser ; USER=root ; COMMAND=/usr/bin/cat /etc/shadow`
- Screenshots: `screenshots/CS-003/`

## Timeline
| Time (UTC) | Event                                                      |
| ---------- | ---------------------------------------------------------- |
| 00:09:58   | testuser впервые выполнил sudo (rule 5403)                 |
| 00:09:58   | Попытка чтения /etc/shadow — Unsuccessful sudo (rule 5404) |
| 00:09:58   | Попытка sudo su — Unsuccessful sudo (rule 5404)            |
| 00:09:58   | Попытка sudo visudo — Unsuccessful sudo (rule 5404)        |

## Response
1. Проверить легитимность действий пользователя testuser.
2. В реальной среде: связаться с владельцем учётки, проверить источник подключения.
3. Проверить, не было ли успешного sudo-доступа или изменений в /etc/sudoers.
4. Проверить, есть ли другие попытки с этого IP.

## Verdict
- False positive: No
- Compromised: No (все привилегированные команды отклонены)

### Recommended action: 
  - Ограничить sudo до минимально необходимых команд.
  - Мониторить неуспешные sudo-попытки в реальном времени.