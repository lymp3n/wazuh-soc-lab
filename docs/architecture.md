### 📄 Файл 1: `docs/incident-reports/README.md`

Этот файл — индекс, на который ссылается главный README. Сохрани его в `D:\wazuh-soc-lab\docs\incident-reports\README.md`:

```markdown
# 📋 Incident Reports Index

Все инциденты, зафиксированные в лаборатории Wazuh SOC.

| ID | Название | Правила Wazuh | MITRE ATT&CK | Severity | Дата |
|---|---|---|---|---|---|
| [CS-001](CS-001-SSH-BruteForce.md) | SSH Brute-Force | 5760, 5557, 5758, 5763 | T1110.001 | High (10) | 2026-10-08 |
| [CS-002](CS-002-User-Creation.md) | Suspicious User Creation | 5902, 5555, 40501 | T1136.001 | Critical (15) | 2026-10-08 |
| [CS-003](CS-003-Sudo-Activity.md) | Sudo Privilege Escalation | 5403, 5404, 5405 | T1548.003 | High (10) | 2026-10-09 |

## Формат отчёта

Каждый кейс содержит:

- **Metadata** — дата, правила, хосты, MITRE-маппинг.
- **Description** — описание атаки и как она детектирована.
- **Evidence** — конкретные поля алертов, IP, пользователи, `full_log`.
- **Timeline** — хронология событий в UTC.
- **Response** — действия и рекомендации.
- **Verdict** — вердикт: false positive, компрометация, эскалация.

## Severity Levels (Wazuh)

| Level | Значение | Действие |
|---|---|---|
| 0–3 | Информация | Логирование |
| 4–7 | Низкий/Средний | Мониторинг |
| 8–11 | Высокий | Триаж, эскалация на L2 |
| 12–15 | Критический | Немедленная эскалация, изоляция |
```

---

### 📄 Файл 2: `docs/mitre-mapping.md`

Этот файл показывает, какие техники MITRE ATT&CK покрыты в лаборатории. Сохрани его в `D:\wazuh-soc-lab\docs\mitre-mapping.md`:

```markdown
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
```

---

### 📄 Файл 3: `docs/architecture.md`

Этот файл описывает архитектуру лаборатории. Сохрани его в `D:\wazuh-soc-lab\docs\architecture.md`:

```markdown
# 🏗️ Архитектура лаборатории

## Общая схема

```
┌──────────────────────────────────────────────────────────────────┐
│  Windows Host (Docker Desktop)                                   │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │  Wazuh Single-Node Stack (Docker Compose)                  │  │
│  │                                                            │  │
│  │  ┌──────────────────┐  ┌──────────────────┐               │  │
│  │  │  wazuh.manager   │  │  wazuh.indexer   │               │  │
│  │  │  :1514 (agents)  │  │  :9200 (API)     │               │  │
│  │  │  :1515 (enroll)  │  │  OpenSearch      │               │  │
│  │  │  :55000 (API)    │  │                  │               │  │
│  │  │  :514/udp (syslog)│  │                  │               │  │
│  │  └────────┬─────────┘  └────────┬─────────┘               │  │
│  │           │                     │                         │  │
│  │           └──────────┬──────────┘                         │  │
│  │                      │                                    │  │
│  │           ┌──────────▼──────────┐                         │  │
│  │           │  wazuh.dashboard    │                         │  │
│  │           │  :443 (web UI)      │                         │  │
│  │           │  OpenSearch Dash    │                         │  │
│  │           └─────────────────────┘                         │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Docker volumes (bind mounts на D:/wazuh_data/):                 │
│  - wazuh_etc, wazuh_logs, wazuh_queue                            │
│  - wazuh-indexer-data                                            │
│  - wazuh-dashboard-config                                        │
└──────────────────────────────────────────────────────────────────┘
                              ▲
                              │ Wazuh agent protocol (TCP 1514, AES)
                              │
              ┌───────────────┴───────────────┐
              │                               │
    ┌─────────▼─────────┐           ┌─────────▼─────────┐
    │  Debian 13 (VM)   │           │  Kali Linux (VM)  │
    │  (Victim)         │           │  (Attacker)       │
    │                   │           │                   │
    │  IP: 192.168.0.9  │           │  IP: 192.168.0.11 │
    │  Wazuh Agent      │           │  hydra, sshpass   │
    │  OpenSSH Server   │           │  nmap, netcat     │
    │  rsyslog          │           │                   │
    │  auth.log         │           │                   │
    └───────────────────┘           └───────────────────┘
