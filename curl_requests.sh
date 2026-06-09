#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Adobe Commerce Optimizer - Automotive Categories API
# ---------------------------------------------------------------------------
# Fill in the four required values below, then run:
#   chmod +x curl_requests.sh && ./curl_requests.sh
# ---------------------------------------------------------------------------

TENANT_ID="YOUR_TENANT_ID"
CLIENT_ID="YOUR_CLIENT_ID"
CLIENT_SECRET="YOUR_CLIENT_SECRET"
REGION="na1"
ENVIRONMENT="sandbox"          # set to "" for production
LOCALE="en-US"

# Derived URLs
if [[ -n "$ENVIRONMENT" ]]; then
  BASE_URL="https://${REGION}-${ENVIRONMENT}.api.commerce.adobe.com"
else
  BASE_URL="https://${REGION}.api.commerce.adobe.com"
fi

IMS_URL="https://ims-na1.adobelogin.com/ims/token/v3"
CATEGORIES_ENDPOINT="/v1/catalog/categories"
PRODUCTS_ENDPOINT="/v1/catalog/products"

# ---------------------------------------------------------------------------
# 0. Get Access Token
# ---------------------------------------------------------------------------
echo "==> 0. Get Access Token"
TOKEN_RESPONSE=$(curl --silent --fail --show-error \
  -X POST "$IMS_URL" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "grant_type=client_credentials" \
  --data-urlencode "client_id=$CLIENT_ID" \
  --data-urlencode "client_secret=$CLIENT_SECRET" \
  --data-urlencode "scope=openid,AdobeID,email,additional_info.projectedProductContext,profile,commerce.aco.ingestion,commerce.accs,org.read,additional_info.roles"
)
echo "$TOKEN_RESPONSE"

# Extract the raw token value and prefix it with "Bearer "
ACCESS_TOKEN="Bearer $(echo "$TOKEN_RESPONSE" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)"
echo ""
echo "Access token captured."
echo ""

# ---------------------------------------------------------------------------
# 1. Create Root Category - Engine & Drivetrain
# ---------------------------------------------------------------------------
echo "==> 1. Create Root Category - Engine & Drivetrain"
curl --silent --fail --show-error \
  -X POST "${BASE_URL}/${TENANT_ID}${CATEGORIES_ENDPOINT}" \
  -H "Content-Type: application/json" \
  -H "Authorization: $ACCESS_TOKEN" \
  -d '[
  {
    "slug": "engine-drivetrain",
    "source": { "locale": "'"$LOCALE"'" },
    "name": "Engine & Drivetrain",
    "families": ["parts-catalog"],
    "description": "OEM and aftermarket engine components, transmissions, and drivetrain parts for all makes and models.",
    "metaTags": {
      "title": "Engine & Drivetrain Parts | AutoParts Store",
      "description": "Shop engine components, transmissions, differentials, and drivetrain parts. OEM quality and aftermarket options available.",
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
]'
echo ""
echo ""

# ---------------------------------------------------------------------------
# 2. Create Child Category - Engine Components (Level 2)
# ---------------------------------------------------------------------------
echo "==> 2. Create Child Category - Engine Components (Level 2)"
curl --silent --fail --show-error \
  -X POST "${BASE_URL}/${TENANT_ID}${CATEGORIES_ENDPOINT}" \
  -H "Content-Type: application/json" \
  -H "Authorization: $ACCESS_TOKEN" \
  -d '[
  {
    "slug": "engine-drivetrain/engine-components",
    "source": { "locale": "'"$LOCALE"'" },
    "name": "Engine Components",
    "families": ["parts-catalog"],
    "description": "Internal and external engine components including pistons, gaskets, timing systems, and valvetrain parts.",
    "metaTags": {
      "title": "Engine Components | AutoParts Store",
      "description": "Browse OEM and aftermarket engine components. Pistons, head gaskets, timing chains, camshafts, and more.",
      "keywords": ["engine components", "pistons", "gaskets", "timing chain", "camshaft"]
    },
    "images": [
      {
        "url": "https://example.com/images/engine-components.jpg",
        "label": "Engine components category",
        "roles": ["BASE", "THUMBNAIL"]
      }
    ]
  }
]'
echo ""
echo ""

