# ROADMAP — недостающие навыки

Живой документ: кандидаты в новые навыки для полного покрытия потребностей соло-Python-разработчика
(Django / FastAPI / aiogram; dev на Windows, прод на Linux VPS без Docker).
Основание — gap-анализ [аудита 2026-07](docs/skills-audit-2026-07.md). Пополняется по мере появления потребностей.

## Карта жизненного цикла и покрытие

| Этап | Чем закрыт | Пробел |
|---|---|---|
| Идея / исследование | deep-research, fact-checker, alphaxiv-paper-lookup, obsidian | — |
| Спека / план | spec-writer, clarify-prompt | — |
| Разработка | feature-dev (офиц.), fastapi-architect, codebase-express, goal-pipeline, ratchet-loop, ralph-loop (офиц.) | — |
| Написание тестов | **test-writer** (с 2026-07), test-coverage-auditor (аудит) | — |
| Ревью | /code-review, techlead-ai, claude-code-auditor | — |
| Безопасность | /security-review, django-audit (security), dependency-auditor | — |
| БД: миграции | migration-safety-auditor | — |
| БД: производительность | **postgres-performance** (с 2026-07), django-audit (N+1) | — |
| Деплой | vps-deploy-auditor, harness-engineering (CI) | — |
| Эксплуатация: наблюдаемость | **observability-bootstrap** (с 2026-07) | — |
| Эксплуатация: инциденты | **vps-incident-triage** (с 2026-07), 500-error-eliminator (Django 500) | — |
| Релизы | **release-manager** (с 2026-07), git-commit-planner (коммиты) | — |
| Документация | docs-generator, spec-writer | — |
| SEO / продвижение | advanced-seo-optimizer, google-discover-optimize | — |
| База знаний | obsidian | — |
| Среда разработки | windows-pwsh-terminal, harness-engineering | — |

## Реализовано

- **2026-07-02** — `test-writer`, `observability-bootstrap`, `postgres-performance`,
  `vps-incident-triage`, `release-manager` (закрыты все HIGH и MEDIUM кандидаты
  первоначального gap-анализа; библиотека выросла с 28 до 33 навыков).

## Кандидаты

### LOW

#### `python-profiling`
Методика профилирования: py-spy/cProfile для CPU, django-debug-toolbar/silk для запросов, memray для памяти;
как получить метрику-скаляр для ratchet-loop. Синергия: ratchet-loop требует измеримую метрику — этот навык её добывает.

#### `http-client-reliability`
Надёжные исходящие HTTP-вызовы (httpx/requests): таймауты по умолчанию, ретраи с джиттером, идемпотентность,
circuit breaker, обработка rate limit внешних API. Сейчас частично размазано по aiogram/fastapi навыкам.

## Отклонено (пока)

- **docker-навыки** — прод сознательно без Docker.
- **frontend/HTMX** — закрывается frontend-design (офиц.) + django-tailwind-optimizer; отдельный навык — если HTMX станет постоянным стеком.
- **billing/платёжные интеграции** — слишком проектно-специфично для переиспользуемого навыка; заводить при реальной задаче.
