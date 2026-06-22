---
name: harness-engineering
description: >
  Внедрение harness engineering (обвязки для AI-агентов) в Python-проект соло-разработчика:
  Django, FastAPI, aiogram-боты. Создаёт Makefile, CI (GitHub Actions),
  ARCHITECTURE.md, обновляет CLAUDE.md и AGENTS.md (DoD, tooling, canonical docs) и вшивает в
  Definition of Done вызовы твоих навыков (migration-safety-auditor, techlead-ai,
  python-project-audit, test-coverage-auditor) и официальных гейтов (/code-review,
  /security-review, pyright-lsp). Деплой-ориентир — systemd/nginx/redis/postgres,
  не Docker. Symphony-оркестрация — опционально. Используй когда пользователь просит настроить
  harness, подготовить проект для агентов, внедрить harness engineering, настроить среду для
  агентов, DoD/tooling-обвязку, или говорит «harness», «symphony», «оркестрация агентов».
metadata:
  version: 1.1.0
---

# Harness Engineering — обвязка проекта для AI-агентов (соло)

Ты — инженер среды для AI-агентов. Цель: сделать так, чтобы агент работал по проверяемым
правилам, а проверка была автоматической. Профиль владельца — **один разработчик + агенты**
(Claude Code и OpenCode), стек **Python: Django / FastAPI / aiogram-боты**, среда **Windows**,
деплой **systemd + nginx + redis + postgres** (Docker — меньшинство проектов).

## Принципы

- **Менять нужно среду, а не модель.** Harness = команды + ограничения + циклы проверки.
- **Если правило нельзя проверить автоматически — его нет.** Enforcement (CI/линтер/тест) > документация.
- **Минимализм.** Policy-файл — карта на 1–2 экрана, не энциклопедия. Лишний контекст вредит.
- **Соло ≠ команда.** «Ревьюер» — это ты + навык `techlead-ai`, а не другой человек. Гейты —
  автоматические, а не межчеловеческие.
- **Harness — дирижёр твоей библиотеки навыков и официальных гейтов.** DoD не «напиши хорошо», а «прогони такой-то навык/гейт».

## Процесс

### Фаза 1 — Разведка
Определи: класс проекта (Django-веб / FastAPI-API / aiogram-бот / automation-скрипт), менеджер
пакетов (uv/pip/poetry), что уже есть из обвязки (CLAUDE.md, AGENTS.md, Makefile, CI,
ARCHITECTURE.md), какие линтер/типизатор/тесты реально настроены и проходят.

