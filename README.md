# 🛡️ Wazuh SOC Home Lab

Персональная лаборатория для отработки навыков **SOC Analyst L1**:
развёртывание SIEM, генерация атак, триаж инцидентов, документирование
с привязкой к MITRE ATT&CK.

## 🎯 Цель проекта

Демонстрация практических навыков, необходимых для позиции SOC L1:
- Развёртывание и настройка SIEM (Wazuh + OpenSearch).
- Подключение агентов (Linux) и настройка сбора логов.
- Детектирование атак через встроенные правила Wazuh.
- Триаж инцидентов и оформление отчётов (incident reports).
- Маппинг событий на **MITRE ATT&CK**.
- Работа с Docker, Git, Linux, Bash.

## 🏗️ Архитектура лаборатории

```
┌──────────────────────────────────────────────────────────┐
│  Windows Host (Docker Desktop)                           │
│  ┌────────────────────────────────────────────────────┐  │
│  │  Wazuh Single-Node Stack                           │  │
│  │  ┌──────────┐  ┌──────────┐  ┌─────────────────┐   │  │
│  │  │ Manager  │  │ Indexer  │  │ Dashboard       │   │  │
│  │  │ :1514    │  │ :9200    │  │ :443            │   │  │
│  │  │ :1515    │  │          │  │                 │   │  │
│  │  │ :55000   │  │          │  │                 │   │  │
│  │  └──────────┘  └──────────┘  └─────────────────┘   │  │
│  └────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
              ▲                            ▲
              │                            │
      ┌───────┴────────┐          ┌────────┴───────┐
      │  Debian 13 VM  │          │  Kali Linux VM │
      │  (Victim)      │          │  (Attacker)    │
      │  Wazuh Agent   │          │  hydra, nmap   │
      │  192.168.0.9   │          │  192.168.0.11  │
      └────────────────┘          └────────────────┘
```

- **Wazuh 4.8.0** (single-node, Docker) — SIEM + XDR.
- **Debian 13** — жертва, Wazuh Agent, SSH, syslog.
- **Kali Linux** — атакующий, генерация трафика.

## 🎯 Реализованные сценарии

| ID | Сценарий | Правила Wazuh | MITRE ATT&CK | Severity |
|---|---|---|---|---|
| [CS-001](docs/incident-reports/CS-001-SSH-BruteForce.md) | SSH Brute-Force | 5760, 5557, 5758, 5763 | T1110.001 | High (10) |
| [CS-002](docs/incident-reports/CS-002-User-Creation.md) | Suspicious User Creation | 5902, 5555, 40501 | T1136.001 | Critical (15) |
| [CS-003](docs/incident-reports/CS-003-Sudo-Activity.md) | Sudo Privilege Escalation | 5403, 5405 | T1548.003 | High (10) |

Подробнее — в [индексе инцидентов](docs/incident-reports/README.md).

## 🛠️ Стек технологий

- **SIEM/XDR**: Wazuh 4.8.0, OpenSearch, Filebeat
- **Инфраструктура**: Docker, Docker Compose
- **ОС**: Windows (хост), Debian 13, Kali Linux
- **Атаки**: Hydra, sshpass, встроенные средства
- **Документация**: Markdown (Obsidian), Git, GitHub

## 🚀 Быстрый старт

### Требования

- Docker Desktop (Windows/macOS/Linux)
- Минимум 8 ГБ RAM, 4 CPU, 50 ГБ диска
- Git

### Развёртывание Wazuh

```bash
# 1. Клонировать репозиторий
git clone https://github.com/lymp3n/wazuh-soc-lab.git
cd wazuh-soc-lab

# 2. Скачать официальный репозиторий Wazuh Docker
git clone -b v4.8.0 https://github.com/wazuh/wazuh-docker.git
cd wazuh-docker/single-node

# 3. Сгенерировать SSL-сертификаты
docker compose -f generate-indexer-certs.yml run --rm generator

# 4. Запустить стек
docker compose up -d

# 5. Проверить статус
docker compose ps
```

Дашборд: **https://localhost:443** (учётные данные из вашего `.env`).

### Подключение агента (Debian 13)

```bash
# Установка агента Wazuh 4.8.0 (версия должна совпадать с менеджером)
wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.8.0-1_amd64.deb
sudo WAZUH_MANAGER='<IP_МЕНЕДЖЕРА>' dpkg -i ./wazuh-agent_4.8.0-1_amd64.deb

sudo systemctl daemon-reload
sudo systemctl enable --now wazuh-agent
```

**Важно:** на Debian 13 используется systemd-journald, а Wazuh 4.8.0
не умеет читать journald напрямую (поддержка появилась в 4.9.0).
Решение — установить `rsyslog` и включить пересылку из journald.
Подробнее — в [lab-setup.md](docs/lab-setup.md).

## 📚 Документация

- [Архитектура лаборатории](docs/architecture.md)
- [Настройка с нуля](docs/lab-setup.md)
- [Маппинг на MITRE ATT&CK](docs/mitre-mapping.md)
- [Индекс инцидентов](docs/incident-reports/README.md)

## 📊 Скриншоты

Скриншоты всех инцидентов — в `docs/screenshots/`:
- `CS-001/` — SSH Brute-Force detection
- `CS-002/` — User creation + composite alert (level 15)
- `CS-003/` — Sudo privilege escalation attempt

## 🎓 Чему я научился

- Развёртывание single-node Wazuh в Docker с persist-хранилищем
  (bind mounts на отдельный диск).
- Настройка сбора логов через syslog и обход несовместимости journald
  в Wazuh 4.8.0.
- Диагностика проблем: NAT между Docker и внешней сетью, брандмауэр
  Windows, версии агентов, индексация в OpenSearch.
- Работа с композитными алертами (rule 40501 — level 15).
- Триаж инцидентов и оформление отчётов по структуре, близкой к
  реальному SOC (Metadata, Description, Evidence, Timeline, Response,
  Verdict).
- Работа с MITRE ATT&CK: маппинг правил Wazuh на тактики и техники.
- Работа с Git, Markdown, Docker Compose.

## 📝 Roadmap

- [x] Развёртывание Wazuh single-node
- [x] Подключение Linux-агента
- [x] Case 001: SSH Brute-Force (T1110.001)
- [x] Case 002: User Creation (T1136.001)
- [x] Case 003: Sudo Activity (T1548.003)
- [ ] Windows-агент + Sysmon (T1059.001, PowerShell)
- [ ] Интеграция с TheHive / MISP
- [ ] Автоматизация через Wazuh API + Python
- [ ] Кастомные дашборды в OpenSearch Dashboards

## 👤 Автор

**Федченко Андрей** — начинающий SOC Analyst L1
- GitHub: [@lymp3n](https://github.com/lymp3n)