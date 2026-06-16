# Детальные чеклисты SEO-аудита

## 1. HTML5-семантика и заголовки
- Ровно один `<h1>` с primary keyword, совпадает с `<title>`.
- Заголовки по порядку H1→H2→H3 без пропуска уровней.
- nav/breadcrumbs/footer не используют `<hN>`.
- Лендмарки: `<header>`, `<nav aria-label="...">`, `<main>` (один), `<article>`, `<section>`, `<aside>`, `<footer>`; нет `<div class="header">` вместо тегов.
- `<title>` 50–60 символов, формат `Primary Keyword - Brand`, уникален.

Alt-тексты:
| Случай | alt |
|--------|-----|
| Информативное | Краткое описание + ключевое слово |
| Декоративное | `alt=""` (пустой, не отсутствующий) |
| Ссылочное | Описание цели ссылки |
| Текст на картинке | Воспроизвести текст |

## 2. Meta / OG / Twitter / canonical
- Meta description 120–160 символов, уникальный, с CTA; авто-фоллбэк из модели/первых ~155 символов.
- Canonical: всегда абсолютный URL, self-canonical на каждой странице; HTTP `Link: rel="canonical"` как фоллбэк.

Open Graph:
```html
<meta property="og:title" content="...">
<meta property="og:description" content="120-300 chars">
<meta property="og:image" content="https://example.com/img/og.jpg">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta property="og:url" content="https://example.com/page/">
<meta property="og:type" content="website">
<meta property="og:site_name" content="Brand Name">
<meta property="og:locale" content="ru_RU">
```
OG image: >=1200×630, < 1 MB, JPEG предпочтительно.

Twitter Card:
```html
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:site" content="@handle">
<meta name="twitter:title" content="...">
<meta name="twitter:description" content="max 200 chars">
<meta name="twitter:image" content="https://example.com/img/twitter.jpg">
<meta name="twitter:image:alt" content="...">
```

## 4. Индексация
robots.txt: существует (200, не 404/редирект); блок `User-agent: *`; нет случайного `Disallow: /`;
статика не заблокирована; объявлен `Sitemap:`; staging имеет `Disallow: /`.

sitemap.xml: по `/sitemap.xml` или объявлен в robots; `Content-Type: application/xml`;
все публичные индексируемые URL; нет 4xx/5xx и заблокированных в robots; реальный `<lastmod>`;
абсолютные `<loc>`; < 50 MB и < 50 000 URL (иначе разбить на индекс).

noindex/nofollow:
| Случай | Тег |
|--------|-----|
| Thin/дубликат | `noindex,follow` |
| Закрытая страница | `noindex,nofollow` + серверная авторизация |
| Страница поиска | `noindex,follow` |
| Страница "Спасибо" | `noindex,nofollow` |

## 6. Перелинковка / хлебные крошки / пагинация
- Каждая индексируемая страница <=3 клика от главной; описательные анкоры (не «нажмите здесь»).
- Нет битых ссылок; используется `<a href>` (не JS-only); важные внутренние страницы без `rel="nofollow"`.
- Breadcrumbs на всех страницах кроме Home; совпадают с BreadcrumbList JSON-LD; в `<nav aria-label="Breadcrumb">`; Home первый, текущая последняя без ссылки.
- Пагинация: **self-canonical на каждой странице** (НЕ canonical на page=1).

> Устаревшее: `<link rel="prev"/"next">` для пагинации Google официально **не использует с 2019 года**.
> Не рекомендуй их как фактор SEO. Для UX/доступности они допустимы, но это не влияет на индексирование.
> Для больших списков рассмотри подгрузку/«показать все» или внятную пагинацию с уникальными title/description.

## 7. Core Web Vitals
- **LCP <= 2.5s**: hero `fetchpriority="high"` + `<link rel="preload" as="image">`; серверный кэш; нет render-blocking ресурсов выше fold.
- **CLS < 0.1**: явные `width`/`height` у `<img>`/`<video>`; резерв места под рекламу/эмбеды/lazy; `font-display: swap`.
- **INP <= 200ms**: нет long tasks (>50ms) в обработчиках; defer некритичного JS; `requestIdleCallback` для аналитики; DOM < 1500 узлов. (INP заменил FID в наборе Core Web Vitals с марта 2024 — FID больше не используется.)
- **TTFB <= 800ms**: `cache_page` на тяжёлых views; `select_related`/`prefetch_related`; Redis-кэш; CDN/WhiteNoise для статики.
- Изображения: WebP/AVIF с фоллбэком через `<picture>`; `srcset`/`sizes`; `loading="lazy"` ниже fold; < 150 KB для контентных.
- CSS/JS: critical CSS инлайн (< 14 KB); некритичный CSS через `preload`+`onload`; сторонние скрипты `async`/`defer`.
