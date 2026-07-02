# Аудит библиотеки навыков llm-skills

**Дата:** 2026-07-02
**Объект:** 28 навыков репозитория `goldenprofile/llm-skills`, манифесты плагина, README.
**Метод:** инвентаризация фронтматтера (замер длины `description` в символах), карта заголовков всех SKILL.md, выборочное чтение тел (django-tailwind-optimizer — полностью; clarify-prompt — полностью; крупные навыки — по структуре), сверка с критериями skill-creator (официальный плагин Anthropic) и манифестов с фактическим составом репо.

**Критерии** (источник — skill-creator, `claude-plugins-official`):
- Метаданные (name + description) сидят в контексте **каждой** сессии; ориентир — ~100 слов на описание.
- Тело SKILL.md — в контексте при срабатывании; идеал < 500 строк, тяжёлое — в `references/` (progressive disclosure).
- `description` — что делает + когда использовать (триггеры); лимит валидации Anthropic — 1024 символа, `name` — 64 символа. *Пометка: Claude Code сейчас загружает и более длинные описания; лимит подтверждён документацией API/claude.ai — «требует проверки» при следующем обновлении доки.*

---

## Сводка

| Показатель | Значение |
|---|---|
| Навыков | 28 (совпадает с бейджем README и манифестами) |
| `name` = имя папки | 28/28 ✓ |
| Описание содержит триггеры «когда использовать» | 28/28 ✓ |
| **Описаний длиннее 1024 символов** | **16/28 ✗** |
| Суммарный объём всех описаний | ~31 000 символов ≈ 15–18 тыс. токенов **в каждой сессии** |
| Тел SKILL.md > 500 строк | 0/28 ✓ (максимум — spec-writer, 413) |
| Устаревшее содержание | 1 (django-tailwind-optimizer — Tailwind v3 при v4-актуальности) |
| Структурные отклонения | REFERENCE.md вместо `references/` (2), пример вне `references/` (1) |
| Evals (`evals/evals.json`) | 0/28 — ни у одного навыка |

## Находки уровня библиотеки

### A1. 16 описаний превышают лимит 1024 символа — HIGH

Замер (символов, после нормализации переносов):

| Навык | Длина | Навык | Длина |
|---|---|---|---|
| goal-pipeline | **1980** | migration-safety-auditor | **1141** |
| python-project-audit | **1885** | agent-audit | **1081** |
| ratchet-loop | **1873** | harness-engineering | **1062** |
| spec-writer | **1544** | techlead-ai | **1056** |
| fastapi-architect | **1452** | obsidian | **1035** |
| claude-code-auditor | **1399** | clarify-prompt | **1028** |
| vps-deploy-auditor | **1315** | aiogram-bot-auditor | 1013 ✓ |
| django-audit | **1292** | google-discover-optimize | 978 ✓ |
| docs-generator | **1261** | advanced-seo-optimizer | 935 ✓ |
| dependency-auditor | **1216** | session-catchup | 931 ✓ |

Остальные 8 (codebase-express 871, code-archaeologist 840, windows-pwsh-terminal 820, 500-error-eliminator 757, fact-checker 719, django-tailwind-optimizer 621, git-commit-planner 609, test-coverage-auditor 575) — в норме.

Последствия: (1) вне спеки Anthropic — при ужесточении валидации Claude Code или установке через claude.ai/API навыки отклонятся; (2) постоянный токен-налог: ~15–18 тыс. токенов метаданных грузятся в каждую сессию, включая сессии, где ни один навык не нужен. Кириллица усиливает эффект (~1 токен на 1.5–2 символа против ~4 для латиницы).

### A2. Сверхширокий триггер agent-audit — HIGH

Описание agent-audit триггерится на голое слово «аудит» — при 7+ навыках-аудиторах в библиотеке (django-audit, python-project-audit, dependency-auditor, migration-safety-auditor, aiogram-bot-auditor, vps-deploy-auditor, test-coverage-auditor) это прямой конфликт: «сделай аудит проекта» может увести в самоаудит агента вместо аудита кода.

### A3. django-tailwind-optimizer устарел и внутренне сломан — HIGH

Навык учит workflow Tailwind **v3** (`tailwind.config.js` с `module.exports`, директивы `@tailwind base/components/utilities`), но команда установки качает `releases/latest/download/...` — то есть бинарь **v4**, который этот конфиг не обработает (v4 перешёл на CSS-first: `@import "tailwindcss"`, `@theme`, конфиг-файл опционален). Пользователь, следующий инструкции, получит неработающую сборку. Единственный содержательно сломанный навык из проверенных.

### A4. README отстал от репозитория — MEDIUM

- Дерево «Структура репозитория» не содержит `ratchet-loop/` (27 папок при 28 навыках в каталоге и бейдже) и `.claude-plugin/`.
- Установка описана только копированием папок; установка как плагина (`/plugin marketplace add goldenprofile/llm-skills`) не упомянута, хотя `.claude-plugin/plugin.json` и `marketplace.json` существуют и рабочие.

### A5. Структурная разнородность — MEDIUM

- `session-catchup/REFERENCE.md` и `windows-pwsh-terminal/REFERENCE.md` — вместо стандартной папки `references/`.
- `ratchet-loop/contract-example.md` лежит в корне навыка, а не в `references/`.
- Имена справочников выходного формата разнобойные: `output-format.md` (5 навыков), `report-template.md` (3), `report-format.md` (1).

### A6. Три тяжеловеса тела — MEDIUM

goal-pipeline (30.3 КБ, 390 строк), ratchet-loop (24.7 КБ, 317), spec-writer (22.5 КБ, 413). Формально в лимите 500 строк, но в токенах (кириллица) это ~8–12 тыс. на срабатывание. У goal-pipeline и ratchet-loop выносимы протокол исполнителя, маркеры транскрипта и «Память (Windows)»; у spec-writer — три полных шаблона (примеры уже в `references/`).

