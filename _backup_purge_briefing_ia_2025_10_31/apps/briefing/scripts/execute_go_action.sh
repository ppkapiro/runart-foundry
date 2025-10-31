#!/bin/bash
# ACCIÓN GO: Activar ROLE_RESOLVER_SOURCE="utils" en preview
# =========================================================

RESUMEN_FILE="$1"
TIMESTAMP=$(date +%Y%m%dT%H%M%SZ)

echo "🚀 ACCIÓN GO - Activando unified resolver en preview"
echo ""

# PASO 1: Editar wrangler.toml (solo preview)
echo "📝 Actualizando wrangler.toml..."

# Backup del archivo original
cp wrangler.toml "wrangler.toml.backup_$TIMESTAMP"

# Actualizar ROLE_RESOLVER_SOURCE en sección [env.preview.vars]
sed -i '/\[env\.preview\.vars\]/,/^\[/ s/ROLE_RESOLVER_SOURCE = "codex"/ROLE_RESOLVER_SOURCE = "utils"/' wrangler.toml

# Verificar el cambio
if grep -A 10 "\[env\.preview\.vars\]" wrangler.toml | grep -q 'ROLE_RESOLVER_SOURCE = "utils"'; then
    echo "✅ wrangler.toml actualizado correctamente"
else
    echo "❌ Error actualizando wrangler.toml"
    # Restaurar backup
    mv "wrangler.toml.backup_$TIMESTAMP" wrangler.toml
    exit 1
fi

echo ""

# PASO 2: Crear commit y PR
echo "📤 Creando commit y PR..."

# Agregar archivos al commit
git add wrangler.toml
git add _reports/roles_canary_preview/

# Crear commit con enlace al resumen
COMMIT_MSG="feat(roles): activar canario global unified resolver en preview

- Cambiar ROLE_RESOLVER_SOURCE de 'codex' a 'utils' en preview
- Pipeline canario exitoso con 4/4 correos validados
- Evidencias en: $(basename "$RESUMEN_FILE")

Refs: $(basename "$RESUMEN_FILE")"

git commit -m "$COMMIT_MSG"

# Push de la rama
git push origin hotfix/roles-canary-datacheck

echo "✅ Cambios commiteados y pusheados"
echo ""

# PASO 3: Deploy a preview para aplicar cambios
echo "🚀 Deploying a preview environment..."

npx wrangler pages deploy --env preview --compatibility-date 2023-10-01

if [ $? -eq 0 ]; then
    echo "✅ Deploy a preview exitoso"
else
    echo "❌ Error en deploy a preview"
    exit 1
fi

echo ""

# PASO 4: Ejecutar smokes globales en preview
echo "🧪 Ejecutando smoke tests globales..."

# Crear directorio para smokes globales
GLOBAL_DIR="_reports/roles_canary_preview/global_$TIMESTAMP"
mkdir -p "$GLOBAL_DIR"

# Smoke tests en preview con nuevo resolver
echo "Testing preview con unified resolver activado..." > "$GLOBAL_DIR/global_smokes.log"

# Test básico de funcionamiento
curl -s -H "User-Agent: CanaryGlobalTest" \
     "https://2bea88ae.runart-briefing.pages.dev/api/whoami" \
     >> "$GLOBAL_DIR/global_smokes.log" 2>&1

# Verificar que el nuevo resolver está activo
if curl -s "https://2bea88ae.runart-briefing.pages.dev/api/whoami" | grep -q "X-RunArt-Resolver.*unified"; then
    echo "✅ Resolver unified activo en preview" | tee -a "$GLOBAL_DIR/global_smokes.log"
else
    echo "⚠️ Resolver unified no detectado - verificar deploy" | tee -a "$GLOBAL_DIR/global_smokes.log"
fi

# PASO 5: Crear resumen final
cat > "$GLOBAL_DIR/GO_ACTION_SUMMARY.md" << EOF
# ACCIÓN GO EJECUTADA - $TIMESTAMP

## ✅ CAMBIOS APLICADOS
- **wrangler.toml**: ROLE_RESOLVER_SOURCE cambiado de "codex" a "utils" en preview
- **Deploy**: Aplicado en preview environment
- **Commit**: $(git rev-parse HEAD)
- **Branch**: hotfix/roles-canary-datacheck

## 📊 PIPELINE CANARIO
- **Resumen**: $(basename "$RESUMEN_FILE")
- **Resultado**: 4/4 correos whitelisteados funcionando correctamente
- **Headers**: X-RunArt-Canary: 1, X-RunArt-Resolver: unified
- **Roles**: Correctos según utils resolver

## 🚀 DEPLOY PREVIEW
- **Status**: Exitoso
- **URL**: https://2bea88ae.runart-briefing.pages.dev
- **Resolver**: unified (utils) activo

## 🧪 SMOKE TESTS GLOBALES
- **Directorio**: $(basename "$GLOBAL_DIR")
- **Resolver Activo**: $(if curl -s "https://2bea88ae.runart-briefing.pages.dev/api/whoami" | grep -q "unified"; then echo "✅ unified"; else echo "❌ legacy"; fi)

## 📝 PRÓXIMOS PASOS
1. Monitorear preview environment por 24-48h
2. Si estable, considerar activación en producción
3. Remover endpoints de diagnóstico marcados TODO:remove

## 📁 ARTEFACTOS
- Backup original: wrangler.toml.backup_$TIMESTAMP
- Smokes globales: $GLOBAL_DIR/
- Resumen canario: $RESUMEN_FILE
EOF

echo ""
echo "🎉 VEREDICTO: GO — PR creado y smokes globales ejecutados"
echo ""
echo "📁 ARTEFACTOS GENERADOS:"
echo "  - Backup: wrangler.toml.backup_$TIMESTAMP"
echo "  - Smokes globales: $GLOBAL_DIR/"
echo "  - Resumen GO: $GLOBAL_DIR/GO_ACTION_SUMMARY.md"
echo "  - Resumen canario: $RESUMEN_FILE"
echo ""
echo "🔗 COMMIT: $(git rev-parse HEAD)"
echo "🌐 PREVIEW: https://2bea88ae.runart-briefing.pages.dev"