# ---------------------------------------------------------------------------
# 3. Create Grandchild Category - Pistons & Rings (Level 3)
# ---------------------------------------------------------------------------
echo "==> 3. Create Grandchild Category - Pistons & Rings (Level 3)"
curl --silent --fail --show-error \
  -X POST "${BASE_URL}/${TENANT_ID}${CATEGORIES_ENDPOINT}" \
  -H "Content-Type: application/json" \
  -H "Authorization: $ACCESS_TOKEN" \
  -d '[
  {
    "slug": "engine-drivetrain/engine-components/pistons-rings",
    "source": { "locale": "'"$LOCALE"'" },
    "name": "Pistons & Rings",
    "families": ["parts-catalog"],
    "description": "Forged and cast pistons, piston rings, and piston pin kits for engine rebuilds and performance upgrades.",
    "metaTags": {
      "title": "Pistons & Rings | Engine Components",
      "description": "Shop forged pistons, piston ring sets, and pin kits for stock rebuilds and high-performance builds.",
      "keywords": ["pistons", "piston rings", "forged pistons", "engine rebuild", "performance"]
    }
  }
]'
echo ""
echo ""

# ---------------------------------------------------------------------------
# 4. Batch Create - Brakes & Suspension Trees
# ---------------------------------------------------------------------------
echo "==> 4. Batch Create - Brakes & Suspension Trees"
curl --silent --fail --show-error \
  -X POST "${BASE_URL}/${TENANT_ID}${CATEGORIES_ENDPOINT}" \
  -H "Content-Type: application/json" \
  -H "Authorization: $ACCESS_TOKEN" \
  -d '[
  {
    "slug": "brakes",
    "source": { "locale": "'"$LOCALE"'" },
    "name": "Brakes",
    "families": ["parts-catalog"],
    "description": "Complete brake system parts - pads, rotors, calipers, lines, and hardware for all vehicle types.",
    "metaTags": {
      "title": "Brake Parts | AutoParts Store",
      "description": "Shop brake pads, rotors, calipers, and complete brake kits. OEM replacements and performance upgrades.",
      "keywords": ["brake pads", "brake rotors", "calipers", "brake kit", "stopping power"]
    },
    "images": [
      {
        "url": "https://example.com/images/brakes-hero.jpg",
        "label": "Brake system parts hero",
        "roles": ["BASE", "THUMBNAIL"],
        "customRoles": ["category-hero"]
      }
    ]
  },
  {
    "slug": "brakes/brake-pads",
    "source": { "locale": "'"$LOCALE"'" },
    "name": "Brake Pads",
    "families": ["parts-catalog"],
    "description": "Ceramic, semi-metallic, and organic brake pads for street, track, and heavy-duty applications.",
    "metaTags": {
      "title": "Brake Pads | AutoParts Store",
      "description": "Find the right brake pads - ceramic for daily driving, semi-metallic for towing, performance compounds for track use.",
      "keywords": ["ceramic brake pads", "semi-metallic pads", "performance brake pads", "track pads"]
    }
  },
  {
    "slug": "brakes/brake-rotors",
    "source": { "locale": "'"$LOCALE"'" },
    "name": "Brake Rotors & Drums",
    "families": ["parts-catalog"],
    "description": "Slotted, drilled, and plain rotors plus brake drums for all vehicle classes.",
    "metaTags": {
      "title": "Brake Rotors & Drums | AutoParts Store",
      "description": "Shop drilled, slotted, and plain brake rotors plus replacement drums. OEM fitment guaranteed.",
      "keywords": ["brake rotors", "drilled rotors", "slotted rotors", "brake drums"]
    }
  },
  {
    "slug": "brakes/calipers-hardware",
    "source": { "locale": "'"$LOCALE"'" },
    "name": "Calipers & Hardware",
    "families": ["parts-catalog"],
    "description": "Remanufactured and new calipers, caliper brackets, brake hardware kits, and guide pins.",
    "metaTags": {
      "title": "Calipers & Brake Hardware | AutoParts Store",
      "description": "Browse brake calipers, brackets, and hardware kits. Remanufactured cores accepted.",
      "keywords": ["brake calipers", "caliper brackets", "brake hardware", "guide pins"]
    }
  },
  {
    "slug": "suspension",
    "source": { "locale": "'"$LOCALE"'" },
    "name": "Suspension & Steering",
    "families": ["parts-catalog"],
    "description": "Shocks, struts, control arms, tie rods, and complete suspension kits for all makes and models.",
    "metaTags": {
      "title": "Suspension & Steering Parts | AutoParts Store",
      "description": "Shop shocks, struts, ball joints, control arms, and steering components.",
      "keywords": ["shocks", "struts", "control arms", "tie rods", "suspension kit"]
    },
    "images": [
      {
        "url": "https://example.com/images/suspension-hero.jpg",
        "label": "Suspension and steering parts hero",
        "roles": ["BASE", "THUMBNAIL"],
        "customRoles": ["category-hero"]
      }
    ]
  },
  {
    "slug": "suspension/shocks-struts",
    "source": { "locale": "'"$LOCALE"'" },
    "name": "Shocks & Struts",
    "families": ["parts-catalog"],
    "description": "OEM replacement and performance shocks and struts, complete strut assemblies, and coilover kits.",
    "metaTags": {
      "title": "Shocks & Struts | AutoParts Store",
      "description": "Find replacement shocks, struts, and complete strut assemblies. Performance and OEM options in stock.",
      "keywords": ["shocks", "struts", "strut assembly", "coilovers"]
    }
  },
  {
    "slug": "suspension/control-arms-ball-joints",
    "source": { "locale": "'"$LOCALE"'" },
    "name": "Control Arms & Ball Joints",
    "families": ["parts-catalog"],
    "description": "Upper and lower control arms, ball joints, and complete control arm assemblies with bushings pre-installed.",
    "metaTags": {
      "title": "Control Arms & Ball Joints | AutoParts Store",
      "description": "Shop upper and lower control arms, ball joints, and pre-assembled kits for easy installation.",
      "keywords": ["control arms", "ball joints", "upper control arm", "lower control arm"]
    }
  }
]'
echo ""
echo ""

