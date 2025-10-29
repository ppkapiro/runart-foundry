#!/usr/bin/env bash
# LIMPIEZA AUTOMÁTICA STAGING CON CREDENCIALES GITHUB
# Usa las credenciales ya configuradas en GitHub Secrets para limpieza automática

set -euo pipefail

# Configuración
REPO_FULL="RunArtFoundry/runart-foundry"
STAGING_URL="https://staging.runartfoundry.com"
LOG_FILE="$(pwd)/logs/staging_cleanup_$(date +%Y%m%d_%H%M%S).log"

# Crear directorio de logs si no existe
mkdir -p "$(dirname "$LOG_FILE")"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"; }

# Obtener credenciales de GitHub
get_github_credentials() {
    log_info "Obteniendo credenciales de GitHub..."
    
    # Verificar gh CLI autenticado
    if ! gh auth status >/dev/null 2>&1; then
        log_error "gh CLI no autenticado. Ejecutar: gh auth login"
        exit 1
    fi
    
    # Obtener WP_BASE_URL (variable pública)
    WP_BASE_URL=$(gh variable get WP_BASE_URL --repo "$REPO_FULL" 2>/dev/null || echo "")
    if [[ -n "$WP_BASE_URL" ]]; then
        log_success "WP_BASE_URL obtenida: $WP_BASE_URL"
        STAGING_URL="$WP_BASE_URL"
    else
        log_warn "WP_BASE_URL no configurada, usando: $STAGING_URL"
    fi
    
    # Obtener secrets (no podemos leerlos directamente, pero podemos usarlos en workflow)
    log_info "Verificando secrets disponibles..."
    local secrets=$(gh secret list --repo "$REPO_FULL" 2>/dev/null | grep -E "(WP_USER|WP_APP_PASSWORD)" || echo "")
    
    if echo "$secrets" | grep -q "WP_USER" && echo "$secrets" | grep -q "WP_APP_PASSWORD"; then
        log_success "Secrets WP_USER y WP_APP_PASSWORD encontrados"
        CREDENTIALS_AVAILABLE=true
    else
        log_warn "Secrets no disponibles - usando modo limitado"
        CREDENTIALS_AVAILABLE=false
    fi
}

