#!/bin/bash
# PASO 0: OBTENER CF_API_TOKEN SEGURO
# ====================================

echo "🔐 CONFIGURACIÓN DE CF_API_TOKEN"
echo ""
echo "OPCIÓN 1 - Variable de entorno (recomendado):"
echo "  export CF_API_TOKEN=your_cloudflare_api_token_here"
echo ""
echo "OPCIÓN 2 - PowerShell (Windows):"
echo "  \$env:CF_API_TOKEN=\"your_cloudflare_api_token_here\""
echo ""
echo "OPCIÓN 3 - Obtener desde Cloudflare Dashboard:"
echo "  1. Ir a https://dash.cloudflare.com/profile/api-tokens"
echo "  2. Crear token con permisos:"
echo "     - Zone:Zone:Read"
echo "     - Zone:Zone Settings:Edit"  
echo "     - Account:Cloudflare Workers:Edit"
echo "     - Account:Workers KV Storage:Edit"
echo "  3. Copiar token y usar OPCIÓN 1 arriba"
echo ""

# Verificar si token está disponible
if [ -z "$CF_API_TOKEN" ]; then
    echo "❌ CF_API_TOKEN no encontrado"
    echo ""
    echo "ACCIÓN REQUERIDA:"
    echo "1. Obtener token usando una de las opciones arriba"
    echo "2. Ejecutar: export CF_API_TOKEN=your_token_here"
    echo "3. Re-ejecutar este script"
    echo ""
    exit 1
else
    echo "✅ CF_API_TOKEN encontrado (${#CF_API_TOKEN} caracteres)"
    echo ""
fi

# PASO 1: EJECUTAR PIPELINE REAL
# ==============================
echo "🚀 EJECUTANDO PIPELINE CANARIO REAL"
echo ""

cd /home/pepe/work/runartfoundry/apps/briefing

# Correos representativos del snapshot auditado
OWNER_EMAIL="ppcapiro@gmail.com"
TEAM_EMAIL="team@runart.com" 
CLIENT_ADMIN_EMAIL="admin@runart.com"
CLIENT_EMAIL="client@runartfoundry.com"
HOST="https://2bea88ae.runart-briefing.pages.dev"

echo "Configuración del canario:"
echo "  Host: $HOST"
echo "  Owner: $OWNER_EMAIL"
echo "  Team: $TEAM_EMAIL"
echo "  Client Admin: $CLIENT_ADMIN_EMAIL"
echo "  Client: $CLIENT_EMAIL"
echo ""

# Ejecutar pipeline
echo "Ejecutando pipeline completo..."
node scripts/canary_pipeline.mjs \
    --host "$HOST" \
    --owner "$OWNER_EMAIL" \
    --team "$TEAM_EMAIL" \
    --client_admin "$CLIENT_ADMIN_EMAIL" \
    --client "$CLIENT_EMAIL"

PIPELINE_EXIT_CODE=$?

if [ $PIPELINE_EXIT_CODE -ne 0 ]; then
    echo "❌ Pipeline falló con código $PIPELINE_EXIT_CODE"
    exit $PIPELINE_EXIT_CODE
fi

echo ""
echo "✅ Pipeline completado exitosamente"
echo ""

# PASO 2: ENCONTRAR EL RESUMEN MÁS RECIENTE
# =========================================
echo "🔍 BUSCANDO RESUMEN GENERADO..."

# Buscar el RESUMEN más reciente
RESUMEN_FILE=$(ls -t _reports/roles_canary_preview/RESUMEN_*.md 2>/dev/null | head -1)

if [ -z "$RESUMEN_FILE" ]; then
    echo "❌ No se encontró archivo RESUMEN_*.md"
    exit 1
fi

echo "📄 Resumen encontrado: $RESUMEN_FILE"
echo ""

# Mostrar contenido del resumen para evaluación
echo "=== CONTENIDO DEL RESUMEN ==="
cat "$RESUMEN_FILE"
echo "============================"
echo ""

# PASO 3: EVALUACIÓN AUTOMÁTICA
# =============================
echo "⚖️ EVALUANDO CRITERIOS GO/NO-GO..."

# Extraer información clave del resumen
GO_DECISION="unknown"

# Verificar headers y roles (búsqueda en el contenido)
if grep -q "X-RunArt-Canary: 1.*X-RunArt-Resolver: unified" "$RESUMEN_FILE" && \
   grep -q "CRITERIO.*✅.*4/4" "$RESUMEN_FILE" && \
   ! grep -q "❌.*FALLO" "$RESUMEN_FILE"; then
    GO_DECISION="GO"
else
    GO_DECISION="NO-GO"
fi

echo "📊 VEREDICTO: $GO_DECISION"
echo ""

# Ejecutar acción correspondiente
if [ "$GO_DECISION" = "GO" ]; then
    echo "✅ EJECUTANDO ACCIÓN GO..."
    ./scripts/execute_go_action.sh "$RESUMEN_FILE"
else
    echo "❌ EJECUTANDO ACCIÓN NO-GO..."  
    ./scripts/execute_nogo_action.sh "$RESUMEN_FILE"
fi

echo ""
echo "🏁 PIPELINE CANARIO COMPLETADO"
echo "📁 Artefactos en: _reports/roles_canary_preview/"
echo "📄 Resumen final: $RESUMEN_FILE"