### A7. Мелкое — LOW

- Смешение EN/RU заголовков в старых навыках (500-error-eliminator: «Quick Start», «Prevention Checklist» рядом с русскими).
- `plugin.json` версия 1.0.0 не бампается при изменениях навыков (harness-engineering уже 1.3.0) — кэш маркетплейса не увидит обновлений.
- test-coverage-auditor не разграничен с линзой tests django-audit (односторонняя коллизия).
- Ни у одного навыка нет evals — спорные пары триггеров нечем проверить эмпирически.

---

## Таблица по навыкам

Состояние: **OK** — трогать не нужно; **правки** — точечные исправления; **переработка** — существенное обновление.
Длина = описание в символах; строки = тело SKILL.md.

| # | Навык | Строки | Длина desc | Состояние | Находки | Приоритет |
|---|---|---|---|---|---|---|
| 1 | 500-error-eliminator | 201 | 757 | правки | смешение EN/RU заголовков; нет перекрёстных ссылок (на vps-deploy-auditor при инфраструктурных 500) | low |
| 2 | advanced-seo-optimizer | 83 | 935 | OK | образцовая структура; desc близко к лимиту — при правках не раздувать | — |
| 3 | agent-audit | 236 | 1081 | правки | desc > лимита; **триггер «аудит» конфликтует со всем семейством аудиторов**; шаблон отчёта инлайн — кандидат в references | **high** |
| 4 | aiogram-bot-auditor | 86 | 1013 | OK | образец «семейства аудиторов» (Когда применять → Контекст → Процесс → Уровни риска → Чеклист → Связь → Справочники) | — |
| 5 | clarify-prompt | 104 | 1028 | правки | desc чуть > лимита (−4 слова достаточно) | low |
| 6 | claude-code-auditor | 154 | 1399 | правки | desc > лимита; зависимость от внешнего CLI `hermes` — убедиться, что описан graceful-отказ при его отсутствии | medium |
| 7 | code-archaeologist | 158 | 840 | OK | разграничение с codebase-express взаимное и чёткое | — |
| 8 | codebase-express | 188 | 871 | OK | без references, но компактен и самодостаточен | — |
| 9 | dependency-auditor | 89 | 1216 | правки | desc > лимита; тело образцовое | medium |
| 10 | django-audit | 115 | 1292 | правки | desc > лимита; добавить разграничение линзы tests ↔ test-coverage-auditor | medium |
| 11 | django-tailwind-optimizer | 264 | 621 | **переработка** | **Tailwind v3 workflow + установка latest (v4) = сломанная инструкция**; нет references при 264 строках | **high** |
| 12 | docs-generator | 89 | 1261 | правки | desc > лимита; тело образцовое | medium |
| 13 | fact-checker | 132 | 719 | OK | — | — |
| 14 | fastapi-architect | 99 | 1452 | правки | desc > лимита (перечисляет полсодержания тела); тело образцовое | medium |
| 15 | git-commit-planner | 188 | 609 | OK | опционально: разграничить с личным навыком commit-push (вне этого репо) | low |
| 16 | goal-pipeline | 390 | **1980** | правки | рекордный desc — ×2 лимита; тело 30 КБ: протокол исполнителя, маркеры, «Память (Windows)» — в references | **high** |
| 17 | google-discover-optimize | 93 | 978 | OK | desc близко к лимиту | — |
| 18 | harness-engineering | 166 | 1062 | правки | desc > лимита; v1.3.0 — единственный с живой версией | medium |
| 19 | migration-safety-auditor | 84 | 1141 | правки | desc > лимита; тело образцовое | medium |
| 20 | obsidian | 157 | 1035 | правки | desc чуть > лимита; 10 references + 2 шаблона — правильная структура | low |
| 21 | python-project-audit | 122 | 1885 | правки | desc ×1.8 лимита; триггеры «найди баги», «проверь безопасность проекта» пересекаются с /security-review и django-audit — сузить | **high** |
| 22 | ratchet-loop | 317 | 1873 | правки | desc ×1.8 лимита; `contract-example.md` в корень `references/`; тело 25 КБ — частично выносимо | **high** |
| 23 | session-catchup | 102 | 931 | правки | `REFERENCE.md` → `references/` | low |
| 24 | spec-writer | 413 | 1544 | правки | desc > лимита; крупнейшее тело — 3 инлайн-шаблона выносимы (примеры уже в references) | medium |
| 25 | techlead-ai | 138 | 1056 | правки | desc чуть > лимита | low |
| 26 | test-coverage-auditor | 153 | 575 | правки | добавить разграничение с django-audit (линза tests) | low |
| 27 | vps-deploy-auditor | 97 | 1315 | правки | desc > лимита; тело образцовое | medium |
| 28 | windows-pwsh-terminal | 48 | 820 | правки | `REFERENCE.md` → `references/`; в остальном образец компактности | low |

**Итог:** OK — 7, правки — 20, переработка — 1.

## Положительные моменты

- «Семейство аудиторов» (aiogram-bot-auditor, dependency-auditor, fastapi-architect, vps-deploy-auditor, migration-safety-auditor, docs-generator) имеет единый выверенный скелет — лучший образец для унификации остальных.
- Взаимные анти-коллизионные указатели («для X — см. Y») уже присутствуют в большинстве смежных пар — практика, которую Anthropic не даёт из коробки.
- Прогрессивное раскрытие реально используется: 79 справочных файлов, тела в основном компактны.
- Манифесты плагина валидны, состав совпадает с фактическим (28/28), кэш синхронен с репо.
