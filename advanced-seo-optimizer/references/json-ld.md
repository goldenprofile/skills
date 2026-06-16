# Эталонные JSON-LD шаблоны

Правила: JSON-LD в `<script type="application/ld+json">` в `<head>`; несколько схем —
отдельные блоки или массив `[{...}, {...}]`; `@context: "https://schema.org"`; все
обязательные свойства по spec; валидация — Google Rich Results Test и Schema.org Validator.

Обязательные схемы по типу страницы:

| Тип | Схемы |
|-----|-------|
| Home | Organization, WebSite (SearchAction) |
| Category | BreadcrumbList, ItemList |
| Product | Product (Offer, AggregateRating), BreadcrumbList |
| Article | Article/NewsArticle/BlogPosting, BreadcrumbList, Person/Organization |
| Any | WebPage (рекомендуется) |

## Organization (Home)
```json
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "Brand Name",
  "url": "https://example.com/",
  "logo": {"@type": "ImageObject", "url": "https://example.com/logo.png", "width": 200, "height": 60},
  "contactPoint": {"@type": "ContactPoint", "telephone": "+7-000-000-0000", "contactType": "customer service"},
  "sameAs": ["https://vk.com/brand", "https://t.me/brand"]
}
```

## WebSite + SearchAction (Home)
```json
{
  "@context": "https://schema.org",
  "@type": "WebSite",
  "name": "Brand Name",
  "url": "https://example.com/",
  "potentialAction": {
    "@type": "SearchAction",
    "target": {"@type": "EntryPoint", "urlTemplate": "https://example.com/search/?q={search_term_string}"},
    "query-input": "required name=search_term_string"
  }
}
```

## BreadcrumbList
```json
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": [
    {"@type": "ListItem", "position": 1, "name": "Home", "item": "https://example.com/"},
    {"@type": "ListItem", "position": 2, "name": "Category", "item": "https://example.com/cat/"},
    {"@type": "ListItem", "position": 3, "name": "Page Title"}
  ]
}
```
Последний элемент (текущая страница) может быть без `"item"`.

## Product
```json
{
  "@context": "https://schema.org",
  "@type": "Product",
  "name": "Product Name",
  "image": ["https://example.com/img/product.jpg"],
  "description": "Product description.",
  "sku": "SKU-001",
  "brand": {"@type": "Brand", "name": "Brand"},
  "offers": {
    "@type": "Offer",
    "url": "https://example.com/product/",
    "priceCurrency": "RUB",
    "price": "1299.00",
    "priceValidUntil": "<дата на год вперёд от текущей>",
    "itemCondition": "https://schema.org/NewCondition",
    "availability": "https://schema.org/InStock"
  },
  "aggregateRating": {"@type": "AggregateRating", "ratingValue": "4.5", "reviewCount": "12"}
}
```
`priceValidUntil` — рассчитывай динамически (например, +1 год), не хардкодь фиксированную дату.

## Article / NewsArticle / BlogPosting
```json
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "Article Title (max 110 chars)",
  "image": ["https://example.com/img/article.jpg"],
  "author": {"@type": "Person", "name": "Author Name"},
  "publisher": {
    "@type": "Organization",
    "name": "Brand Name",
    "logo": {"@type": "ImageObject", "url": "https://example.com/logo.png"}
  },
  "datePublished": "<ISO 8601 с таймзоной>",
  "dateModified": "<ISO 8601 с таймзоной>",
  "mainEntityOfPage": {"@type": "WebPage", "@id": "https://example.com/article/"}
}
```
Даты — реальные значения из модели (`published_at`/`updated_at`), формат ISO 8601 с таймзоной.

## FAQPage
```json
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {"@type": "Question", "name": "Question text?", "acceptedAnswer": {"@type": "Answer", "text": "Answer text."}}
  ]
}
```

## ItemList (Category/Listing)
```json
{
  "@context": "https://schema.org",
  "@type": "ItemList",
  "name": "Category Name",
  "itemListElement": [
    {"@type": "ListItem", "position": 1, "url": "https://example.com/item-1/"},
    {"@type": "ListItem", "position": 2, "url": "https://example.com/item-2/"}
  ]
}
```
