# 🎯 MITRE ATT&CK Mapping

Таблица соответствия правил Wazuh, реализованных в лаборатории,
техникам и тактикам MITRE ATT&CK.

## Сводная таблица

| Тактика (Tactic) | Техника (Technique) | Rule ID | Level | Описание |
|---|---|---|---|---|
| Credential Access | **T1110.001** — Password Guessing | 5760, 5557, 5758, 5763 | 5–10 | SSH brute-force, множественные неудачные логины |
| Persistence | **T1136.001** — Create Account: Local Account | 5902, 40501 | 8–15 | Создание локального пользователя, композитное правило |
| Privilege Escalation | **T1548.003** — Sudo and Sudo Caching | 5403, 5404, 5405 | 4–10 | Подозрительная sudo-активность, отказ в доступе |
| Defense Evasion | **T1078** — Valid Accounts | 5501, 5502 | 3 | PAM: Login session opened/closed |
| Lateral Movement | **T1021.004** — SSH | 5760, 5557 | 5 | Использование SSH для перемещения |

## Детализация по техникам

### T1110.001 — Password Guessing (Credential Access)

**Правила Wazuh:**
- `5760` (level 5) — sshd: authentication failed
- `5557` (level 5) — unix_chkpwd: Password check failed
- `5758` (level 8) — Maximum authentication attempts exceeded
- `5763` (level 10) — sshd: brute force trying to get access to the system

**Как детектируется:** множественные события `Failed password` в `/var/log/auth.log`
от одного IP за короткий промежуток времени. Wazuh агрегирует их через
композитные правила и повышает severity.

**Источник:** auth.log, syslog.

---

### T1136.001 — Create Account: Local Account (Persistence)

**Правила Wazuh:**
- `5902` (level 8) — New user added to the system
- `40501` (level 15) — Attacks followed by the addition of an user

**Как детектируется:** Wazuh отслеживает изменения в `/etc/passwd` и `/etc/shadow`.
Композитное правило `40501` срабатывает, когда создание пользователя
происходит **после** серии атак (brute-force) — это признак компрометации.

**Источник:** FIM (File Integrity Monitoring), auth.log.

---

### T1548.003 — Sudo and Sudo Caching (Privilege Escalation)

**Правила Wazuh:**
- `5403` (level 4) — First time user executed sudo
- `5404` (level 10) — Three failed attempts to run sudo
- `5405` (level 10) — Unauthorized user attempted to use sudo

**Как детектируется:** Wazuh анализирует `/var/log/auth.log` на предмет
sudo-команд. Правило `5404` срабатывает после трёх неверных вводов пароля,
`5405` — при попытке выполнить запрещённую команду.

**Источник:** auth.log, sudo logs.

---

## Покрытие тактик

| Тактика | Покрыта | Правила |
|---|---|---|
| Initial Access | ✅ | 5760, 5763 |
| Execution | ❌ | — |
| Persistence | ✅ | 5902, 40501 |
| Privilege Escalation | ✅ | 5403, 5404, 5405 |
| Defense Evasion | ✅ | 5501, 5502 |
| Credential Access | ✅ | 5760, 5557, 5758, 5763 |
| Discovery | ❌ | — |
| Lateral Movement | ✅ | 5760 |
| Collection | ❌ | — |
| Command and Control | ❌ | — |
| Exfiltration | ❌ | — |
| Impact | ❌ | — |