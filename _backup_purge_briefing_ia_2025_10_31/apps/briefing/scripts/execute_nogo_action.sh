#!/bin/bash
# ACCIÓN NO-GO: Conservar legacy y documentar incident
# ==================================================

RESUMEN_FILE="$1"
TIMESTAMP=$(date +%Y%m%dT%H%M%SZ)

echo "❌ ACCIÓN NO-GO - Documentando incident y conservando legacy resolver"
echo ""

# PASO 1: Crear carpeta de incident
echo "📁 Creando carpeta de incident..."

INCIDENT_DIR="_reports/roles_canary_preview/INCIDENT_$TIMESTAMP"
mkdir -p "$INCIDENT_DIR"

echo "✅ Carpeta creada: $INCIDENT_DIR"
echo ""

# PASO 2: Copiar evidencias
echo "📄 Copiando evidencias del incident..."

# Copiar resumen principal
cp "$RESUMEN_FILE" "$INCIDENT_DIR/"

# Copiar otros artefactos del pipeline
cp _reports/kv_snapshot_preview_*.json "$INCIDENT_DIR/" 2>/dev/null || echo "⚠️ No se encontraron snapshots KV"
cp _reports/kv_audit_preview_*.md "$INCIDENT_DIR/" 2>/dev/null || echo "⚠️ No se encontraron audits KV"
cp _reports/canary_allowlist_cmd_*.txt "$INCIDENT_DIR/" 2>/dev/null || echo "⚠️ No se encontraron comandos allowlist"

# Copiar smokes si existen
if [ -d "_reports/roles_canary_preview/smokes_"* ]; then
    cp -r _reports/roles_canary_preview/smokes_* "$INCIDENT_DIR/" 2>/dev/null
fi

echo "✅ Evidencias copiadas"
echo ""

# PASO 3: Analizar failures del resumen
echo "🔍 Analizando failures..."

# Extraer información de fallos
FAILED_EMAILS=$(grep -A 5 -B 5 "❌.*FALLO" "$RESUMEN_FILE" 2>/dev/null || echo "No se detectaron fallos específicos")
HEADERS_ISSUES=$(grep -A 3 -B 3 "X-RunArt-" "$RESUMEN_FILE" | grep -v "✅" 2>/dev/null || echo "Headers no disponibles")

# PASO 4: Crear análisis del incident
cat > "$INCIDENT_DIR/INCIDENT_ANALYSIS.md" << EOF
# INCIDENT ANALYSIS - CANARY NO-GO
**Timestamp:** $TIMESTAMP  
**Pipeline:** Canary por Whitelist  
**Veredicto:** NO-GO ❌

## RESUMEN DEL FALLO
El pipeline canario detectó inconsistencias que impiden la activación del unified resolver en preview.

## EVIDENCIAS RECOPILADAS
- **Resumen principal:** $(basename "$RESUMEN_FILE")
- **Snapshot KV:** $(ls _reports/kv_snapshot_preview_*.json 2>/dev/null | tail -1 | xargs basename)
- **Audit KV:** $(ls _reports/kv_audit_preview_*.md 2>/dev/null | tail -1 | xargs basename)
- **Smokes:** $(ls -d _reports/roles_canary_preview/smokes_* 2>/dev/null | tail -1 | xargs basename)

