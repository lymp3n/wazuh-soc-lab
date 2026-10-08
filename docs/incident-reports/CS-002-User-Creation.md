# # Case Study 002: Suspicious User Creation After Brute-Force

## Metadata
| Field              | Value                                         |
| ------------------ | --------------------------------------------- |
| Date               | 2026-10-08                                    |
| Detection rules    | Wazuh 5902 (L8), **40501 (L15)**, 5403 (L4)   |
| Victim host        | Debian (192.168.0.9)                          |
| Attacker           | Kali (192.168.0.11) / local sudo              |
| MITRE ATT&CK       | **T1136.001 — Create Account: Local Account** |
| Additional tactics | Persistence, Privilege Escalation             |

## Description
После серии неудачных SSH-аутентификаций зафиксировано создание новой
учётной записи `hacker` с добавлением в группу `sudo`. Wazuh сгенерировал
композитное правило 40501 (level 15) — "Attacks followed by the addition
of an user", что указывает на вероятную компрометацию и попытку
закрепления в системе.

## Evidence
- `rule.id`: 40501, 5902, 5403
- `data.dstuser`: hacker
- `full_log`: `useradd[XXXX]: new user: name=hacker, UID=1001...`
- Screenshots: `docs/screenshots/CS-002/`

## Timeline
| Time (UTC) | Event                                                             |
| ---------- | ----------------------------------------------------------------- |
| 23:08:34   | New user added to the system (rule 5902)                          |
| 23:08:34   | **Attacks followed by the addition of an user (rule 40501, L15)** |
| 23:08:46   | Successful sudo to ROOT executed (rule 5402)                      |

## Response
1. Проверить легитимность создания пользователя (подтверждено, что это тестовая активность в лаборатории).
2. В реальной среде: немедленная эскалация на L2, блокировка учётки, проверка всех сессий пользователя `hacker`.
3. Проверить, не было ли успешного SSH-логина под новой учёткой.
4. Рекомендовано: мониторинг создания пользователей через SIEM, алертинг на добавление в `sudo` группу.

## Verdict
- False positive: No
- Compromised: Yes (в рамках лабораторного сценария)
- Recommended action: В продакшене — эскалация на L2, изоляция хоста.