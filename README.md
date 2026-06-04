# Adobe Commerce Optimizer – Categories API

Postman collection for creating and managing categories via the **Adobe Commerce Optimizer Data Ingestion REST API**.

---

## Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Import into Postman](#import-into-postman)
- [Configuration](#configuration)
- [Authentication](#authentication)
- [Requests](#requests)
  - [0. Get Access Token](#0-get-access-token)
  - [1. Create Root Category](#1-create-root-category)
  - [2. Create Child Category (Level 2)](#2-create-child-category-level-2)
  - [3. Create Grandchild Category (Level 3)](#3-create-grandchild-category-level-3)
  - [4. Batch Create Multiple Categories](#4-batch-create-multiple-categories)
  - [5. Create Seasonal Family Categories](#5-create-seasonal-family-categories)
  - [6. Create Category with Full Rich Content](#6-create-category-with-full-rich-content)
  - [7. Assign Product to Categories](#7-assign-product-to-categories)
- [Key Concepts](#key-concepts)
- [API Response Reference](#api-response-reference)
- [Rate Limits](#rate-limits)
- [References](#references)

---

## Overview

This collection covers the full category ingestion workflow for **Adobe Commerce Optimizer** (SaaS / composable catalog). Categories are created via the Data Ingestion REST API and then queryable on the storefront through the Merchandising GraphQL API (`navigation`, `categoryTree`, `searchCategory` queries).

**Base URL pattern:**
```
https://{region}-{environment}.api.commerce.adobe.com/{tenantId}/v1/catalog/categories
```

---

## Prerequisites

| Requirement | Where to get it |
|---|---|
| Adobe Commerce Optimizer instance | [Adobe Experience Cloud](https://experience.adobe.com/) → Commerce Cloud Manager |
| Tenant ID (Instance ID) | Cloud Manager → Instance Details |
| API credentials (Client ID + Secret) | [Adobe Developer Console](https://developer.adobe.com/console) → Your Project |
| REST base URL | Cloud Manager → Instance Details |

---

## Import into Postman

1. Download `Adobe_Commerce_Categories_API.postman_collection.json`
2. Open Postman
3. Click **File → Import** (or drag the file into the Postman window)
4. The collection appears in your sidebar under **Collections**

---

## Configuration

After importing, open the collection and go to the **Variables** tab. Fill in the following before running any request:

| Variable | Description | Example |
|---|---|---|
| `tenantId` | Unique identifier for your Commerce Optimizer instance | `abc123xyz` |
| `clientId` | OAuth client ID from Adobe Developer Console | `abc123...` |
| `clientSecret` | OAuth client secret from Adobe Developer Console | `p8e-xyz...` |
| `region` | Cloud region of your instance | `na1` |
| `environment` | `sandbox` for non-production; leave empty for production | `sandbox` |
| `accessToken` | Populated automatically by request 0 — do not edit manually | _(auto-set)_ |

> **Sandbox note:** Sandbox instances are only available in the North America (`na1`) region.

---

## Authentication

This collection uses **Adobe IMS OAuth 2.0 client credentials** flow.

Run **request 0** before any other request. A Postman Test script automatically extracts the token from the response and saves it as `{{accessToken}}` on the collection, so all subsequent requests are authorized without any manual copy-paste.

The token is scoped to:
```
openid, AdobeID, email, additional_info.projectedProductContext,
profile, commerce.aco.ingestion, commerce.accs, org.read, additional_info.roles
```

IMS tokens expire after **24 hours**. Re-run request 0 to refresh.

---

## Requests

### 0. Get Access Token

**POST** `https://ims-na1.adobelogin.com/ims/token/v3`

Exchanges your client credentials for a Bearer token. The token is saved automatically to `{{accessToken}}` via a Postman Test script and prepended with `Bearer ` — no manual steps needed.

---

### 1. Create Root Category

**POST** `.../v1/catalog/categories`

Creates a single top-level (level 1) category with no parent.

```json
[
  {
    "slug": "men",
    "name": "Men",
    "family": "main-catalog",
    "parentSlug": "",
    "level": 1,
    "description": "All mens clothing and accessories",
    "metaTags": {
      "title": "Men | My Store",
      "description": "Shop mens clothing, shoes, and accessories",
      "keywords": ["mens", "clothing", "fashion"]
    },
    "images": [
      {
        "url": "https://example.com/images/men-banner.jpg",
        "label": "Men category banner",
        "roles": ["BASE", "THUMBNAIL"]
      }
    ]
  }
]
```

> `parentSlug` must be an empty string `""` for root categories.

---

### 2. Create Child Category (Level 2)

**POST** `.../v1/catalog/categories`

Creates a level 2 category nested under an existing root. The `parentSlug` must match the `slug` of an already-ingested parent.

```json
[
  {
    "slug": "men/clothing",
    "name": "Men's Clothing",
    "family": "main-catalog",
    "parentSlug": "men",
    "level": 2,
    "description": "Tops, bottoms, and outerwear for men"
  }
]
```

---

### 3. Create Grandchild Category (Level 3)

**POST** `.../v1/catalog/categories`

Creates a level 3 leaf category. Images and `metaTags` are optional at this depth — omit them for lightweight leaf nodes.

```json
[
  {
    "slug": "men/clothing/tops",
    "name": "Men's Tops",
    "family": "main-catalog",
    "parentSlug": "men/clothing",
    "level": 3,
    "description": "T-shirts, polos, and dress shirts"
  }
]
```

---

### 4. Batch Create Multiple Categories

**POST** `.../v1/catalog/categories`

Sends multiple categories in a single request. The array can span different levels — the API processes them all together. This is the most efficient approach when seeding a new catalog hierarchy.

```json
[
  { "slug": "women",                 "level": 1, "parentSlug": "" },
  { "slug": "women/clothing",        "level": 2, "parentSlug": "women" },
  { "slug": "women/clothing/tops",   "level": 3, "parentSlug": "women/clothing" },
  { "slug": "women/clothing/bottoms","level": 3, "parentSlug": "women/clothing" }
]
```

**Successful response:**
```json
{ "status": "ACCEPTED", "acceptedCount": 4 }
```

---

### 5. Create Seasonal Family Categories

**POST** `.../v1/catalog/categories`

Creates categories under a separate `family` namespace. Use distinct family names when your catalog has multiple independent category trees — for example `main-catalog` for primary navigation and `seasonal` for campaign-specific hierarchies. The `family` value is passed as a header when querying via the Merchandising GraphQL API.

```json
[
  { "slug": "summer",            "family": "seasonal", "level": 1, "parentSlug": "" },
  { "slug": "summer/essentials", "family": "seasonal", "level": 2, "parentSlug": "summer" }
]
```

---

### 6. Create Category with Full Rich Content

**POST** `.../v1/catalog/categories`

Creates a category with the complete set of optional fields: `description`, SEO `metaTags`, multiple `images` with standard and custom roles. Use this shape for category landing pages that need hero imagery and search engine metadata.

```json
[
  {
    "slug": "men/clothing/shorts",
    "name": "Men's Shorts",
    "family": "main-catalog",
    "parentSlug": "men/clothing",
    "level": 3,
    "description": "Browse our full range of men's shorts, from casual to athletic styles.",
    "metaTags": {
      "title": "Men's Shorts | My Store",
      "description": "Shop men's shorts for every occasion",
      "keywords": ["shorts", "men", "athletic", "casual"]
    },
    "images": [
      {
        "url": "https://example.com/images/mens-shorts-hero.jpg",
        "label": "Men's shorts collection hero",
        "roles": ["BASE"],
        "customRoles": ["hero-banner"]
      },
      {
        "url": "https://example.com/images/mens-shorts-thumb.jpg",
        "label": "Men's shorts thumbnail",
        "roles": ["THUMBNAIL"]
      }
    ]
  }
]
```

---

### 7. Assign Product to Categories

**POST** `.../v1/catalog/products`

Links an existing product to one or more categories by referencing their `slug` values in the `categories` array. A product can belong to multiple categories across different families simultaneously.

```json
[
  {
    "sku": "my-product-sku-001",
    "source": { "locale": "en-US" },
    "name": "My Product",
    "slug": "my-product",
    "status": "ENABLED",
    "categories": [
      { "slug": "men/clothing/tops" },
      { "slug": "summer/essentials" }
    ],
    "roles": ["SEARCH", "CATALOG"]
  }
]
```

---

## Key Concepts

### Slugs and hierarchy

The `slug` field is the unique identifier for a category and encodes its position in the tree. By convention, child slugs extend the parent slug with a `/` separator:

```
men                    ← level 1 (root)
men/clothing           ← level 2
men/clothing/tops      ← level 3
men/clothing/tops/tees ← level 4 (max depth for navigation query)
```

The `parentSlug` field must explicitly reference the direct parent. Setting an incorrect `parentSlug` relative to the `slug` path will cause hierarchy inconsistencies.

### Category families

A `family` groups categories into an independent tree. Use families when you need multiple distinct navigation structures — for example a main product taxonomy alongside a seasonal or promotional hierarchy. When querying the storefront, pass the family name in the `family` argument to scope results:

```graphql
navigation(family: "seasonal") { ... }
categoryTree(family: "main-catalog") { ... }
```

### Navigation depth limit

The `navigation` GraphQL query returns a maximum of **4 levels** of nested children. Design your hierarchy accordingly — categories deeper than level 4 will not appear in navigation results (but remain accessible via `categoryTree`).

### Image roles

| Role | Usage |
|---|---|
| `BASE` | Primary display image (e.g. category hero) |
| `THUMBNAIL` | Compact image for menus or listing tiles |
| `customRoles` | Arbitrary string tags for your storefront (e.g. `"hero-banner"`) |

---

## API Response Reference

| Scenario | HTTP Status | Body |
|---|---|---|
| Success | `200` | `{ "status": "ACCEPTED", "acceptedCount": N }` |
| Bad request (invalid payload) | `400` | Error detail object |
| Unauthorized (bad/expired token) | `401` | Error detail object |
| Rate limit exceeded | `429` | Error detail object |

---

## Rate Limits

The Data Ingestion API is limited to **300 requests per minute**. Exceeding this returns a `429` response. For large catalog seeding operations, add delays between batch requests or use the [TypeScript SDK](https://github.com/adobe-commerce/aco-ts-sdk) or [Java SDK](https://github.com/adobe-commerce/aco-java-sdk) which handle retries automatically.

---

## References

- [Categories Storefront Implementation Guide](https://developer.adobe.com/commerce/services/optimizer/merchandising-services/categories-storefront-implementation/)
- [Data Ingestion API – Get Started](https://developer.adobe.com/commerce/services/optimizer/data-ingestion/using-the-api/)
- [Data Ingestion REST API Reference](https://developer.adobe.com/commerce/services/reference/rest/)
- [Merchandising GraphQL API Reference](https://developer.adobe.com/commerce/services/reference/graphql/)
- [Authentication Guide](https://developer.adobe.com/commerce/services/optimizer/data-ingestion/authentication/)
- [Adobe Commerce Optimizer Tutorial](https://developer.adobe.com/commerce/services/optimizer/ccdm-use-case/)