# Crear workflow temporal para limpieza
create_cleanup_workflow() {
    local workflow_file=".github/workflows/staging-cleanup-temp.yml"
    
    log_info "Creando workflow temporal de limpieza..."
    
    cat > "$workflow_file" << 'EOF'
name: Staging Cleanup (Temporal)

on:
  workflow_dispatch: {}

jobs:
  cleanup-staging:
    runs-on: ubuntu-latest
    env:
      WP_URL: ${{ vars.WP_BASE_URL }}
      WP_USER: ${{ secrets.WP_USER }}
      WP_APP_PASSWORD: ${{ secrets.WP_APP_PASSWORD }}
    
    steps:
      - name: Verificar acceso a staging
        run: |
          echo "🔍 Verificando acceso a $WP_URL"
          curl -s -I "$WP_URL" | head -3
          
          echo "🔍 Verificando WP-CLI disponible"
          curl -s -I "$WP_URL/wp-cli.phar" | head -2
      
      - name: Inventario pre-limpieza
        run: |
          echo "📊 INVENTARIO PRE-LIMPIEZA"
          
          POSTS=$(curl -s "$WP_URL/wp-json/wp/v2/posts" | jq 'length' 2>/dev/null || echo "0")
          PAGES=$(curl -s "$WP_URL/wp-json/wp/v2/pages" | jq 'length' 2>/dev/null || echo "0") 
          MEDIA=$(curl -s "$WP_URL/wp-json/wp/v2/media" | jq 'length' 2>/dev/null || echo "0")
          
          echo "Posts detectados: $POSTS"
          echo "Páginas detectadas: $PAGES"
          echo "Medios detectados: $MEDIA"
          
          echo "posts_before=$POSTS" >> $GITHUB_ENV
          echo "pages_before=$PAGES" >> $GITHUB_ENV
          echo "media_before=$MEDIA" >> $GITHUB_ENV
      
      - name: Eliminar posts via REST API
        run: | 
          echo "🗑️ Eliminando posts..."
          
          # Obtener todos los IDs de posts
          POST_IDS=$(curl -s "$WP_URL/wp-json/wp/v2/posts?per_page=100" | jq -r '.[].id' 2>/dev/null || echo "")
          
          if [[ -n "$POST_IDS" ]]; then
            for id in $POST_IDS; do
              RESPONSE=$(curl -s -w "%{http_code}" -u "$WP_USER:$WP_APP_PASSWORD" \
                        -X DELETE "$WP_URL/wp-json/wp/v2/posts/$id?force=true" \
                        -o /dev/null 2>/dev/null || echo "000")
              
              if [[ "$RESPONSE" == "200" ]]; then
                echo "✓ Post eliminado: ID $id"
              else
                echo "⚠ Error eliminando post ID $id (HTTP $RESPONSE)"
              fi
              
              sleep 0.5
            done
          else
            echo "No hay posts para eliminar"
          fi
      
      - name: Eliminar páginas via REST API
        run: |
          echo "🗑️ Eliminando páginas..."
          
          PAGE_IDS=$(curl -s "$WP_URL/wp-json/wp/v2/pages?per_page=100" | jq -r '.[].id' 2>/dev/null || echo "")
          
          if [[ -n "$PAGE_IDS" ]]; then
            for id in $PAGE_IDS; do
              RESPONSE=$(curl -s -w "%{http_code}" -u "$WP_USER:$WP_APP_PASSWORD" \
                        -X DELETE "$WP_URL/wp-json/wp/v2/pages/$id?force=true" \
                        -o /dev/null 2>/dev/null || echo "000")
              
              if [[ "$RESPONSE" == "200" ]]; then
                echo "✓ Página eliminada: ID $id"
              else  
                echo "⚠ Error eliminando página ID $id (HTTP $RESPONSE)"
              fi
              
              sleep 0.5
            done
          else
            echo "No hay páginas para eliminar"
          fi
      
      - name: Eliminar medios via REST API
        run: |
          echo "🗑️ Eliminando archivos multimedia..."
          
          MEDIA_IDS=$(curl -s "$WP_URL/wp-json/wp/v2/media?per_page=100" | jq -r '.[].id' 2>/dev/null || echo "")
          
          if [[ -n "$MEDIA_IDS" ]]; then
            for id in $MEDIA_IDS; do
              RESPONSE=$(curl -s -w "%{http_code}" -u "$WP_USER:$WP_APP_PASSWORD" \
                        -X DELETE "$WP_URL/wp-json/wp/v2/media/$id?force=true" \
                        -o /dev/null 2>/dev/null || echo "000")
              
              if [[ "$RESPONSE" == "200" ]]; then
                echo "✓ Medio eliminado: ID $id"
              else
                echo "⚠ Error eliminando medio ID $id (HTTP $RESPONSE)"  
              fi
              
              sleep 0.5
            done
          else
            echo "No hay medios para eliminar"
          fi
      
      - name: Limpiar comentarios con WP-CLI
        run: |
          echo "🗑️ Eliminando comentarios..."
          
          # Descargar WP-CLI
          curl -sS -o wp-cli.phar "$WP_URL/wp-cli.phar"
          chmod +x wp-cli.phar
          
          # Crear configuración WP-CLI para acceso remoto
          cat > wp-cli.yml << WPCLI_EOF
          url: $WP_URL
          user: $WP_USER
          WPCLI_EOF
          
          # Eliminar comentarios (requiere conexión directa, método alternativo)
          echo "Intentando limpieza via WP-CLI remoto..."
          
          # Método alternativo: via REST API comments endpoint si está disponible
          COMMENTS=$(curl -s "$WP_URL/wp-json/wp/v2/comments?per_page=100" | jq -r '.[].id' 2>/dev/null || echo "")
          if [[ -n "$COMMENTS" ]]; then
            for id in $COMMENTS; do
              curl -s -u "$WP_USER:$WP_APP_PASSWORD" \
                   -X DELETE "$WP_URL/wp-json/wp/v2/comments/$id?force=true" \
                   >/dev/null 2>&1 && echo "✓ Comentario eliminado: ID $id" || true
              sleep 0.3
            done
          fi
      
      - name: Verificación post-limpieza
        run: |
          echo "✅ VERIFICACIÓN POST-LIMPIEZA"
          
          POSTS_AFTER=$(curl -s "$WP_URL/wp-json/wp/v2/posts" | jq 'length' 2>/dev/null || echo "error")
          PAGES_AFTER=$(curl -s "$WP_URL/wp-json/wp/v2/pages" | jq 'length' 2>/dev/null || echo "error")  
          MEDIA_AFTER=$(curl -s "$WP_URL/wp-json/wp/v2/media" | jq 'length' 2>/dev/null || echo "error")
          
          echo "Posts restantes: $POSTS_AFTER (antes: $posts_before)"
          echo "Páginas restantes: $PAGES_AFTER (antes: $pages_before)"
          echo "Medios restantes: $MEDIA_AFTER (antes: $media_before)"
          
          # Verificar Polylang preservado
          POLYLANG_LANGS=$(curl -s "$WP_URL/wp-json/pll/v1/languages" | jq 'length' 2>/dev/null || echo "0")
          echo "Idiomas Polylang: $POLYLANG_LANGS"
          
          if [[ "$POLYLANG_LANGS" == "2" ]]; then
            echo "✅ Polylang preservado correctamente"
          else
            echo "⚠️ Polylang: configuración requiere verificación"
          fi
          
          # Status final
          if [[ "$POSTS_AFTER" == "0" && "$PAGES_AFTER" == "0" && "$MEDIA_AFTER" == "0" ]]; then
            echo "🎉 LIMPIEZA EXITOSA - Staging limpio y listo para Fase 2"
          else
            echo "⚠️ Limpieza parcial - contenido residual detectado"
          fi
          
          # Comandos de verificación
          echo ""
          echo "=== COMANDOS DE VERIFICACIÓN MANUAL ==="
          echo "curl -s '$WP_URL/wp-json/wp/v2/posts' | jq 'length'"
          echo "curl -s '$WP_URL/wp-json/wp/v2/pages' | jq 'length'" 
          echo "curl -s '$WP_URL/wp-json/wp/v2/media' | jq 'length'"
          echo "curl -s '$WP_URL/wp-json/pll/v1/languages' | jq -r '.[].name'"
EOF

    log_success "Workflow temporal creado: $workflow_file"
    echo "$workflow_file"
}

