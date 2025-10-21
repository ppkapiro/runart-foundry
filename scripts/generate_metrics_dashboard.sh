#!/usr/bin/env bash
# Dashboard de métricas — Tendencias de health checks y smoke tests
# Genera visualizaciones ASCII de métricas históricas

set -euo pipefail

echo "=== 📊 Generando Dashboard de Métricas ==="

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

METRICS_DIR="_reports/metrics"
mkdir -p "$METRICS_DIR"

OUTPUT_FILE="$METRICS_DIR/README.md"

# Función para calcular promedio
calc_avg() {
    local sum=0
    local count=0
    while read -r val; do
        if [[ "$val" =~ ^[0-9]+$ ]]; then
            sum=$((sum + val))
            count=$((count + 1))
        fi
    done
    if [ "$count" -gt 0 ]; then
        echo $((sum / count))
    else
        echo "0"
    fi
}

# Función para generar gráfico ASCII simple
ascii_bar() {
    local value=$1
    local max=$2
    local width=50
    local filled=$((value * width / max))
    local empty=$((width - filled))
    
    printf "["
    for ((i=0; i<filled; i++)); do printf "█"; done
    for ((i=0; i<empty; i++)); do printf "░"; done
    printf "] %d/%d\n" "$value" "$max"
}

# Analizar health checks
echo "Analizando health checks..."
HEALTH_DIR="_reports/health"
HEALTH_COUNT=0
HEALTH_OK=0
HEALTH_FAIL=0
RESPONSE_TIMES=()

if [ -d "$HEALTH_DIR" ]; then
    HEALTH_COUNT=$(find "$HEALTH_DIR" -name "health_*.md" 2>/dev/null | wc -l)
    
    # Contar OK vs FAIL
    for file in "$HEALTH_DIR"/health_*.md; do
        if [ -f "$file" ]; then
            if grep -q "OK" "$file"; then
                HEALTH_OK=$((HEALTH_OK + 1))
            else
                HEALTH_FAIL=$((HEALTH_FAIL + 1))
            fi
            
            # Extraer tiempo de respuesta si existe
            RT=$(grep "Response Time:" "$file" 2>/dev/null | sed 's/.*: \([0-9]*\)ms.*/\1/' || echo "")
            if [[ "$RT" =~ ^[0-9]+$ ]]; then
                RESPONSE_TIMES+=("$RT")
            fi
        fi
    done
fi

