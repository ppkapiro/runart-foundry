#!/usr/bin/env bash
# validate_structure.sh - Guardarraíles de gobernanza del repositorio
# Valida ubicaciones de archivos, tamaños y exclusiones según docs/proyecto_estructura_y_gobernanza.md

# Colores para output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Contadores
ERRORS=0
WARNINGS=0

# Función para imprimir errores
error() {
    echo -e "${RED}❌ ERROR:${NC} $1"
    ((ERRORS++))
}

# Función para imprimir advertencias
warning() {
    echo -e "${YELLOW}⚠️  WARNING:${NC} $1"
    ((WARNINGS++))
}

# Función para imprimir info
info() {
    echo -e "${BLUE}ℹ️  INFO:${NC} $1"
}

# Función para imprimir éxito
success() {
    echo -e "${GREEN}✅ SUCCESS:${NC} $1"
}

# Banner
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       RUNART FOUNDRY - Structure Validation Guard       ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Determinar modo de operación
MODE="full"
if [[ "$1" == "--pr-mode" ]]; then
    MODE="pr"
    info "Mode: Pull Request (checking diff against main)"
elif [[ "$1" == "--commit-mode" ]]; then
    MODE="commit"
    info "Mode: Commit (checking last commit)"
elif [[ "$1" == "--staged-only" ]]; then
    MODE="staged"
    info "Mode: Staged files only (pre-commit hook)"
else
    info "Mode: Full repository scan"
fi

echo ""

# Obtener lista de archivos a validar
FILES=()

if [[ "$MODE" == "pr" ]]; then
    # En PR, comparar contra main
    if git rev-parse --verify origin/main >/dev/null 2>&1; then
        BASE="origin/main"
    elif git rev-parse --verify main >/dev/null 2>&1; then
        BASE="main"
    else
        error "No se puede encontrar rama main para comparar"
        exit 1
    fi
    
    info "Comparing against $BASE..."
    
    # Obtener archivos nuevos y modificados
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            FILES+=("$file")
        fi
    done < <(git diff --name-only --diff-filter=AM "$BASE"...HEAD)
    
elif [[ "$MODE" == "commit" ]]; then
    # En commit, revisar último commit
    info "Checking last commit..."
    
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            FILES+=("$file")
        fi
    done < <(git diff --name-only --diff-filter=AM HEAD~1..HEAD)
    
elif [[ "$MODE" == "staged" ]]; then
    # Pre-commit: solo archivos staged
    info "Checking staged files..."
    
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            FILES+=("$file")
        fi
    done < <(git diff --cached --name-only --diff-filter=AM)
    
else
    # Full scan: todos los archivos rastreados
    info "Scanning all tracked files..."
    
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            FILES+=("$file")
        fi
    done < <(git ls-files)
fi