# ---------------------------------------------------------------------------
# 5. Create Full Rich Category - Electrical & Lighting
# ---------------------------------------------------------------------------
echo "==> 5. Create Full Rich Category - Electrical & Lighting"
curl --silent --fail --show-error \
  -X POST "${BASE_URL}/${TENANT_ID}${CATEGORIES_ENDPOINT}" \
  -H "Content-Type: application/json" \
  -H "Authorization: $ACCESS_TOKEN" \
  -d '[
  {
    "slug": "electrical-lighting",
    "source": { "locale": "'"$LOCALE"'" },
    "name": "Electrical & Lighting",
    "families": ["parts-catalog"],
    "description": "Batteries, alternators, starters, sensors, wiring harnesses, headlights, tail lights, and all vehicle electrical components.",
    "metaTags": {
      "title": "Electrical & Lighting Parts | AutoParts Store",
      "description": "Shop batteries, alternators, starters, sensors, and lighting. OEM and aftermarket electrical parts for all vehicles.",
      "keywords": ["car battery", "alternator", "starter motor", "headlights", "sensors", "wiring"]
    },
    "images": [
      {
        "url": "https://example.com/images/electrical-lighting-hero.jpg",
        "label": "Electrical and lighting parts hero banner",
        "roles": ["BASE"],
        "customRoles": ["category-hero", "nav-featured"]
      },
      {
        "url": "https://example.com/images/electrical-lighting-thumb.jpg",
        "label": "Electrical and lighting thumbnail",
        "roles": ["THUMBNAIL"]
      }
    ]
  },
  {
    "slug": "electrical-lighting/batteries-charging",
    "source": { "locale": "'"$LOCALE"'" },
    "name": "Batteries & Charging",
    "families": ["parts-catalog"],
    "description": "Automotive and truck batteries, alternators, voltage regulators, and battery accessories.",
    "metaTags": {
      "title": "Car Batteries & Charging Systems | AutoParts Store",
      "description": "Find the right battery for your vehicle. Shop alternators, voltage regulators, and battery maintainers.",
      "keywords": ["car battery", "truck battery", "alternator", "voltage regulator", "battery charger"]
    },
    "images": [
      {
        "url": "https://example.com/images/batteries-charging.jpg",
        "label": "Batteries and charging systems",
        "roles": ["BASE", "THUMBNAIL"]
      }
    ]
  },
  {
    "slug": "electrical-lighting/headlights-taillights",
    "source": { "locale": "'"$LOCALE"'" },
    "name": "Headlights & Tail Lights",
    "families": ["parts-catalog"],
    "description": "OEM replacement and upgraded headlight assemblies, tail light assemblies, fog lights, and daytime running lights.",
    "metaTags": {
      "title": "Headlights & Tail Lights | AutoParts Store",
      "description": "Shop OEM replacement headlights, tail lights, and LED upgrades. Direct-fit assemblies for all makes.",
      "keywords": ["headlights", "tail lights", "LED headlights", "headlight assembly", "fog lights"]
    },
    "images": [
      {
        "url": "https://example.com/images/lighting-hero.jpg",
        "label": "Headlights and tail lights",
        "roles": ["BASE", "THUMBNAIL"]
      }
    ]
  },
  {
    "slug": "electrical-lighting/sensors-switches",
    "source": { "locale": "'"$LOCALE"'" },
    "name": "Sensors & Switches",
    "families": ["parts-catalog"],
    "description": "O2 sensors, MAP sensors, ABS sensors, crankshaft position sensors, and ignition switches.",
    "metaTags": {
      "title": "Sensors & Switches | AutoParts Store",
      "description": "Find O2 sensors, ABS sensors, MAP sensors, and ignition switches. OEM quality for accurate engine management.",
      "keywords": ["O2 sensor", "oxygen sensor", "ABS sensor", "MAP sensor", "crankshaft sensor"]
    }
  }
]'
echo ""
echo ""

