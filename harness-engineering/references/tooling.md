# Tooling — задачи-команды и CI под Python-стек

Стек известен: Python (Django / FastAPI / aiogram). Многостековые таблицы не нужны.
Инструменты по умолчанию: **ruff** (lint + format), **mypy** (types), **pytest**
(+ pytest-django / httpx для FastAPI), **bandit** + **pip-audit** (security).

## Runner: Makefile (работает и на Windows, и на Unix/Linux)

Makefile — единый набор команд для тебя и для агента, одинаковый локально и в CI.

### `Makefile` (база, общая для всех Python-проектов)

```makefile
# подставь свой менеджер пакетов: uv run / poetry run / python -m
RUN := uv run

.PHONY: lint fmt type test sec all
lint:  ; $(RUN) ruff check .
fmt:   ; $(RUN) ruff format . && $(RUN) ruff check --fix .
type:  ; $(RUN) mypy .
test:  ; $(RUN) pytest -q
sec:   ; $(RUN) bandit -q -r . -c pyproject.toml && $(RUN) pip-audit
all: lint type test sec
```

> Батч-гейты CI: `make type` (типы), `make sec` (bandit + pip-audit). В сессии их дополняют
> `pyright-lsp` (типы по мере правок) и `/code-review` + `/security-review` (ревью диффа) —
> см. DoD в [policy-and-docs.md](policy-and-docs.md).

## Цели под класс проекта

Добавляй к базе только то, что соответствует проекту.

### Django (веб)
```makefile
mk:      ; $(RUN) python manage.py makemigrations --check --dry-run   # CI: упасть, если миграция забыта
migrate: ; $(RUN) python manage.py migrate
run:     ; $(RUN) python manage.py runserver
# test переопредели на pytest -q (с pytest-django) или python manage.py test
```
Перед `migrate` на проде — навык `migration-safety-auditor`.

### FastAPI (API)
```makefile
run:      ; $(RUN) uvicorn app.main:app --reload
migrate:  ; $(RUN) alembic upgrade head
revision: ; $(RUN) alembic revision --autogenerate -m "$(m)"   # autogenerate ВСЕГДА ревьюить
```

### aiogram (бот)
Бота нет смысла «сёрвить» как HTTP — это polling-воркер. Цель запуска и юнит для деплоя:
```makefile
run-bot: ; $(RUN) python -m bot
```
Тесты — на хендлеры/FSM (pytest + aiogram test utils), линт/тип/sec — те же. У бота свой
жизненный цикл: graceful shutdown, idempotent-обработка апдейтов, RedisStorage для FSM.

### Automation-скрипт
Часто без «run»-сервиса: достаточно `lint/type/test/sec` + цель запуска самого скрипта и
заметка про cron/systemd-timer.

## CI — GitHub Actions

Без docker-build по умолчанию. На ubuntu-runner `make` предустановлен:

```yaml
name: ci
on:
  push: { branches: [main, master] }
  pull_request: { branches: [main, master] }
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v5            # или actions/setup-python + pip
      - run: uv sync --all-extras --dev
      - run: make all
```

Для Django добавь сервис postgres (`services: postgres:`) и шаг `make mk` (проверка забытых
миграций). Для FastAPI с Alembic — шаг `make migrate` на тестовой БД.

## Деплой — ориентир systemd/nginx (не Docker)

Не навязывай docker-build. Типовой деплой: gunicorn/uvicorn (или бот-воркер) под systemd за
nginx, redis как broker/cache/FSM-storage, postgres. Деплой-заметку в репозитории держи
короткой (юнит-файл, `systemctl restart`, где конфиг nginx). Подробный деплой-навык — отдельно.
