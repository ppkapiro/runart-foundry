#!/bin/bash
#
# Script para configurar SSH key en GitHub y hacer push del bootstrap
# Ejecutar: bash setup_ssh_and_push.sh
#

set -euo pipefail

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 Configuración SSH para GitHub"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verificar si la llave SSH ya está configurada
echo "🔍 Verificando conexión SSH con GitHub..."
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "✅ SSH ya está configurado correctamente"
else
    echo "⚠️  SSH no está configurado aún"
    echo ""
    echo "Tu llave pública SSH es:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat ~/.ssh/id_ed25519.pub
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Por favor, agrega esta llave en GitHub:"
    echo "1. Abre: https://github.com/settings/ssh/new"
    echo "2. Title: RunArt laptop"
    echo "3. Key: (copia la llave de arriba)"
    echo "4. Haz clic en 'Add SSH key'"
    echo ""
    read -p "Presiona ENTER cuando hayas agregado la llave..."
    
    # Verificar nuevamente
    echo ""
    echo "🔍 Verificando conexión SSH..."
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        echo "✅ ¡SSH configurado correctamente!"
    else
        echo "❌ SSH sigue sin funcionar. Por favor verifica la configuración."
        exit 1
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📤 Haciendo push de la rama chore/bootstrap-git"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verificar que estamos en la rama correcta
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "chore/bootstrap-git" ]; then
    echo "⚠️  No estás en la rama chore/bootstrap-git, cambiando..."
    git checkout chore/bootstrap-git
fi

# Verificar remote
echo "🔍 Verificando remote..."
git remote -v | grep origin

# Hacer push
echo ""
echo "🚀 Haciendo push..."
git push -u origin chore/bootstrap-git

echo ""
echo "✅ Push completado exitosamente!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Creando Pull Request"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Crear PR usando gh CLI
gh pr create \
  -B main \
  -H chore/bootstrap-git \
  --title "chore(bootstrap): estructura monorepo + guardarraíles + política MIRROR" \
  --body "## 🎯 Objetivo

Bootstrap inicial del monorepo con:

- ✅ Estructura de carpetas confirmada (briefing/, audits/, mirror/, docs/, scripts/)
- ✅ Guardarraíles automáticos (CI workflow + validation script + Git hooks)
- ✅ Política MIRROR implementada (plantillas sin payload, gitignored)
- ✅ CODEOWNERS configurado (@ppkapiro)
- ✅ PR template con checklist de gobernanza
- ✅ Reportes organizados en carpetas designadas

## 📦 Contenido del PR

### Guardarraíles implementados
- \`.github/workflows/structure-guard.yml\` - CI validation en PR y push
- \`scripts/validate_structure.sh\` - Script de validación (4 reglas)
- \`.githooks/pre-commit\` - Hook local de validación
- \`.githooks/prepare-commit-msg\` - Sugerencia de prefijos de módulo

### Configuración
- \`.github/CODEOWNERS\` - @ppkapiro en todos los módulos
- \`.github/PULL_REQUEST_TEMPLATE.md\` - Checklist de gobernanza
- \`.gitignore\` - Exclusiones (mirror/raw/**, .venv, builds, logs)
- \`.gitattributes\` - Normalización LF

### Política MIRROR
- \`mirror/README.md\` - Documentación de la política (no payload)
- \`mirror/index.json\` - Metadata del snapshot 2025-10-01
- \`mirror/scripts/fetch.sh\` - Plantilla comentada

### Documentación
- \`docs/proyecto_estructura_y_gobernanza.md\` - Documento maestro actualizado
- \`docs/_artifacts/repo_tree.txt\` - Árbol del proyecto regenerado

### Reorganización
- Reportes movidos a \`audits/reports/\` y \`briefing/_reports/\`
- README.md actualizado con sección de guardarraíles

## 🔍 Validación

El script de validación reporta:
- ⚠️  5 warnings (scripts en root - recomendación no bloqueante)
- ✅ 0 errors

## 📋 Checklist

- [x] Ningún archivo supera los límites de tamaño
- [x] Reportes en carpetas designadas
- [x] MIRROR sin payload (gitignored)
- [x] Hooks locales activados
- [x] CI configurado
- [x] Documentación actualizada

## 🎯 Próximos pasos post-merge

1. Activar branch protection en \`main\`
2. (Opcional) Mover scripts de root a \`scripts/\`"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ ¡Proceso completado!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔗 Ver PR en el navegador:"
gh pr view --web

echo ""
echo "📊 Información del PR:"
gh pr view

echo ""
echo "✅ El workflow 'Structure & Governance Guard' se ejecutará automáticamente"
echo "✅ Una vez aprobado, puedes hacer merge del PR"
echo ""
