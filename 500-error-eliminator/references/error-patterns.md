# Каталог типовых паттернов Django 500 + workflow по типам

Справочник распространённых причин 500 с примерами «было/стало» и пошаговыми
процедурами под каждый тип ошибки. Открывай нужный паттерн по типу исключения из traceback.

## Pattern 1: Необработанный None
Признак: `AttributeError: 'NoneType' object has no attribute 'something'`
```python
# Плохо — не проверяется результат get()
domain = Domain.objects.filter(name=name).first()
return domain.name                      # упадёт, если domain is None

# Хорошо — защитная проверка
domain = Domain.objects.filter(name=name).first()
if not domain:
    return None                         # или raise Http404, или дефолт
return domain.name
```

## Pattern 2: Ошибка импорта
Признак: `ImportError: cannot import name 'SomeClass' from 'apps.module'`
Причины: опечатка в имени; циклический импорт; файл не существует; класс определён после импорта.
Диагностика:
1. Прочитай файл-источник → существует ли класс.
2. Прочитай оба файла (откуда и куда) → ищи взаимные импорты.
3. Циклический импорт → перенеси импорт внутрь функции или отрефактори.

## Pattern 3: Template-ошибки
Признак: `TemplateSyntaxError: Invalid block tag on line X`
```django
{% endfi %}                 {# опечатка — должно быть endif #}
{% static 'file.css' %}     {# нужен {% load static %} сначала #}
```
Исправление: проверь написание всех тегов; загрузи нужные через `{% load %}`;
используй `{% if %}` для проверки существования атрибутов перед использованием.

## Pattern 4: Middleware-ошибки
Признак: traceback содержит файл middleware проекта или строку с `middleware`.
Проверь:
- порядок middleware в settings (некоторые должны быть первыми);
- возвращает ли middleware response / вызывает `get_response()`;
- нет ли необработанных исключений в middleware.

## Pattern 5: KeyError во view
Признак: `KeyError: 'some_key'`
```python
value = request.POST['field_name']           # упадёт, если поля нет
value = request.POST.get('field_name', '')   # безопасно
```

---

# Workflow по типам ошибок

## Type A: View Logic Error
1. По traceback найди view-функцию; прочитай её целиком.
2. Найди строку ошибки; проверь все переменные: могут ли быть None? неправильного типа? проверены ли границы?
3. Исправь: проверки на None, try/except где нужно, валидация входных данных.

## Type B: Template Error
1. Найди в traceback имя файла шаблона; прочитай его целиком.
2. Проверь: все `{% load %}` на месте? у `{% if %}`/`{% for %}` есть закрытия? нет опечаток в тегах?
3. Если ошибка доступа к атрибуту: прочитай view, рендерящий шаблон → передаётся ли переменная в context? существует ли атрибут модели?

## Type C: Configuration Error
1. По traceback определи источник: settings (типично `config/settings.py` или `<project>/settings.py`), urls (`config/urls.py` или urls приложения), middleware проекта. Точные пути уточни по структуре проекта.
2. Проверь: опечатки в `INSTALLED_APPS`/`MIDDLEWARE`? все пути существуют? импорты корректны?
3. Особое внимание: порядок `MIDDLEWARE`; зависимости в `INSTALLED_APPS` выше зависимых; `TEMPLATES['DIRS']` существуют.
