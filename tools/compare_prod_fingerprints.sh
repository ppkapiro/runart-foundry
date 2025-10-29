#!/usr/bin/env bash
# Download production content and compare fingerprints

set -euo pipefail

FORENSICS_DIR="docs/_meta/_deploy_forensics"

echo "📥 Downloading production files with Access auth..."

# Verificar que tengamos los secretos (workflow context)
if [[ -z "${CF_CLIENT_ID:-}" || -z "${CF_CLIENT_SECRET:-}" ]]; then
    echo "❌ ERROR: CF_CLIENT_ID y CF_CLIENT_SECRET deben estar configurados"
    exit 1
fi

# Descargar index.html de producción
curl -sS \
    -H "CF-Access-Client-Id: $CF_CLIENT_ID" \
    -H "CF-Access-Client-Secret: $CF_CLIENT_SECRET" \
    https://runart-foundry.pages.dev/index.html \
    -o "$FORENSICS_DIR/prod_index.html"

echo "✅ Downloaded index.html ($(wc -c < "$FORENSICS_DIR/prod_index.html") bytes)"

# Descargar status/index.html
curl -sS \
    -H "CF-Access-Client-Id: $CF_CLIENT_ID" \
    -H "CF-Access-Client-Secret: $CF_CLIENT_SECRET" \
    https://runart-foundry.pages.dev/status/index.html \
    -o "$FORENSICS_DIR/prod_status_index.html"

echo "✅ Downloaded status/index.html ($(wc -c < "$FORENSICS_DIR/prod_status_index.html") bytes)"

# Calcular fingerprints de producción
sha1sum "$FORENSICS_DIR/prod_index.html" > "$FORENSICS_DIR/prod_fingerprints.txt"
sha1sum "$FORENSICS_DIR/prod_status_index.html" >> "$FORENSICS_DIR/prod_fingerprints.txt"

echo "---"
echo "📊 Production fingerprints:"
cat "$FORENSICS_DIR/prod_fingerprints.txt"

echo "---"
echo "📊 Local fingerprints:"
cat "$FORENSICS_DIR/local_fingerprints.txt"

echo "---"
echo "🔍 Comparing..."

LOCAL_INDEX_SHA=$(awk '{print $1}' "$FORENSICS_DIR/local_fingerprints.txt" | head -1)
PROD_INDEX_SHA=$(awk '{print $1}' "$FORENSICS_DIR/prod_fingerprints.txt" | head -1)

LOCAL_STATUS_SHA=$(awk '{print $1}' "$FORENSICS_DIR/local_fingerprints.txt" | tail -1)
PROD_STATUS_SHA=$(awk '{print $1}' "$FORENSICS_DIR/prod_fingerprints.txt" | tail -1)

{
    echo "# Fingerprint Comparison"
    echo ""
    echo "## index.html"
    echo "- Local:  $LOCAL_INDEX_SHA"
    echo "- Prod:   $PROD_INDEX_SHA"
    if [[ "$LOCAL_INDEX_SHA" == "$PROD_INDEX_SHA" ]]; then
        echo "- Result: ✅ MATCH"
    else
        echo "- Result: ❌ MISMATCH"
    fi
    echo ""
    echo "## status/index.html"
    echo "- Local:  $LOCAL_STATUS_SHA"
    echo "- Prod:   $PROD_STATUS_SHA"
    if [[ "$LOCAL_STATUS_SHA" == "$PROD_STATUS_SHA" ]]; then
        echo "- Result: ✅ MATCH"
    else
        echo "- Result: ❌ MISMATCH"
    fi
} > "$FORENSICS_DIR/fingerprint_diff.txt"

cat "$FORENSICS_DIR/fingerprint_diff.txt"

echo "---"
echo "📝 Results saved to $FORENSICS_DIR/fingerprint_diff.txt"
