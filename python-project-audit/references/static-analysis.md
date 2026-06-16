# Автоматический статический анализ — инструменты и команды

Шесть «испытаний» статического анализа. Установка пакетов — **только с согласия
пользователя**. Никогда не используй `pip install --break-system-packages`.

## Способы запуска (без загрязнения системного Python)

- `uvx <tool> ...` — запуск без установки (рекомендуется, если есть `uv`).
- `pipx run <tool> ...` — аналогично через pipx.
- В venv проекта: активируй `.venv` и `pip install <tool>` внутри неё.

Ниже команды даны для PowerShell (Windows) и в cross-platform виде через `uvx`.

## Испытание 1: Качество кода (pylint)

```powershell
# через uvx, без установки
uvx pylint --disable=C0114,C0115,C0116 --output-format=json (Get-ChildItem -Recurse -Filter *.py -Exclude venv,.venv | Select-Object -First 30 -ExpandProperty FullName) > pylint.json
```

Оценка: чем больше `error`/`fatal` и `warning`, тем ниже балл. Ориентир:
score = 10 − (errors·2 + warnings·0.5 + conventions·0.1), но не ниже 0.
Прочитай `pylint.json` инструментом Read и просуммируй по полю `type`.

## Испытание 2: Безопасность (bandit)

```powershell
uvx bandit -r . -f json --exclude "*/test*,*/venv/*,*/.venv/*" > bandit.json
```

Разбери `results`: считай `issue_severity` HIGH / MEDIUM / LOW.
Для каждой HIGH-находки укажи `issue_text`, `filename`, `line_number`.

## Испытание 3: Типизация (mypy)

```powershell
uvx mypy . --ignore-missing-imports --no-error-summary
```

Зафиксируй количество ошибок типизации и наиболее частые категории.

## Испытание 4: Сложность кода (radon)

```powershell
# Цикломатическая сложность (средняя, только B и хуже)
uvx radon cc . -a -nb --exclude "venv,.venv"
# Индекс поддерживаемости
uvx radon mi . -nb --exclude "venv,.venv"
```

Отметь функции/модули с рангом C и ниже — кандидаты на рефакторинг.

## Испытание 5: Мёртвый код (vulture)

```powershell
uvx vulture . --exclude "venv,.venv" --min-confidence 80
```

Список неиспользуемых функций/переменных/импортов (confidence ≥ 80%).

## Испытание 6: Уязвимые зависимости (safety)

```powershell
uvx safety check -r requirements.txt
```

Если `requirements.txt` нет — попробуй `pip-audit` (`uvx pip-audit`) либо
отметь в отчёте, что проверка зависимостей не выполнена.

## Покрытие тестами (для Испытания 5 ручного review)

Покрытие требует запуска тестов и часто БД — на статическом аудите это
опционально и только с согласия пользователя. Если согласие есть:

```powershell
uvx --with pytest-cov pytest --cov=. --cov-report=term-missing -q
```

Иначе оцени покрытие косвенно: соотношение test-файлов к модулям,
наличие тестов для критичных путей. Подробнее — навык test-coverage-auditor.
