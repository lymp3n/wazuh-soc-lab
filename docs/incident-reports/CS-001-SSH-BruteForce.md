# Case Study 001: SSH Brute-Force Detection

## Metadata
| Field | Value |
|---|---|
| Date | 2026-10-08 |
| Detection rules | Wazuh 5760, 5557, 5758, 2502, 40111, **5763** |
| Victim host | Debian (192.168.0.9) |
| Attacker | Kali (192.168.0.11) |
| MITRE ATT&CK | **T1110.001 — Password Guessing** |

## Description
Серия неудачных SSH-аутентификаций по учётной записи `root` с IP 192.168.0.11.
Wazuh зафиксировал множественные срабатывания rule 5760 и агрегированный алерт
rule 5763 (level 10) — sshd: brute force trying to get access to the system.
## Evidence
- `full_log`: `Failed password for root from 192.168.0.11 port XXXX ssh2`
- `data.srcip`: 192.168.0.11
- `data.dstuser`: root
- Screenshots: `docs/screenshots/CS-001/`

## Timeline
| Time (UTC) | Event                                                   |
| ---------- | ------------------------------------------------------- |
| 23:04:54   | Начало серии неудачных логинов                          |
| 23:05:10   | Срабатывание rule 5763 (level 10)                       |
| 23:06:06   | rule 2502 — User missed the password more than one time |

## Response
1. Проверил IP источника — Kali (192.168.0.11), тестовая машина.
2. Убедился, что успешных логинов с этого IP не было.
3. Рекомендовано: fail2ban, отключить PermitRootLogin, ключи вместо паролей.

## Verdict
- False positive: No
- Compromised: No
- Recommended action: Настроить fail2ban, ограничить SSH по IP.