```

## Компоненты

### Wazuh Manager

- **Роль:** принимает события от агентов, применяет правила детектирования,
  генерирует алерты, управляет active response.
- **Порты:**
  - `1514/tcp` — приём событий от агентов.
  - `1515/tcp` — регистрация новых агентов.
  - `55000/tcp` — REST API для дашборда и автоматизации.
  - `514/udp` — syslog (для устройств без агента).
- **Конфигурация:** `/var/ossec/etc/ossec.conf` (внутри контейнера).

### Wazuh Indexer

- **Роль:** хранение и индексация алертов, полнотекстовый поиск.
- **Технология:** OpenSearch (форк Elasticsearch).
- **Порт:** `9200/tcp`.
- **Индексы:** `wazuh-alerts-4.x-YYYY.MM.DD`, `wazuh-monitoring-*`,
  `wazuh-states-vulnerabilities-*`.
- **Память:** 1 GB heap (`OPENSEARCH_JAVA_OPTS=-Xms1g -Xmx1g`).

### Wazuh Dashboard

- **Роль:** веб-интерфейс для визуализации, поиска, управления агентами.
- **Порт:** `443/tcp` (HTTPS).
- **Логин:** `admin` / пароль из `.env`.
- **Интеграция:** MITRE ATT&CK, Security Events, Agents, FIM, Vulnerabilities.

### Debian 13 (Victim)

- **Роль:** жертва атак, источник логов.
- **Сервисы:** OpenSSH Server, rsyslog, Wazuh Agent 4.8.0.
- **Логи:** `/var/log/auth.log` (SSH, sudo), `/var/log/syslog`.
- **Особенность:** Debian 13 использует systemd-journald вместо syslog.
  Для совместимости с Wazuh 4.8.0 установлен rsyslog + `ForwardToSyslog=yes`.

### Kali Linux (Attacker)

- **Роль:** генерация атакующего трафика.
- **Инструменты:** `hydra` (brute-force), `sshpass` (скриптовые логины),
  `nmap`, `netcat`.
- **Сценарии:** SSH brute-force, создание пользователя (через SSH-сессию),
  sudo-эскалация.

## Сеть

### Схема связности

```
Kali (192.168.0.11) ──SSH──▶ Debian (192.168.0.9) ──Wazuh Agent──▶ Manager
                                                                      │
                                                              (Docker bridge)
                                                                      │
                                                                      ▼
                                                              Indexer ──▶ Dashboard
```

### Порты и протоколы

| Источник | Назначение | Порт | Протокол | Назначение |
|---|---|---|---|---|
| Debian Agent | Wazuh Manager | 1514 | TCP | Передача событий |
| Debian Agent | Wazuh Manager | 1515 | TCP | Регистрация |
| Dashboard | Wazuh Manager | 55000 | TCP | REST API |
| Kali | Debian | 22 | TCP | SSH (атака) |
| Windows Host | Dashboard | 443 | TCP | Web UI |

### NAT и брандмауэр

- Docker Desktop пробрасывает порты `0.0.0.0:1514-1515`, `55000`, `443`
  на Windows-хост.
- Windows Firewall должен пропускать входящие на эти порты (правила созданы).
- Debian Agent подключается к `192.168.0.x` (IP Windows-хоста), а не к
  внутреннему IP Docker (`172.18.0.x`).

## Хранилище

Все данные Wazuh вынесены на диск `D:` через bind mounts:

```
D:/wazuh_data/
├── wazuh_api_configuration/   # API конфиги
├── wazuh_etc/                 # ossec.conf, rules, decoders
├── wazuh_logs/                # alerts.json, archives.json
├── wazuh_queue/               # очереди событий
├── wazuh-indexer-data/        # индексы OpenSearch (основной объём)
├── filebeat_etc/              # конфиги Filebeat
├── filebeat_var/              # состояние Filebeat
├── wazuh-dashboard-config/    # конфиги дашборда
└── wazuh-dashboard-custom/    # кастомные плагины
```

Это позволяет:
- Не занимать место на системном диске `C:`.
- Легко бэкапить и переносить лабораторию.
- Очищать данные без пересоздания контейнеров.

## Поток данных

```
1. Атака (Kali) ──▶ SSH-попытки ──▶ Debian (auth.log)
2. Wazuh Agent (Debian) ──читает──▶ auth.log
3. Агент ──шифрует (AES)──▶ Wazuh Manager :1514
4. Manager ──применяет правила──▶ генерирует алерт (JSON)
5. Manager ──▶ alerts.json ──Filebeat──▶ Wazuh Indexer :9200
6. Indexer ──индексирует──▶ wazuh-alerts-4.x-YYYY.MM.DD
7. Dashboard ──запрос──▶ Indexer ──▶ визуализация в UI
```

## Масштабирование (в продакшене)

В реальной инфраструктуре:

- **Manager** — кластер из 2+ нод (master + worker) с балансировкой.
- **Indexer** — кластер OpenSearch из 3+ нод (hot/warm/cold).
- **Dashboard** — за балансировщиком (nginx/HAProxy) с TLS.
- **Агенты** — тысячи endpoints, группы, централизованные политики.
- **Интеграции** — TheHive, MISP, Slack, Telegram, Jira.

В этой лаборатории используется **single-node** для простоты и экономии ресурсов.
```