# ---------------------------------------------------------------------------
# 6. Create Seasonal Family - Winter & Summer Campaigns
# ---------------------------------------------------------------------------
echo "==> 6. Create Seasonal Family - Winter & Summer Campaigns"
curl --silent --fail --show-error \
  -X POST "${BASE_URL}/${TENANT_ID}${CATEGORIES_ENDPOINT}" \
  -H "Content-Type: application/json" \
  -H "Authorization: $ACCESS_TOKEN" \
  -d '[
  {
    "slug": "winter-prep",
    "source": { "locale": "'"$LOCALE"'" },
    "name": "Winter Vehicle Prep",
    "families": ["seasonal-catalog"],
    "description": "Everything you need to prepare your vehicle for winter - batteries, wipers, antifreeze, snow tires, and traction aids.",
    "metaTags": {
      "title": "Winter Vehicle Prep | AutoParts Store",
      "description": "Get your vehicle ready for winter. Shop cold-weather batteries, winter wipers, antifreeze, and snow tires.",
      "keywords": ["winter car prep", "winter battery", "winter wipers", "antifreeze", "snow tires"]
    },
    "images": [
      {
        "url": "https://example.com/images/winter-prep-hero.jpg",
        "label": "Winter vehicle preparation hero",
        "roles": ["BASE", "THUMBNAIL"],
        "customRoles": ["seasonal-hero", "homepage-banner"]
      }
    ]
  },
  {
    "slug": "winter-prep/cold-weather-batteries",
    "source": { "locale": "'"$LOCALE"'" },
    "name": "Cold Weather Batteries",
    "families": ["seasonal-catalog"],
    "description": "High cold-cranking-amp (CCA) batteries engineered for reliable starts in sub-zero temperatures.",
    "metaTags": {
      "title": "Cold Weather Car Batteries | AutoParts Store",
      "description": "Shop high CCA batteries built for winter. AGM and lead-acid options for trucks, SUVs, and passenger cars.",
      "keywords": ["cold weather battery", "high CCA battery", "AGM battery", "winter battery"]
    }
  },
  {
    "slug": "winter-prep/winter-wipers-fluid",
    "source": { "locale": "'"$LOCALE"'" },
    "name": "Winter Wipers & Washer Fluid",
    "families": ["seasonal-catalog"],
    "description": "Beam and traditional winter wiper blades plus de-icing washer fluid rated to -40F.",
    "metaTags": {
      "title": "Winter Wiper Blades & De-Icer Fluid | AutoParts Store",
      "description": "Stay safe in winter weather. Shop beam wiper blades and sub-zero washer fluid.",
      "keywords": ["winter wiper blades", "beam wipers", "de-icer fluid", "washer fluid"]
    }
  },
  {
    "slug": "summer-performance",
    "source": { "locale": "'"$LOCALE"'" },
    "name": "Summer Performance",
    "families": ["seasonal-catalog"],
    "description": "Cooling system upgrades, performance air intakes, summer tires, and detailing products for warm-weather driving.",
    "metaTags": {
      "title": "Summer Performance Parts | AutoParts Store",
      "description": "Maximize performance this summer. Shop radiators, performance intakes, summer tires, and car care products.",
      "keywords": ["summer performance", "cooling system", "performance intake", "summer tires"]
    },
    "images": [
      {
        "url": "https://example.com/images/summer-performance-hero.jpg",
        "label": "Summer performance parts hero",
        "roles": ["BASE", "THUMBNAIL"],
        "customRoles": ["seasonal-hero", "homepage-banner"]
      }
    ]
  },
  {
    "slug": "summer-performance/cooling-system",
    "source": { "locale": "'"$LOCALE"'" },
    "name": "Cooling System Upgrades",
    "families": ["seasonal-catalog"],
    "description": "Performance radiators, electric fans, coolant additives, and thermostat kits to beat summer heat.",
    "metaTags": {
      "title": "Cooling System Parts & Upgrades | AutoParts Store",
      "description": "Keep your engine cool. Shop performance radiators, electric cooling fans, and coolant additives.",
      "keywords": ["performance radiator", "electric fan", "coolant additive", "thermostat"]
    }
  }
]'
echo ""
echo ""