# Calcular promedio de tiempos de respuesta
if [ ${#RESPONSE_TIMES[@]} -gt 0 ]; then
    AVG_RESPONSE=$(printf "%s\n" "${RESPONSE_TIMES[@]}" | calc_avg)
else
    AVG_RESPONSE=0
fi

# Analizar smoke tests
echo "Analizando smoke tests..."
SMOKES_DIR="_reports/smokes"
SMOKES_COUNT=0
SMOKES_PASS=0
SMOKES_WARN=0
SMOKES_FAIL=0

if [ -d "$SMOKES_DIR" ]; then
    SMOKES_COUNT=$(find "$SMOKES_DIR" -name "smoke_*.md" 2>/dev/null | wc -l)
    
    for file in "$SMOKES_DIR"/smoke_*.md; do
        if [ -f "$file" ]; then
            if grep -q "PASS ✅" "$file"; then
                SMOKES_PASS=$((SMOKES_PASS + 1))
            elif grep -q "WARN ⚠️" "$file"; then
                SMOKES_WARN=$((SMOKES_WARN + 1))
            elif grep -q "FAIL ❌" "$file"; then
                SMOKES_FAIL=$((SMOKES_FAIL + 1))
            fi
        fi
    done
fi

# Generar README.md
cat > "$OUTPUT_FILE" <<EOF
# 📊 Dashboard de Métricas — RUN Art Foundry Staging

**Última actualización:** $(date)  
**Entorno:** https://staging.runartfoundry.com

---

## 🩺 Health Checks

### Resumen
- **Total ejecutados:** $HEALTH_COUNT
- **Exitosos (OK):** $HEALTH_OK
- **Fallidos:** $HEALTH_FAIL
- **Tasa de éxito:** $([ "$HEALTH_COUNT" -gt 0 ] && echo "$((HEALTH_OK * 100 / HEALTH_COUNT))%" || echo "N/A")

### Disponibilidad
$(ascii_bar "$HEALTH_OK" "$HEALTH_COUNT")

### Rendimiento
- **Tiempo de respuesta promedio:** ${AVG_RESPONSE}ms
- **Últimos tiempos registrados:**
EOF

# Añadir últimos 5 tiempos de respuesta
if [ ${#RESPONSE_TIMES[@]} -gt 0 ]; then
    echo "  \`\`\`" >> "$OUTPUT_FILE"
    printf "  %s\n" "${RESPONSE_TIMES[@]: -5}" | while read -r rt; do
        echo "  ${rt}ms" >> "$OUTPUT_FILE"
    done
    echo "  \`\`\`" >> "$OUTPUT_FILE"
else
    echo "  *No hay datos de tiempos de respuesta*" >> "$OUTPUT_FILE"
fi

cat >> "$OUTPUT_FILE" <<EOF

---

## 🧪 Smoke Tests (Content Validation)

### Resumen
- **Total ejecutados:** $SMOKES_COUNT
- **Passed (✅):** $SMOKES_PASS
- **Warnings (⚠️):** $SMOKES_WARN
- **Failed (❌):** $SMOKES_FAIL

### Distribución
EOF

if [ "$SMOKES_COUNT" -gt 0 ]; then
    echo "- **PASS:** $(ascii_bar "$SMOKES_PASS" "$SMOKES_COUNT")" >> "$OUTPUT_FILE"
    echo "- **WARN:** $(ascii_bar "$SMOKES_WARN" "$SMOKES_COUNT")" >> "$OUTPUT_FILE"
    echo "- **FAIL:** $(ascii_bar "$SMOKES_FAIL" "$SMOKES_COUNT")" >> "$OUTPUT_FILE"
else
    echo "*No hay smoke tests ejecutados todavía*" >> "$OUTPUT_FILE"
fi

cat >> "$OUTPUT_FILE" <<EOF

---

## 📈 Tendencias

### Health Checks (Últimos 7 días)
EOF

# Generar mini-gráfico de tendencia (últimos 7 health checks)
RECENT_HEALTH=$(find "$HEALTH_DIR" -name "health_*.md" 2>/dev/null | sort -r | head -7 | sort)
if [ -n "$RECENT_HEALTH" ]; then
    echo "\`\`\`" >> "$OUTPUT_FILE"
    echo "$RECENT_HEALTH" | while read -r file; do
        DATE=$(basename "$file" .md | sed 's/health_//')
        if grep -q "OK" "$file"; then
            echo "$DATE: ✅ OK" >> "$OUTPUT_FILE"
        else
            echo "$DATE: ❌ FAIL" >> "$OUTPUT_FILE"
        fi
    done
    echo "\`\`\`" >> "$OUTPUT_FILE"
else
    echo "*No hay datos suficientes*" >> "$OUTPUT_FILE"
fi

cat >> "$OUTPUT_FILE" <<EOF

### Smoke Tests (Últimos 7 días)
EOF

# Generar mini-gráfico de tendencia (últimos 7 smoke tests)
if [ -d "$SMOKES_DIR" ]; then
    RECENT_SMOKES=$(find "$SMOKES_DIR" -name "smoke_*.md" 2>/dev/null | sort -r | head -7 | sort)
    if [ -n "$RECENT_SMOKES" ]; then
        echo "\`\`\`" >> "$OUTPUT_FILE"
        echo "$RECENT_SMOKES" | while read -r file; do
            DATE=$(basename "$file" .md | sed 's/smoke_//')
            if grep -q "PASS ✅" "$file"; then
                echo "$DATE: ✅ PASS" >> "$OUTPUT_FILE"
            elif grep -q "WARN ⚠️" "$file"; then
                echo "$DATE: ⚠️  WARN" >> "$OUTPUT_FILE"
            else
                echo "$DATE: ❌ FAIL" >> "$OUTPUT_FILE"
            fi
        done
        echo "\`\`\`" >> "$OUTPUT_FILE"
    else
        echo "*No hay datos suficientes*" >> "$OUTPUT_FILE"
    fi
else
    echo "*Smoke tests no configurados todavía*" >> "$OUTPUT_FILE"
fi

cat >> "$OUTPUT_FILE" <<EOF

---

## 🎯 Objetivos y SLAs

### Disponibilidad
- **Objetivo:** 99.9% uptime
- **Actual:** $([ "$HEALTH_COUNT" -gt 0 ] && echo "$((HEALTH_OK * 100 / HEALTH_COUNT))%" || echo "N/A")
- **Estado:** $([ "$HEALTH_COUNT" -gt 0 ] && [ "$((HEALTH_OK * 100 / HEALTH_COUNT))" -ge 99 ] && echo "✅ Cumpliendo" || echo "⚠️  Revisar")

### Rendimiento
- **Objetivo:** < 500ms tiempo de respuesta
- **Actual:** ${AVG_RESPONSE}ms
- **Estado:** $([ "$AVG_RESPONSE" -lt 500 ] && echo "✅ Cumpliendo" || echo "⚠️  Revisar")

### Content Validation
- **Objetivo:** 100% PASS en smoke tests
- **Actual:** $([ "$SMOKES_COUNT" -gt 0 ] && echo "$((SMOKES_PASS * 100 / SMOKES_COUNT))% PASS" || echo "N/A")
- **Estado:** $([ "$SMOKES_COUNT" -gt 0 ] && [ "$SMOKES_PASS" -eq "$SMOKES_COUNT" ] && echo "✅ Cumpliendo" || echo "⚠️  Revisar")

---

## 📁 Archivos de Referencia

- **Health Checks:** \`_reports/health/\`
- **Smoke Tests:** \`_reports/smokes/\`
- **Índice de Reportes:** \`_reports/INDEX.md\`
- **Handoff Document:** \`docs/HANDOFF_FASE10.md\`

---

*Dashboard generado automáticamente por \`scripts/generate_metrics_dashboard.sh\`*  
*Última ejecución: $(date)*
EOF

echo "✅ Dashboard generado: $OUTPUT_FILE"
echo ""
cat "$OUTPUT_FILE"