if [[ "${SKIP_COMPAT:-}" == "1" ]]; then
    info "SKIP_COMPAT=1 → ignorando briefing/** (compat) hasta 075_cleanup_briefing.md"
    FILTERED_FILES=()
    for file in "${FILES[@]}"; do
        if [[ "$file" == briefing/* ]]; then
            continue
        fi
        FILTERED_FILES+=("$file")
    done
    FILES=("${FILTERED_FILES[@]}")
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
    success "No files to validate"
    exit 0
fi

info "Validating ${#FILES[@]} file(s)..."
echo ""

# ═══════════════════════════════════════════════════════════
# REGLA 1: RUTAS PROHIBIDAS (archivos que NO deben existir)
# ═══════════════════════════════════════════════════════════

echo -e "${BLUE}[1/4] Checking prohibited paths...${NC}"

PROHIBITED_PATTERNS=(
    # Builds generados
    "briefing/site/"
    "build/"
    "dist/"
    "out/"
    
    # Dependencias
    "node_modules/"
    ".cache/"
    
    # Logs
    "_logs/"
    ".log$"
    ".pid$"
    
    # Mirror: binarios pesados
    "mirror/raw/.*/wp-content/uploads/"
    "mirror/raw/.*/wp-content/cache/"
    "mirror/raw/.*/wp-content/backup"
    
    # Mirror: configs sensibles
    "mirror/raw/.*/wp-config.php"
    "mirror/raw/.*/.env"
    
    # Credenciales
    "^.env$"
    "secrets/"
    "credentials/"
    ".key$"
    ".pem$"
    
    # Temporales
    "tmp/"
    "sandbox/"
    ".tmp$"
    ".bak$"
    ".swp$"
    ".swo$"
    
    # Python
    "__pycache__/"
    ".pyc$"
)

for file in "${FILES[@]}"; do
    for pattern in "${PROHIBITED_PATTERNS[@]}"; do
        if echo "$file" | grep -qE "$pattern"; then
            error "Prohibited path: $file (matches pattern: $pattern)"
            echo "   📖 See: docs/proyecto_estructura_y_gobernanza.md section 3"
        fi
    done
done

echo ""

# ═══════════════════════════════════════════════════════════
# REGLA 2: UBICACIÓN DE REPORTES
# ═══════════════════════════════════════════════════════════

echo -e "${BLUE}[2/4] Checking report locations...${NC}"

# Reportes deben estar en briefing/_reports/ o audits/reports/
# NO en raíz (excepto README.md, LICENSE, etc.)

ALLOWED_IN_ROOT=(
    "README.md"
    ".gitignore"
    ".gitattributes"
    ".env.example"
    "LICENSE"
    "LICENSE.md"
    "CONTRIBUTING.md"
    "CHANGELOG.md"
    "INCIDENTS.md"
    "STATUS.md"
    "NEXT_PHASE.md"
)

for file in "${FILES[@]}"; do
    # Si es .md en raíz
    if [[ "$file" =~ ^[^/]+\.md$ ]]; then
        # Verificar si está en la lista permitida
        allowed=false
        for allowed_file in "${ALLOWED_IN_ROOT[@]}"; do
            if [[ "$file" == "$allowed_file" ]]; then
                allowed=true
                break
            fi
        done
        
        if [[ "$allowed" == false ]]; then
            error "Report in root: $file (should be in briefing/_reports/ or audits/reports/)"
            echo "   📖 See: docs/proyecto_estructura_y_gobernanza.md section 3"
        fi
    fi
    
    # Permitir README.md en cualquier carpeta de módulo
    if [[ "$file" =~ /README\.md$ ]]; then
        continue
    fi
    
    # Permitir archivos .md en carpetas de artefactos/estructura
    if [[ "$file" =~ (_structure/|_artifacts/|_reports/) ]]; then
        continue
    fi
    
    # Permitir contenido Markdown del micrositio canonical
    if [[ "$file" =~ ^apps/briefing/docs/ ]]; then
        continue
    fi

    # Si es .md con patrón de reporte (contiene palabras clave)
    if [[ "$file" =~ \.md$ ]] && [[ "$file" =~ (informe|reporte|_audit|_report|_closure|_diagnostic|_overview|_status|_plan) ]]; then
        # Debe estar en ubicaciones permitidas
        if [[ ! "$file" =~ ^(briefing/_reports/|audits/reports/|docs/) ]]; then
            error "Report outside designated folder: $file"
            echo "   📖 Reports must be in: briefing/_reports/, audits/reports/, or docs/"
        fi
    fi
done

echo ""

# ═══════════════════════════════════════════════════════════
# REGLA 3: TAMAÑOS DE ARCHIVO
# ═══════════════════════════════════════════════════════════

echo -e "${BLUE}[3/4] Checking file sizes...${NC}"

# Límites
SIZE_HARD_LIMIT_MB=25
SIZE_WARN_LIMIT_MB=10
SIZE_HARD_LIMIT_BYTES=$((SIZE_HARD_LIMIT_MB * 1024 * 1024))
SIZE_WARN_LIMIT_BYTES=$((SIZE_WARN_LIMIT_MB * 1024 * 1024))

for file in "${FILES[@]}"; do
    if [[ -f "$file" ]]; then
        size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo 0)
        
        if [[ $size -ge $SIZE_HARD_LIMIT_BYTES ]]; then
            size_mb=$((size / 1024 / 1024))
            error "File too large: $file (${size_mb}MB ≥ ${SIZE_HARD_LIMIT_MB}MB)"
            echo "   📖 See: docs/proyecto_estructura_y_gobernanza.md section 3 (File size limits)"
        elif [[ $size -ge $SIZE_WARN_LIMIT_BYTES ]]; then
            size_mb=$((size / 1024 / 1024))
            warning "Large file: $file (${size_mb}MB, consider compression or external storage)"
        fi
    fi
done

echo ""

# ═══════════════════════════════════════════════════════════
# REGLA 4: ARCHIVOS EJECUTABLES EN RAÍZ
# ═══════════════════════════════════════════════════════════

echo -e "${BLUE}[4/4] Checking executable scripts location...${NC}"

for file in "${FILES[@]}"; do
    # Scripts ejecutables .sh en raíz (no en carpetas)
    if [[ "$file" =~ ^[^/]+\.sh$ ]] && [[ -x "$file" ]]; then
        warning "Executable script in root: $file (consider moving to scripts/)"
        echo "   📖 Recommendation: scripts/ folder for better organization"
    fi
done

echo ""

# ═══════════════════════════════════════════════════════════
# RESUMEN
# ═══════════════════════════════════════════════════════════

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    VALIDATION SUMMARY                    ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

if [[ $ERRORS -eq 0 ]] && [[ $WARNINGS -eq 0 ]]; then
    success "All checks passed! No issues found."
    echo ""
    exit 0
fi

if [[ $ERRORS -gt 0 ]]; then
    echo -e "${RED}❌ ERRORS: $ERRORS${NC}"
fi

if [[ $WARNINGS -gt 0 ]]; then
    echo -e "${YELLOW}⚠️  WARNINGS: $WARNINGS${NC}"
fi

echo ""
echo -e "${BLUE}📖 Review governance rules:${NC}"
echo "   docs/proyecto_estructura_y_gobernanza.md"
echo ""

if [[ $ERRORS -gt 0 ]]; then
    echo -e "${RED}❌ Validation FAILED - please fix errors before committing${NC}"
    exit 1
else
    if [[ $WARNINGS -gt 0 ]]; then
        echo -e "${YELLOW}⚠️  Validation passed with warnings${NC}"
    fi
    exit 0
fi