# ---------------------------------------------------------------------------
# 7. Submit Attribute Metadata
# ---------------------------------------------------------------------------
echo "==> 7. Submit Attribute Metadata"
curl --silent --fail --show-error \
  -X POST "${BASE_URL}/${TENANT_ID}${PRODUCTS_ENDPOINT}/metadata" \
  -H "Content-Type: application/json" \
  -H "Authorization: $ACCESS_TOKEN" \
  -d '[
  {
    "code": "sku",
    "source": { "locale": "'"$LOCALE"'" },
    "label": "SKU",
    "dataType": "TEXT",
    "visibleIn": ["PRODUCT_DETAIL", "PRODUCT_LISTING", "SEARCH_RESULTS", "PRODUCT_COMPARE"],
    "filterable": true,
    "sortable": false,
    "searchable": true,
    "searchWeight": 1,
    "searchTypes": ["AUTOCOMPLETE"]
  },
  {
    "code": "name",
    "source": { "locale": "'"$LOCALE"'" },
    "label": "Product Name",
    "dataType": "TEXT",
    "visibleIn": ["PRODUCT_DETAIL", "PRODUCT_LISTING", "SEARCH_RESULTS", "PRODUCT_COMPARE"],
    "filterable": false,
    "sortable": true,
    "searchable": true,
    "searchWeight": 1,
    "searchTypes": ["AUTOCOMPLETE"]
  },
  {
    "code": "description",
    "source": { "locale": "'"$LOCALE"'" },
    "label": "Product Description",
    "dataType": "TEXT",
    "visibleIn": ["PRODUCT_DETAIL"],
    "filterable": false,
    "sortable": false,
    "searchable": false,
    "searchWeight": 1,
    "searchTypes": ["AUTOCOMPLETE"]
  },
  {
    "code": "shortDescription",
    "source": { "locale": "'"$LOCALE"'" },
    "label": "Short Description",
    "dataType": "TEXT",
    "visibleIn": ["PRODUCT_DETAIL"],
    "filterable": false,
    "sortable": false,
    "searchable": true,
    "searchWeight": 1,
    "searchTypes": ["AUTOCOMPLETE"]
  },
  {
    "code": "price",
    "source": { "locale": "'"$LOCALE"'" },
    "label": "Price",
    "dataType": "DECIMAL",
    "visibleIn": ["PRODUCT_DETAIL", "PRODUCT_LISTING", "SEARCH_RESULTS", "PRODUCT_COMPARE"],
    "filterable": true,
    "sortable": true,
    "searchable": false,
    "searchWeight": 1,
    "searchTypes": []
  },
  {
    "code": "brand",
    "source": { "locale": "'"$LOCALE"'" },
    "label": "Brand",
    "dataType": "TEXT",
    "visibleIn": ["PRODUCT_DETAIL", "PRODUCT_LISTING", "SEARCH_RESULTS", "PRODUCT_COMPARE"],
    "filterable": true,
    "sortable": true,
    "searchable": true,
    "searchWeight": 2,
    "searchTypes": ["AUTOCOMPLETE"]
  },
  {
    "code": "batteryType",
    "source": { "locale": "'"$LOCALE"'" },
    "label": "Battery Type",
    "dataType": "TEXT",
    "visibleIn": ["PRODUCT_DETAIL", "PRODUCT_LISTING", "PRODUCT_COMPARE"],
    "filterable": true,
    "sortable": false,
    "searchable": true,
    "searchWeight": 1,
    "searchTypes": ["AUTOCOMPLETE"]
  },
  {
    "code": "coldCrankingAmps",
    "source": { "locale": "'"$LOCALE"'" },
    "label": "Cold Cranking Amps (CCA)",
    "dataType": "INTEGER",
    "visibleIn": ["PRODUCT_DETAIL", "PRODUCT_LISTING", "PRODUCT_COMPARE"],
    "filterable": true,
    "sortable": true,
    "searchable": false,
    "searchWeight": 1,
    "searchTypes": []
  },
  {
    "code": "groupSize",
    "source": { "locale": "'"$LOCALE"'" },
    "label": "Battery Group Size",
    "dataType": "TEXT",
    "visibleIn": ["PRODUCT_DETAIL", "PRODUCT_LISTING", "PRODUCT_COMPARE"],
    "filterable": true,
    "sortable": false,
    "searchable": true,
    "searchWeight": 1,
    "searchTypes": ["AUTOCOMPLETE"]
  },
  {
    "code": "partType",
    "source": { "locale": "'"$LOCALE"'" },
    "label": "Part Type",
    "dataType": "TEXT",
    "visibleIn": ["PRODUCT_DETAIL", "PRODUCT_LISTING", "SEARCH_RESULTS", "PRODUCT_COMPARE"],
    "filterable": true,
    "sortable": false,
    "searchable": true,
    "searchWeight": 1,
    "searchTypes": ["AUTOCOMPLETE"]
  }
]'
echo ""
echo ""