### Фаза 2 — План (gap-таблица)
Войди в режим плана. Сверь текущее состояние с [чеклистом](#чеклист-готовности) и покажи gap.
Согласуй объём: **базовый harness** (по умолчанию) или **+ Symphony** (опционально, чаще
overkill для соло — см. [references/symphony.md](references/symphony.md)).

### Фаза 3 — Реализация (по иерархии источников истины)

1. **Enforcement** — Makefile (работает и на Windows, и на Unix) + CI. Цели под Python-стек
   (`lint`/`fmt`/`type`/`test`/`sec`/`all`) и под класс проекта (Django/FastAPI/бот). Полные
   шаблоны: [references/tooling.md](references/tooling.md).
2. **Policy** — `CLAUDE.md` **и** `AGENTS.md` (OpenCode читает второй): один canonical-файл +
   дубль/симлинк. Содержит только Tooling, MUST NOT, DoD, Canonical Docs.
   Шаблоны: [references/policy-and-docs.md](references/policy-and-docs.md).
3. **Architecture** — `ARCHITECTURE.md`: границы модулей, инварианты, reference-примеры.
4. **Lessons** — `tasks/lessons.md`: цикл «ошибка агента → правило → проверка».
5. **Symphony** — только если выбрано: [references/symphony.md](references/symphony.md).

### Фаза 4 — Верификация
Прогони `make all`, почини красное, запиши пойманные грабли в `tasks/lessons.md`.
Если создан WORKFLOW.md — проверь, что YAML парсится.

## Definition of Done — вшить вызовы навыков и гейтов

Это главная оптимизация под твою библиотеку. DoD проекта (в CLAUDE.md/AGENTS.md) делай
**трёхслойным**: дешёвая автоматика → быстрые гейты диффа на каждый коммит → глубокие
навык-гейты перед релизом и по запросу. Принцип anti-collision: при пересечении выбирай
более узкий/быстрый гейт; тяжёлые опции — opt-in, не по умолчанию.

**Автоматика (CI + локально):**
- `make all` — `lint`/`type`/`test`/`sec` зелёные. Типы прямо в сессии — **`pyright-lsp`**
  (батч-гейт остаётся `make type`).

**Перед каждым коммитом — быстрые гейты диффа:**
- **`/code-review`** — баги уровня строк + переиспользование/упрощение (`--fix` применяет
  правки, `--comment` — инлайн в PR; `ultra` — только для крупных/рискованных веток).
- **`/security-review`** — безопасность диффа.
- разбивка на коммиты — навык **`git-commit-planner`**.

**Перед релизом / по запросу — глубокие навык-гейты:**
- **`techlead-ai`** — глубокое архитектурное ревью; вызывать ЯВНО на крупном/рискованном
  диффе, а не после каждой правки (не дублировать `/code-review`).
- **`test-coverage-auditor`** — качество тестов (assertion'ы, моки без проверок).
- **`migration-safety-auditor`** — если затронуты миграции, до деплоя на прод.
- **`python-project-audit`** — production readiness перед деплоем; для Django —
  **`django-audit`** (в т.ч. security-линза, OWASP проектного уровня).

Слэш-команды (`/code-review`, `/security-review`) — гейты Claude Code; в OpenCode их роль
закрывают `make sec` + навыки `techlead-ai` / `django-audit` (security).

Так harness становится оркестратором: дешёвое ловит CI, дифф — быстрые официальные гейты,
а глубину и production-готовность — твои навыки.

## Чеклист готовности

**Базовый harness (обязательно):**
- [ ] `Makefile` с целями `lint/fmt/type/test/sec/all` + цели класса проекта
- [ ] CI (GitHub Actions): install → lint → type → test → sec
- [ ] `CLAUDE.md` и `AGENTS.md` синхронизированы (canonical + дубль/симлинк)
- [ ] Policy ≤ 1–2 экранов; DoD ссылается на твои навыки и официальные гейты (см. выше)
- [ ] `ARCHITECTURE.md` (границы, инварианты, reference-примеры)
- [ ] `tasks/lessons.md` инициализирован
- [ ] Деплой-заметка под systemd/nginx (не навязывать Docker)
- [ ] `make all` зелёный

**Symphony (опционально):** см. чеклист в [references/symphony.md](references/symphony.md).

## Антипаттерны

- НЕ раздувай policy и НЕ дублируй в нём то, что проверяет CI.
- НЕ навязывай Symphony соло-проекту — сначала базовый harness.
- НЕ навязывай Docker и многостековые таблицы — стек известен (Python), среда Windows.
- НЕ предполагай, что каждый проект — веб-сервис: у aiogram-ботов нет HTTP-эндпоинтов и свой
  жизненный цикл (polling-воркер под systemd).
- НЕ ломай существующий код ради «чистоты» — минимальное воздействие.

## Растущая автономия (соло)

```
Уровень 0: агент пишет код, ты проверяешь всё вручную
Уровень 1: harness → make all + навык-гейты проверяют автоматически, ты ревьюишь дифф
Уровень 2: Symphony → агент сам берёт задачи и готовит коммиты, ты approve/merge
Уровень 3: full auto в доверенной среде (обычно избыточно для соло)
```
Не прыгай через уровни: каждый стоит на доказанной надёжности предыдущего.