# Ejecutar limpieza via GitHub Actions
execute_cleanup_workflow() {
    local workflow_file="$1"
    
    log_info "Ejecutando limpieza via GitHub Actions..."
    
    # Commit temporal del workflow
    git add "$workflow_file"
    git commit -m "temp: staging cleanup workflow (auto-delete)" || true
    
    # Push temporal
    git push origin HEAD || {
        log_error "Error pushing workflow temporal"
        return 1
    }
    
    # Ejecutar workflow
    log_info "Disparando workflow de limpieza..."
    gh workflow run "$(basename "$workflow_file")" --repo "$REPO_FULL"
    
    # Esperar inicio
    sleep 10
    
    # Monitorear ejecución
    log_info "Monitoreando ejecución (60s)..."
    local run_id=""
    for i in {1..12}; do
        run_id=$(gh run list --repo "$REPO_FULL" --workflow="$(basename "$workflow_file")" --limit=1 --json databaseId --jq '.[0].databaseId' 2>/dev/null || echo "")
        if [[ -n "$run_id" ]]; then
            break
        fi
        sleep 5
    done
    
    if [[ -n "$run_id" ]]; then
        log_success "Run ID: $run_id"
        log_info "Seguir ejecución: gh run watch $run_id --repo $REPO_FULL"
        
        # Auto-watch por 5 minutos
        timeout 300 gh run watch "$run_id" --repo "$REPO_FULL" || log_warn "Timeout watching - continúa en background"
    else
        log_warn "No se pudo obtener Run ID - verificar manualmente"
    fi
}

# Limpiar archivos temporales
cleanup_temp_files() {
    log_info "Limpiando archivos temporales..."
    
    local workflow_file=".github/workflows/staging-cleanup-temp.yml"
    if [[ -f "$workflow_file" ]]; then
        rm -f "$workflow_file"
        git add "$workflow_file" 2>/dev/null || true
        git commit -m "cleanup: remove temp staging cleanup workflow" 2>/dev/null || true
        git push origin HEAD 2>/dev/null || true
        log_success "Workflow temporal eliminado"
    fi
}

# Función principal
main() {
    log_info "=== LIMPIEZA AUTOMÁTICA STAGING CON GITHUB ACTIONS ==="
    log_info "Repositorio: $REPO_FULL"  
    log_info "Log: $LOG_FILE"
    
    # Verificar dependencias
    for cmd in gh git curl jq; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log_error "Dependencia faltante: $cmd"
            exit 1
        fi
    done
    
    # Obtener credenciales
    get_github_credentials
    
    if [[ "$CREDENTIALS_AVAILABLE" == "true" ]]; then
        log_success "Usando modo automático completo con GitHub Actions"
        
        # Crear y ejecutar workflow
        local workflow_file
        workflow_file=$(create_cleanup_workflow)
        
        # Trap para limpiar en caso de error
        trap 'cleanup_temp_files' EXIT
        
        execute_cleanup_workflow "$workflow_file"
        
        log_success "Limpieza iniciada via GitHub Actions"
        log_info "Revisar resultados en: https://github.com/$REPO_FULL/actions"
        
    else
        log_error "Credenciales no disponibles"
        log_info "Configurar primero: ./tools/load_staging_credentials.sh"
        exit 1
    fi
}

# Mostrar ayuda
show_help() {
    echo "LIMPIEZA AUTOMÁTICA STAGING - GitHub Actions"
    echo ""
    echo "Este script utiliza las credenciales ya configuradas en GitHub"
    echo "para ejecutar una limpieza completa del staging automáticamente."
    echo ""
    echo "Requisitos:"
    echo "  - gh CLI autenticado (gh auth login)"
    echo "  - Credenciales configuradas (./tools/load_staging_credentials.sh)"
    echo "  - Permisos de admin/mantenedor en el repositorio"
    echo ""
    echo "Uso: $0 [opciones]"
    echo ""
    echo "Opciones:"
    echo "  -h, --help     Mostrar ayuda"
    echo "  -v, --verbose  Modo verbose"
    echo ""
}

# Procesar argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            set -x
            shift
            ;;
        *)
            log_error "Opción desconocida: $1"
            show_help
            exit 1
            ;;
    esac
done

# Ejecutar
main