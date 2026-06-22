# Policy и canonical-документация (соло)

Policy — карта на 1–2 экрана, не энциклопедия. Дублировать в ней то, что проверяет CI, нельзя.

## CLAUDE.md + AGENTS.md

Ты используешь Claude Code и OpenCode. Claude Code читает `CLAUDE.md`, OpenCode — `AGENTS.md`.
Держи **один canonical-файл и дубль/симлинк**, чтобы не разъезжались:

```bash
# из корня проекта (Git Bash / WSL)
ln -s CLAUDE.md AGENTS.md
```
На Windows симлинк может не сработать без прав — тогда держи AGENTS.md как копию и обновляй оба,
либо собирай оба из одного источника. Главное — не вести две независимые версии.

## Шаблон policy-файла (CLAUDE.md / AGENTS.md)

```markdown
# <Проект> — заметки для агента

## Tooling
make lint | make fmt | make type | make test | make sec | make all
(make работает и на Windows, и на Unix/Linux)
В сессии: pyright-lsp (типы) · /code-review + /security-review (быстрые гейты диффа)

## MUST NOT
- Не применять миграции на проде без прогона навыка migration-safety-auditor
- Не редактировать уже применённые миграции
- Не коммитить секреты; конфиг — через env, не в репозиторий
- <короткие проверяемые запреты под конкретный проект>

## Definition of Done
Автоматика: make all — зелёный (lint, type, test, sec); типы в сессии — pyright-lsp.

Перед каждым коммитом (быстрые гейты диффа):
1. /code-review — баги + переиспользование/упрощение (--fix применяет правки)
2. /security-review — безопасность диффа
3. коммиты — по git-commit-planner

Перед релизом / по запросу (глубокие навык-гейты):
4. test-coverage-auditor — качество тестов (assertion'ы, моки)
5. migration-safety-auditor — если затронуты миграции, до деплоя
6. techlead-ai — глубокое ревью на крупном/рискованном диффе (вызывать явно)
7. python-project-audit — production readiness (для Django — django-audit, security-линза)

(Слэш-команды — гейты Claude Code; в OpenCode роль закрывают make sec + techlead-ai/django-audit.)

## Canonical Documentation
- ARCHITECTURE.md — границы модулей, инварианты, reference-примеры
- tasks/lessons.md — накопленные грабли и правила
- WORKFLOW.md — оркестрация (только если включён Symphony)
```

Соло-нюанс: DoD — не пожелания, а конкретные вызовы. Быстрые гейты диффа — официальные команды
Claude Code (`/code-review`, `/security-review`), глубину и release-готовность дают твои навыки.
Harness здесь — оркестратор, поэтому policy остаётся коротким, а «как именно проверять» живёт
в навыках и командах.

## ARCHITECTURE.md

```markdown
# Архитектура

## Компоненты
<кратко: какие модули и за что отвечают>

## Границы и зависимости
<кто от кого зависит; зависимости однонаправленные>

## Инварианты
- <правила, которые ВСЕГДА соблюдаются — то, что агент не должен нарушать>

## Reference-примеры
| Паттерн | Эталонный файл |
|---------|----------------|
| Django-вью | app/views/orders.py |
| FastAPI-роут + Pydantic | app/api/orders.py |
| aiogram-роутер + FSM | bot/handlers/checkout.py |
```

## tasks/lessons.md

```markdown
# Lessons Learned
Цикл: ошибка агента → правило → проверка.

### [ГГГГ-ММ-ДД] Краткое описание
**Паттерн:** что пошло не так
**Правило:** что делать/не делать
**Проверка:** какой lint/тест/CI-шаг это ловит (если правило непроверяемо — сделать проверяемым)
```

Каждую пойманную в Фазе 4 проблему фиксируй здесь. Если правило нельзя привязать к
автоматической проверке — это сигнал добавить линт-правило или тест, а не просто текст.
