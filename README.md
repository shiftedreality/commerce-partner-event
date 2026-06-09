# Adobe Commerce Optimizer – Automotive Categories API

Postman and Insomnia collections for creating and managing an **automotive parts & accessories** category hierarchy via the Adobe Commerce Optimizer Data Ingestion REST API.

---

## Contents

- [Overview](#overview)
- [Files](#files)
- [Catalog Structure](#catalog-structure)
- [Prerequisites](#prerequisites)
- [Import into Postman](#import-into-postman)
- [Import into Insomnia](#import-into-insomnia)
- [Using curl scripts](#using-curl-scripts)
- [Configuration](#configuration)
  - [Postman](#postman-configuration)
  - [Insomnia](#insomnia-configuration)
  - [curl scripts](#curl-scripts-configuration)
- [Authentication](#authentication)
  - [Postman](#postman-authentication)
  - [Insomnia](#insomnia-authentication)
- [Requests](#requests)
  - [0. Get Access Token](#0-get-access-token)
  - [1. Create Root Category – Engine & Drivetrain](#1-create-root-category--engine--drivetrain)
  - [2. Create Child Category – Engine Components (Level 2)](#2-create-child-category--engine-components-level-2)
  - [3. Create Grandchild Category – Pistons & Rings (Level 3)](#3-create-grandchild-category--pistons--rings-level-3)
  - [4. Batch Create – Brakes & Suspension Trees](#4-batch-create--brakes--suspension-trees)
  - [5. Create Full Rich Category – Electrical & Lighting](#5-create-full-rich-category--electrical--lighting)
  - [6. Create Seasonal Family – Winter & Summer Campaigns](#6-create-seasonal-family--winter--summer-campaigns)
  - [7. Assign Automotive Part to Categories](#7-assign-automotive-part-to-categories)
- [Discovery API](#discovery-api)
  - [1. Navigation](#1-navigation)
  - [2. Category Tree](#2-category-tree)
- [Full Category Hierarchy](#full-category-hierarchy)
- [Key Concepts](#key-concepts)
- [API Response Reference](#api-response-reference)
- [Rate Limits](#rate-limits)
- [References](#references)

---

## Overview

This collection models a real-world automotive aftermarket catalog using two independent category families ingested via the Adobe Commerce Optimizer Data Ingestion REST API. Categories are then queryable on the storefront through the Merchandising GraphQL API (`navigation`, `categoryTree`, `searchCategory` queries).

**Base URL pattern:**
```
https://{region}-{environment}.api.commerce.adobe.com/{tenantId}/v1/catalog/categories
```

---

## Files

| File | Tool | Description |
|---|---|---|
| `aco_categories_postman.json` | Postman | Collection with auto-token scripting and folder grouping |
| `aco_categories_insomnia.json` | Insomnia | Equivalent collection with pre-built environment variables |
| `curl_requests.sh` | curl | Ingestion API - executes all 8 requests end-to-end; fetches token automatically |
| `curl_discovery.sh` | curl | Discovery GraphQL API - prints assembled curl commands ready to copy and run |

The Postman and Insomnia collections contain identical ingestion requests. The curl scripts are self-contained alternatives requiring no additional tooling.

---

## Catalog Structure

The collection uses **two category families** to separate the permanent parts taxonomy from time-limited seasonal campaigns.

### `parts-catalog` — Core Parts Taxonomy

```
Engine & Drivetrain          (level 1)
└── Engine Components        (level 2)
    └── Pistons & Rings      (level 3)

Brakes                       (level 1)
├── Brake Pads               (level 2)
├── Brake Rotors & Drums     (level 2)
└── Calipers & Hardware      (level 2)

Suspension & Steering        (level 1)
├── Shocks & Struts          (level 2)
└── Control Arms & Ball Joints (level 2)

Electrical & Lighting        (level 1)
├── Batteries & Charging     (level 2)
├── Headlights & Tail Lights (level 2)
└── Sensors & Switches       (level 2)
```

### `seasonal-catalog` — Seasonal Campaigns

```
Winter Vehicle Prep              (level 1)
├── Cold Weather Batteries       (level 2)
└── Winter Wipers & Washer Fluid (level 2)

Summer Performance               (level 1)
└── Cooling System Upgrades      (level 2)
```

A product such as an AGM battery can simultaneously belong to `electrical-lighting/batteries-charging` (parts-catalog) **and** `winter-prep/cold-weather-batteries` (seasonal-catalog), surfacing it in both permanent navigation and the winter campaign.

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

## Import into Insomnia

1. Download `Adobe_Commerce_Automotive_Categories.insomnia_collection.json`
2. Open Insomnia
3. Click **File → Import** and select the file (or drag it into the Insomnia window)
4. The workspace **Adobe Commerce Optimizer – Automotive Categories API** appears with four request folders and two pre-built environments

> **Insomnia version:** This collection uses the v4 export format, compatible with Insomnia 2023.x and later.

---

## Using curl scripts

Two standalone bash scripts are provided as an alternative to the GUI collections.

| Script | Purpose |
|---|---|
| `curl_requests.sh` | Runs all 8 ingestion API requests sequentially; fetches and caches the IMS token automatically |
| `curl_discovery.sh` | Prints ready-to-run curl commands for the two Discovery GraphQL queries |

**Run the ingestion script:**

```bash
chmod +x curl_requests.sh && ./curl_requests.sh
```

**Print discovery commands:** (results may be available with some delay)

```bash
chmod +x curl_discovery.sh && ./curl_discovery.sh
```

Fill in the variables at the top of each file before running. See [curl scripts configuration](#curl-scripts-configuration) below.

---

## Configuration

The same six variables are used in both tools. Fill these in before running any request.

| Variable | Description | Example |
|---|---|---|
| `tenantId` | Unique identifier for your Commerce Optimizer instance | `abc123xyz` |
| `clientId` | OAuth client ID from Adobe Developer Console | `abc123...` |
| `clientSecret` | OAuth client secret from Adobe Developer Console | `p8e-xyz...` |
| `region` | Cloud region of your instance | `na1` |
| `environment` | `sandbox` for non-production; empty string for production | `sandbox` |
| `accessToken` | Bearer token — see [Authentication](#authentication) below | `Bearer eyJ...` |

> **Sandbox note:** Sandbox instances are only available in the North America (`na1`) region.

### Postman configuration

Open the collection → **Variables** tab and fill in the values. The `accessToken` variable is set automatically by the test script in request 0 — leave it blank initially.

### curl scripts configuration

Open the relevant script and fill in the variables at the top of the file.

**`curl_requests.sh`** — Ingestion API:

| Variable | Description |
|---|---|
| `TENANT_ID` | Your Commerce Optimizer instance ID |
| `CLIENT_ID` | OAuth client ID from Adobe Developer Console |
| `CLIENT_SECRET` | OAuth client secret |
| `REGION` | Cloud region, e.g. `na1` |
| `ENVIRONMENT` | `sandbox` for non-production; empty string `""` for production |
| `LOCALE` | Source locale for category data, e.g. `en-US` |

**`curl_discovery.sh`** — Discovery GraphQL API:

| Variable | Description                                                                 |
|---|-----------------------------------------------------------------------------|
| `TENANT_ID` | Your Commerce Optimizer instance ID                                         |
| `REGION` / `ENVIRONMENT` | Same as above                                                               |
| `PRICE_BOOK_ID` | Price book identifier, e.g. `base_usd`                                      |
| `SCOPE_LOCALE` | Storefront scope locale, e.g. `en-US`                                       |
| `VIEW_ID` | Storefront view ID (UUID)                                                   |
| `FAMILY` | Catalog family used during ingestion: `parts-catalog` or `seasonal-catalog` |

---

### Insomnia configuration

The Insomnia collection ships with two pre-built environments accessible from the environment dropdown in the top-left corner of the sidebar:

| Environment | `baseUrl` | Intended use |
|---|---|---|
| **Base Environment** | `https://na1-sandbox.api.commerce.adobe.com` | Sandbox / development |
| **Production** | `https://na1.api.commerce.adobe.com` | Production (shown in red) |

Select the appropriate environment, then click **Manage Environments** to edit your `tenantId`, `clientId`, `clientSecret`, and `accessToken` values directly in the environment JSON.

---

## Authentication

Both collections use **Adobe IMS OAuth 2.0 client credentials** flow. Run **request 0** first to obtain a token.

The token is scoped to:
```
openid, AdobeID, email, additional_info.projectedProductContext,
profile, commerce.aco.ingestion, commerce.accs, org.read, additional_info.roles
```

IMS tokens expire after **24 hours**. Re-run request 0 to refresh.

### Postman authentication

A Postman Test script on request 0 automatically extracts `access_token` from the response and saves it as `{{accessToken}}` (prefixed with `Bearer `) on the collection. All subsequent requests are authorized with no manual steps.

### Insomnia authentication

Insomnia does not support post-response scripts, so the token must be set manually:

1. Run request **0. Get Access Token**
2. In the response body, copy the value of `access_token`
3. Open **Manage Environments** for your active environment
4. Update the `accessToken` value to: `Bearer <paste_token_here>`
5. All subsequent requests will pick up the updated value automatically

---

## Requests

### 0. Get Access Token

**POST** `https://ims-na1.adobelogin.com/ims/token/v3`

Exchanges your client credentials for a Bearer token.

- **Postman:** the Test script saves the token to `{{accessToken}}` automatically.
- **Insomnia:** copy `access_token` from the response body and paste it into your environment's `accessToken` variable as `Bearer <token>`.

---

### 1. Create Root Category – Engine & Drivetrain

**POST** `.../v1/catalog/categories`

Creates the top-level Engine & Drivetrain root in the `parts-catalog` family with a hero image and full SEO metaTags.

```json
[
  {
    "slug": "engine-drivetrain",
    "source": { "locale": "en-US" },
    "name": "Engine & Drivetrain",
    "families": ["parts-catalog"],
    "description": "OEM and aftermarket engine components, transmissions, and drivetrain parts for all makes and models.",
    "metaTags": {
      "title": "Engine & Drivetrain Parts | AutoParts Store",
      "description": "Shop engine components, transmissions, differentials, and drivetrain parts.",
      "keywords": ["engine parts", "drivetrain", "transmission", "OEM", "aftermarket"]
    },
    "images": [
      {
        "url": "https://example.com/images/engine-drivetrain-hero.jpg",
        "label": "Engine and drivetrain parts hero",
        "roles": ["BASE", "THUMBNAIL"],
        "customRoles": ["category-hero"]
      }
    ]
  }
]
```

---

### 2. Create Child Category – Engine Components (Level 2)

**POST** `.../v1/catalog/categories`

Creates a level 2 subcategory nested under `engine-drivetrain`. The slug path prefix (`engine-drivetrain`) identifies the parent category.

```json
[
  {
    "slug": "engine-drivetrain/engine-components",
    "source": { "locale": "en-US" },
    "name": "Engine Components",
    "families": ["parts-catalog"],
    "description": "Pistons, gaskets, timing systems, and valvetrain parts."
  }
]
```

---

### 3. Create Grandchild Category – Pistons & Rings (Level 3)

**POST** `.../v1/catalog/categories`

Creates a level 3 leaf category. Images and metaTags are optional at this depth.

```json
[
  {
    "slug": "engine-drivetrain/engine-components/pistons-rings",
    "source": { "locale": "en-US" },
    "name": "Pistons & Rings",
    "families": ["parts-catalog"],
    "description": "Forged and cast pistons, piston rings, and pin kits for engine rebuilds and performance upgrades."
  }
]
```

---

### 4. Batch Create – Brakes & Suspension Trees

**POST** `.../v1/catalog/categories`

Seeds two complete category trees — Brakes (root + 3 children) and Suspension & Steering (root + 2 children) — in a **single API call**. This is the recommended approach for bulk catalog seeding.

**7 categories created, one request:**

| Slug | Depth |
|---|---|
| `brakes` | 1 |
| `brakes/brake-pads` | 2 |
| `brakes/brake-rotors` | 2 |
| `brakes/calipers-hardware` | 2 |
| `suspension` | 1 |
| `suspension/shocks-struts` | 2 |
| `suspension/control-arms-ball-joints` | 2 |

**Response:**
```json
{ "status": "ACCEPTED", "acceptedCount": 7 }
```

---

### 5. Create Full Rich Category – Electrical & Lighting

**POST** `.../v1/catalog/categories`

Creates the Electrical & Lighting root with the complete set of optional fields — dual images (hero `BASE` + `THUMBNAIL`), `customRoles` for storefront targeting, full SEO `metaTags` — plus three child subcategories in one request. This shape is the template for **SEO-driven category landing pages**.

**Subcategories created:**

| Slug | Name |
|---|---|
| `electrical-lighting/batteries-charging` | Batteries & Charging |
| `electrical-lighting/headlights-taillights` | Headlights & Tail Lights |
| `electrical-lighting/sensors-switches` | Sensors & Switches |

---

### 6. Create Seasonal Family – Winter & Summer Campaigns

**POST** `.../v1/catalog/categories`

Creates two campaign trees under the separate `seasonal-catalog` family. Seasonal categories are fully independent from `parts-catalog` and can be toggled or removed without affecting permanent navigation.

**Categories created:**

| Slug | families | Depth |
|---|---|---|
| `winter-prep` | `["seasonal-catalog"]` | 1 |
| `winter-prep/cold-weather-batteries` | `["seasonal-catalog"]` | 2 |
| `winter-prep/winter-wipers-fluid` | `["seasonal-catalog"]` | 2 |
| `summer-performance` | `["seasonal-catalog"]` | 1 |
| `summer-performance/cooling-system` | `["seasonal-catalog"]` | 2 |

Images include `customRoles: ["seasonal-hero", "homepage-banner"]` for storefront banner slot targeting.

**Storefront query scoped to seasonal family:**
```graphql
navigation(family: "seasonal-catalog") {
  slug
  name
  children { slug name }
}
```

---

### 7. Assign Automotive Part to Categories

**POST** `.../v1/catalog/products`

Assigns the **ProStart AGM Group H6 850CCA Battery** to categories in both families simultaneously — it appears in the permanent Batteries & Charging section and also surfaces in the Winter Vehicle Prep campaign.

```json
[
  {
    "sku": "BAT-AGM-H6-850CCA",
    "source": { "locale": "en-US" },
    "name": "ProStart AGM Group H6 850CCA Battery",
    "slug": "bat-agm-h6-850cca",
    "status": "ENABLED",
    "visibleIn": ["SEARCH", "CATALOG"],
    "attributes": [
      { "code": "brand",            "values": ["ProStart"] },
      { "code": "batteryType",      "values": ["AGM"] },
      { "code": "coldCrankingAmps", "values": ["850"] },
      { "code": "groupSize",        "values": ["H6"] }
    ],
    "routes": [
      { "path": "electrical-lighting/batteries-charging" },
      { "path": "winter-prep/cold-weather-batteries" }
    ]
  }
]
```

---

## Discovery API

The Discovery GraphQL API exposes ingested categories for storefront rendering. Use `curl_discovery.sh` to generate ready-to-run commands for the queries below, or import the **Discovery** folder from the Postman/Insomnia collections.

**Endpoint:** `POST https://{region}-{environment}.api.commerce.adobe.com/{tenantId}/graphql`

**Required headers (both queries):**

| Header | Value |
|---|---|
| `Content-Type` | `application/json` |
| `AC-ENVIRONMENT-Id` | Your tenant ID |
| `AC-Scope-Locale` | Storefront scope locale |

---

### 1. Navigation

Returns a nested tree of categories up to 4 levels deep — the primary input for building storefront navigation menus.

Additional headers: `AC-Price-Book-ID`, `ac-view-id`

```graphql
query Navigation($family: String!) {
  navigation(family: $family) {
    slug
    name
    children {
      slug
      name
      children {
        slug
        name
        children {
          name
        }
      }
    }
  }
}
```

**Variables:**

```json
{ "family": "parts-catalog" }
```

> The `navigation` query returns a maximum of 4 levels. Categories deeper than level 4 remain accessible via `categoryTree`.

---

### 2. Category Tree

Returns a flat list of category nodes with full metadata — level, parent/child relationships, SEO metaTags, and images. Suitable for building breadcrumbs, sitemap generation, or fetching a single subtree by slug.

```graphql
query CategoriesTree($family: String!, $slugs: [String!], $depth: Int) {
  categoryTree(family: $family, slugs: $slugs, depth: $depth) {
    slug
    name
    level
    parentSlug
    childrenSlugs
    metaTags {
      title
    }
    images {
      roles
      customRoles
      url
    }
  }
}
```

**Variables:**

```json
{
  "family": "parts-catalog",
  "slugs": [],
  "depth": 5
}
```

Set `slugs` to a non-empty array to limit results to a specific subtree, e.g. `["brakes", "suspension"]`. Leave it empty (`[]`) to return all categories in the family.

---

## Full Category Hierarchy

```
parts-catalog
├── engine-drivetrain                                 (L1)
│   └── engine-drivetrain/engine-components          (L2)
│       └── .../pistons-rings                        (L3)
├── brakes                                           (L1)
│   ├── brakes/brake-pads                            (L2)
│   ├── brakes/brake-rotors                          (L2)
│   └── brakes/calipers-hardware                     (L2)
├── suspension                                       (L1)
│   ├── suspension/shocks-struts                     (L2)
│   └── suspension/control-arms-ball-joints          (L2)
└── electrical-lighting                              (L1)
    ├── electrical-lighting/batteries-charging       (L2)
    ├── electrical-lighting/headlights-taillights    (L2)
    └── electrical-lighting/sensors-switches         (L2)

seasonal-catalog
├── winter-prep                                      (L1)
│   ├── winter-prep/cold-weather-batteries           (L2)
│   └── winter-prep/winter-wipers-fluid              (L2)
└── summer-performance                               (L1)
    └── summer-performance/cooling-system            (L2)
```

---

## Key Concepts

### Slugs and hierarchy

The `slug` field is the unique identifier for a category and encodes its position in the tree. Child slugs extend the parent with a `/` separator:

```
brakes                        ← level 1 (root)
brakes/brake-pads             ← level 2
brakes/brake-pads/ceramic     ← level 3
brakes/brake-pads/ceramic/oem ← level 4 (max depth for navigation query)
```

The parent category is determined by the slug path prefix. For example, `brakes/brake-pads` is implicitly a child of `brakes` — no separate parent field is needed.

### Category families

The `families` array assigns a category to one or more independent navigation trees:

| families value | Purpose |
|---|---|
| `parts-catalog` | Permanent OEM/aftermarket parts taxonomy — always-on main navigation |
| `seasonal-catalog` | Time-limited campaign trees — activated for seasonal promotions |

When querying the storefront, pass the `family` argument to scope results:

```graphql
# Parts navigation only
navigation(family: "parts-catalog") { ... }

# Winter campaign tree only
categoryTree(family: "seasonal-catalog", slugs: ["winter-prep"]) { ... }
```

### Cross-family product placement

A single product SKU can be assigned to categories across multiple families without data duplication. The product record is shared; only the category assignment differs. This lets an AGM battery live permanently under Electrical and also surface in the Winter prep campaign.

### Navigation depth limit

The `navigation` GraphQL query returns a maximum of **4 levels** of nested children. Categories deeper than level 4 won't appear in navigation results but remain accessible via `categoryTree`.

### Image roles

| Role | Usage |
|---|---|
| `BASE` | Primary display image (category hero) |
| `THUMBNAIL` | Compact image for menus and listing tiles |
| `customRoles` | Arbitrary tags for storefront slot targeting — e.g. `"category-hero"`, `"homepage-banner"`, `"nav-featured"`, `"seasonal-hero"` |

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

The Data Ingestion API is limited to **300 requests per minute**. Exceeding this returns a `429`. For large catalog seeding operations, batch multiple categories into a single request payload (as shown in request 4) or use the official SDKs which handle retries automatically:

- [TypeScript SDK](https://github.com/adobe-commerce/aco-ts-sdk)
- [Java SDK](https://github.com/adobe-commerce/aco-java-sdk)

---

## References

- [Categories Storefront Implementation Guide](https://developer.adobe.com/commerce/services/optimizer/merchandising-services/categories-storefront-implementation/)
- [Data Ingestion API – Get Started](https://developer.adobe.com/commerce/services/optimizer/data-ingestion/using-the-api/)
- [Data Ingestion REST API Reference](https://developer.adobe.com/commerce/services/reference/rest/)
- [Merchandising GraphQL API Reference](https://developer.adobe.com/commerce/services/reference/graphql/)
- [Authentication Guide](https://developer.adobe.com/commerce/services/optimizer/data-ingestion/authentication/)
- [Adobe Commerce Optimizer Tutorial](https://developer.adobe.com/commerce/services/optimizer/ccdm-use-case/)