# ---------------------------------------------------------------------------
# 8. Assign Automotive Part to Categories
# ---------------------------------------------------------------------------
echo "==> 8. Assign Automotive Part to Categories"
curl --silent --fail --show-error \
  -X POST "${BASE_URL}/${TENANT_ID}${PRODUCTS_ENDPOINT}" \
  -H "Content-Type: application/json" \
  -H "Authorization: $ACCESS_TOKEN" \
  -d '[
  {
    "sku": "BAT-AGM-H6-850CCA",
    "source": { "locale": "'"$LOCALE"'" },
    "name": "ProStart AGM Group H6 850CCA Battery",
    "slug": "prostart-agm-h6-850cca-battery",
    "status": "ENABLED",
    "visibleIn": ["CATALOG", "SEARCH"],
    "description": "AGM absorbed glass mat battery with 850 cold cranking amps. Maintenance-free, spill-proof design for trucks, SUVs, and high-demand vehicles.",
    "shortDescription": "AGM 850CCA battery - Group H6 fitment",
    "attributes": [
      { "code": "brand",            "values": ["ProStart"] },
      { "code": "batteryType",      "values": ["AGM"] },
      { "code": "coldCrankingAmps", "values": ["850"] },
      { "code": "groupSize",        "values": ["H6"] },
      { "code": "partType",         "values": ["Battery"] }
    ],
    "routes": [
      { "path": "electrical-lighting/batteries-charging" },
      { "path": "winter-prep/cold-weather-batteries" }
    ],
    "images": [
      {
        "url": "https://example.com/images/bat-agm-h6.jpg",
        "label": "ProStart AGM H6 Battery",
        "roles": ["BASE", "THUMBNAIL"]
      }
    ]
  }
]'
echo ""
echo ""

echo "==> All 8 requests complete."