## EMAILS AFECTADOS
\`\`\`
$FAILED_EMAILS
\`\`\`

## HEADERS OBSERVADOS
\`\`\`
$HEADERS_ISSUES
\`\`\`

## POSIBLES CAUSAS
1. **Inconsistencia en KV data**: Roles en namespace preview diferentes a los esperados
2. **Cache issues**: Headers cacheados del resolver anterior
3. **Configuración ENV**: Variables de entorno incorrectas en preview
4. **Race conditions**: Whitelist no aplicada correctamente antes de smokes

## PASOS DE CORRECCIÓN PROPUESTOS
1. **Verificar KV data integrity**: Comparar snapshot con datos esperados
2. **Cache purge**: Limpiar cache de Cloudflare para preview domain
3. **ENV audit**: Revisar todas las variables de entorno en preview
4. **Timing fix**: Añadir delays entre whitelist setup y smoke tests
5. **Rollback prevention**: Asegurar que legacy resolver permanezca activo

## IMPACTO
- ✅ **Producción**: No afectada (legacy resolver permanece)
- ✅ **Preview**: Conserva legacy resolver (no regression)
- ❌ **Canary**: Unified resolver no validado para activación

## PRÓXIMOS PASOS
1. Investigar root cause usando evidencias en este directorio
2. Implementar fixes específicos identificados
3. Re-ejecutar pipeline canario tras correcciones
4. Documentar lessons learned

---
**Status:** INCIDENT DOCUMENTED  
**Action Required:** Root cause analysis + fixes  
**Timeline:** TBD based on investigation results
EOF

echo "✅ Análisis del incident creado"
echo ""

# PASO 5: Verificar que wrangler.toml NO fue modificado
echo "🔒 Verificando integridad de wrangler.toml..."

if grep -A 10 "\[env\.preview\.vars\]" wrangler.toml | grep -q 'ROLE_RESOLVER_SOURCE = "codex"'; then
    echo "✅ wrangler.toml conserva configuración legacy (correcto)"
elif grep -A 10 "\[env\.preview\.vars\]" wrangler.toml | grep -q 'ROLE_RESOLVER_SOURCE = "lib"'; then
    echo "✅ wrangler.toml conserva configuración legacy (lib - correcto)"
else
    echo "⚠️ Configuración de wrangler.toml no es la esperada - verificar manualmente"
fi

echo ""

# PASO 6: Preparar issue GitHub (template)
cat > "$INCIDENT_DIR/GITHUB_ISSUE_TEMPLATE.md" << EOF
# 🐛 fix(roles): resolver unified discrepancias en preview

## Descripción
El pipeline canario detectó inconsistencias en el unified resolver que impiden su activación en preview.

## Evidencias
- **Incident folder:** \`$INCIDENT_DIR/\`
- **Pipeline timestamp:** $TIMESTAMP
- **Resumen:** $(basename "$RESUMEN_FILE")

## Correos Afectados
$FAILED_EMAILS

## Headers Observados
$HEADERS_ISSUES

## Root Cause Hipótesis
- [ ] KV data integrity issues en preview namespace
- [ ] Cache de headers del resolver anterior
- [ ] Variables de entorno incorrectas
- [ ] Race condition en whitelist setup
- [ ] Otro: _______________

## Pasos de Reproducción
1. Ejecutar pipeline canario: \`scripts/run_canary_real.sh\`
2. Revisar resumen generado
3. Observar failures en smoke tests

## Criterio de Aceptación
- [ ] 4/4 correos whitelisteados muestran \`X-RunArt-Canary: 1\` + \`X-RunArt-Resolver: unified\`
- [ ] Correos NO whitelisteados muestran \`X-RunArt-Resolver: legacy\`
- [ ] Roles extraídos coinciden con utils resolver
- [ ] Cero ascensos indebidos a owner/admin

## Archivos Relacionados
- \`apps/briefing/wrangler.toml\` (conservar SRC=codex/lib)
- \`apps/briefing/scripts/canary_pipeline.mjs\`
- \`apps/briefing/_reports/roles_canary_preview/\`

---
**Priority:** High  
**Labels:** bug, roles, resolver, preview  
**Assignee:** @ppkapiro
EOF

echo "✅ Template de GitHub issue creado"
echo ""

# PASO 7: Crear script para abrir issue
cat > "$INCIDENT_DIR/create_github_issue.sh" << 'EOF'
#!/bin/bash
# Script para crear GitHub issue del incident

ISSUE_FILE="GITHUB_ISSUE_TEMPLATE.md"

echo "🐛 Creando GitHub issue..."
echo ""
echo "OPCIÓN 1 - GitHub CLI (si está instalado):"
echo "  gh issue create --title \"fix(roles): resolver unified discrepancias en preview\" --body-file \"$ISSUE_FILE\""
echo ""
echo "OPCIÓN 2 - Manual:"
echo "  1. Ir a https://github.com/ppkapiro/runart-foundry/issues/new"
echo "  2. Copiar contenido de: $ISSUE_FILE" 
echo "  3. Crear issue manualmente"
echo ""

# Intentar con GitHub CLI si está disponible
if command -v gh &> /dev/null; then
    echo "GitHub CLI detectado, creando issue..."
    gh issue create \
        --title "fix(roles): resolver unified discrepancias en preview" \
        --body-file "$ISSUE_FILE" \
        --label "bug,roles,resolver,preview"
    
    if [ $? -eq 0 ]; then
        echo "✅ Issue creado exitosamente"
    else
        echo "❌ Error creando issue con GitHub CLI - usar método manual"
    fi
else
    echo "GitHub CLI no disponible - usar método manual arriba"
fi
EOF

chmod +x "$INCIDENT_DIR/create_github_issue.sh"

echo "✅ Script para crear issue preparado"
echo ""

# PASO 8: Resumen final NO-GO
cat > "$INCIDENT_DIR/NOGO_ACTION_SUMMARY.md" << EOF
# ACCIÓN NO-GO EJECUTADA - $TIMESTAMP

## ❌ VEREDICTO
Pipeline canario falló criterios de validación - unified resolver NO activado.

## 🔒 CONFIGURACIÓN CONSERVADA
- **wrangler.toml**: ROLE_RESOLVER_SOURCE permanece en "codex"/"lib" (legacy)
- **Preview**: Continúa usando legacy resolver (sin regression)
- **Producción**: No afectada (sin cambios)

## 📁 INCIDENT DOCUMENTADO
- **Carpeta**: $INCIDENT_DIR/
- **Evidencias**: Resumen, snapshots, smokes, análisis
- **GitHub Issue**: Template preparado para creación

## 🔍 ANÁLISIS DISPONIBLE
- **Root cause**: Ver INCIDENT_ANALYSIS.md
- **Correos afectados**: Documentados con headers observados
- **Fixes propuestos**: Lista de acciones de corrección

## 📝 PRÓXIMOS PASOS
1. **Investigar**: Usar evidencias en incident folder
2. **Fijar**: Implementar correcciones identificadas  
3. **Re-test**: Ejecutar pipeline tras fixes
4. **Issue**: Crear usando create_github_issue.sh

## 🎯 CRITERIOS PARA RE-INTENTO
- 4/4 emails whitelisteados con headers correctos
- Resolver unified funcionando según especificación
- Cero regressions en funcionalidad legacy
EOF

echo ""
echo "❌ VEREDICTO: NO-GO — incident registrado"
echo ""
echo "📁 ARTEFACTOS GENERADOS:"
echo "  - Incident folder: $INCIDENT_DIR/"
echo "  - Análisis: $INCIDENT_DIR/INCIDENT_ANALYSIS.md"
echo "  - GitHub issue: $INCIDENT_DIR/GITHUB_ISSUE_TEMPLATE.md"
echo "  - Issue script: $INCIDENT_DIR/create_github_issue.sh"
echo "  - Resumen NO-GO: $INCIDENT_DIR/NOGO_ACTION_SUMMARY.md"
echo ""
echo "🔧 CREAR ISSUE:"
echo "  cd $INCIDENT_DIR && ./create_github_issue.sh"
echo ""
echo "🔒 CONFIGURACIÓN: Legacy resolver conservado (sin cambios)"