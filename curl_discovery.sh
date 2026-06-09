#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Adobe Commerce Optimizer - Discovery GraphQL API
# ---------------------------------------------------------------------------
# Fill in the required values below, then run:
#   chmod +x curl_discovery.sh && ./curl_discovery.sh
# Prints the assembled curl commands - copy and run them directly.
# ---------------------------------------------------------------------------

TENANT_ID="YOUR_TENANT_IDaaa"
REGION="na1"
ENVIRONMENT="sandbox"          # set to "" for production
PRICE_BOOK_ID="YOUR_PRICE_BOOK_ID"
SCOPE_LOCALE="YOUR_LOCALE"     # e.g. "en-US"
VIEW_ID="YOUR_VIEW_IDwww"
FAMILY="parts-catalog"         # e.g. "parts-catalog" or "seasonal-catalog"

# Derived URLs
if [[ -n "$ENVIRONMENT" ]]; then
  BASE_URL="https://${REGION}-${ENVIRONMENT}.api.commerce.adobe.com"
else
  BASE_URL="https://${REGION}.api.commerce.adobe.com"
fi

GRAPHQL_URL="${BASE_URL}/${TENANT_ID}/graphql"

# ---------------------------------------------------------------------------
# 1. Navigation Query
# ---------------------------------------------------------------------------
echo "==> 1. Navigation Query - ${FAMILY}"
cat <<EOF
curl --request POST \\
  --url '${GRAPHQL_URL}' \\
  --header 'Content-Type: application/json' \\
  --header 'AC-ENVIRONMENT-Id: ${TENANT_ID}' \\
  --header 'AC-Price-Book-ID: ${PRICE_BOOK_ID}' \\
  --header 'AC-Scope-Locale: ${SCOPE_LOCALE}' \\
  --header 'ac-view-id: ${VIEW_ID}' \\
  --data '{
  "query": "query Navigation(\$family: String!) {\n  navigation(family: \$family) {\n    slug\n    name\n    children {\n      slug\n      name\n      children {\n        slug\n        name\n        children {\n          name\n        }\n      }\n    }\n  }\n}",
  "operationName": "Navigation",
  "variables": {
    "family": "${FAMILY}"
  }
}'
EOF
echo ""

# ---------------------------------------------------------------------------
# 2. Category Tree Query
# ---------------------------------------------------------------------------
CATEGORY_SLUGS='[]'   # filter by slugs, e.g. '["brakes","suspension"]', or [] for all
CATEGORY_DEPTH=5      # max depth to return (1-5)

echo "==> 2. Category Tree Query - ${FAMILY} (depth: ${CATEGORY_DEPTH})"
cat <<EOF
curl --request POST \\
  --url '${GRAPHQL_URL}' \\
  --header 'Content-Type: application/json' \\
  --header 'AC-ENVIRONMENT-Id: ${TENANT_ID}' \\
  --header 'AC-Scope-Locale: ${SCOPE_LOCALE}' \\
  --data '{
  "query": "query CategoriesTree(\$family: String!, \$slugs: [String!], \$depth: Int) {\n  categoryTree(family: \$family, slugs: \$slugs, depth: \$depth) {\n    slug\n    name\n    level\n    parentSlug\n    childrenSlugs\n    metaTags {\n      title\n    }\n    images {\n      roles\n      customRoles\n      url\n    }\n  }\n}",
  "operationName": "CategoriesTree",
  "variables": {
    "slugs": ${CATEGORY_SLUGS},
    "family": "${FAMILY}",
    "depth": ${CATEGORY_DEPTH}
  }
}'
EOF
echo ""
