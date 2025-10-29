#!/bin/bash
#
# RunArt Foundry - Global Cache Purge
# Purges all caches: WordPress, opcache, transients, rewrite rules
#

set -e

STAGING_PATH="/kunden/homepages/26/d958591612/htdocs/staging"
WP_CLI="wp --allow-root --path=${STAGING_PATH}"

echo "============================================================"
echo "RunArt Foundry - Global Cache Purge"
echo "============================================================"
echo ""

echo "[$(date +%H:%M:%S)] 1. Flushing WordPress cache..."
${WP_CLI} cache flush 2>&1 && echo "   ✓ WordPress cache flushed" || echo "   ✗ Failed to flush WP cache"

echo ""
echo "[$(date +%H:%M:%S)] 2. Deleting all transients..."
TRANSIENT_COUNT=$(${WP_CLI} transient delete --all 2>&1 | grep -oP '\d+(?= transients)' || echo "0")
echo "   ✓ Deleted ${TRANSIENT_COUNT} transients"

echo ""
echo "[$(date +%H:%M:%S)] 3. Flushing rewrite rules..."
${WP_CLI} rewrite flush --hard 2>&1 && echo "   ✓ Rewrite rules flushed" || echo "   ✗ Failed to flush rewrite rules"

echo ""
echo "[$(date +%H:%M:%S)] 4. Attempting opcache reset..."
${WP_CLI} eval 'if (function_exists("opcache_reset")) { opcache_reset(); echo "✓ OPcache reset\n"; } else { echo "⚠ OPcache not available\n"; }' 2>&1

echo ""
echo "[$(date +%H:%M:%S)] 5. Clearing Polylang cache..."
${WP_CLI} eval 'if (function_exists("PLL")) { PLL()->cache->clean("languages"); echo "✓ Polylang cache cleared\n"; } else { echo "⚠ Polylang cache function not available\n"; }' 2>&1

echo ""
echo "[$(date +%H:%M:%S)] 6. Regenerating Polylang rewrites..."
${WP_CLI} eval 'if (function_exists("flush_rewrite_rules")) { flush_rewrite_rules(true); echo "✓ Rewrite rules regenerated\n"; }' 2>&1

echo ""
echo "============================================================"
echo "[$(date +%H:%M:%S)] Cache purge completed"
echo "============================================================"
echo ""
echo "Next steps:"
echo "  1. Clear browser cache (Ctrl+Shift+R or Cmd+Shift+R)"
echo "  2. Test URLs without ?nocache parameter:"
echo "     • /projects/"
echo "     • /es/proyectos/"
echo "     • /services/"
echo "     • /es/servicios/"
echo "     • /testimonials/"
echo "     • /es/testimonios/"
echo ""
