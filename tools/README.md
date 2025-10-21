# Tools

Utilidades compartidas para DX y automatización que pueden ejecutarse desde cualquier módulo. Todos los scripts aquí deben ser auto descriptivos, idempotentes y libres de dependencias propietarias.

## 📁 Estructura

```
tools/
├── check_env.py                      # Validador de entorno y conectividad
├── lint_docs.py                      # Linter de documentación
├── load_staging_credentials.sh      # Cargar credenciales STAGING en GitHub
├── package_template.sh              # Empaquetar plantilla para release
├── publish_mvp_staging.sh           # Publicar MVP en STAGING
├── publish_showcase_page_staging.sh # Publicar showcase en STAGING
├── remediate.sh                     # Auto-remediación de auditorías
├── rotate_wp_app_password.sh        # Rotar App Password de WordPress
└── staging_privacy.sh               # Configurar privacidad en STAGING
```

## 🔧 Convenciones

- **Python**: Ejecutables invocables vía `python tools/<script>.py` o mediante targets de `make`
- **Bash**: Scripts con shebang `#!/usr/bin/env bash` y `set -euo pipefail`
- **Logs**: Mantener registros en `logs/` o `audits/` cuando proceda
- **Documentación**: Opciones y modos de uso en encabezado del script o HOWTO dedicado
- **Permisos**: Scripts bash deben tener permisos de ejecución (`chmod +x`)

## 🐍 Scripts Python

### `check_env.py`

**Propósito**: Validador de banderas de entorno y conectividad

**Uso**:
```bash
python tools/check_env.py
```

**Validaciones**:
- Variables de entorno requeridas
- Conectividad a servicios externos
- Configuración de desarrollo

**Migrado desde**: `briefing/scripts`

---

### `lint_docs.py`

**Propósito**: Linter de documentación con validación estricta

**Uso**:
```bash
python tools/lint_docs.py
```

**Validaciones**:
- `mkdocs build --strict` sin errores
- Snippets de código válidos
- Espacios y formato consistente

**Output**: `audits/docs_lint.log`

---

## 🔐 Scripts de Configuración

### `load_staging_credentials.sh` ⭐ NUEVO

**Propósito**: Cargar credenciales de WordPress STAGING en GitHub para workflows

**Uso**:
```bash
./tools/load_staging_credentials.sh [REPO_FULL]
```

**Interactivo**: Solicita `WP_USER` y `WP_APP_PASSWORD` de forma segura

**Configura**:
- `WP_BASE_URL` (variable): https://staging.runartfoundry.com
- `WP_USER` (secret): Usuario técnico de WordPress
- `WP_APP_PASSWORD` (secret): App Password generada
- `WP_ENV` (variable): staging

**Requisitos**:
- `gh` CLI autenticado
- Permisos de admin/mantenedor en el repo
- Credenciales de WordPress STAGING

**Documentación**: [docs/ops/load_staging_credentials.md](../docs/ops/load_staging_credentials.md)

**Logs**: `logs/gh_credentials_setup_staging_*.log`

---

### `rotate_wp_app_password.sh`

**Propósito**: Rotar App Password de WordPress en GitHub Secrets

**Uso**:
```bash
./tools/rotate_wp_app_password.sh
```

**Workflow**: `.github/workflows/rotate-app-password.yml` (trimestral)

**Seguridad**: Entrada oculta, no logea secrets

---

## 📦 Scripts de Release y Deploy

### `package_template.sh`

**Propósito**: Empaquetar ecosistema como plantilla reusable

**Uso**:
```bash
./tools/package_template.sh
```

**Genera**:
- `runart-foundry-template-vX.Y.Z.tar.gz`
- `runart-foundry-template-vX.Y.Z.sha256`

**Exclusiones**:
- Secrets y archivos sensibles (`.env*`, `secrets/`)
- Logs y reportes (`logs/`, `_reports/*`)
- Artefactos locales (`mirror/raw/`, `ci_artifacts/`)

**Workflow**: `.github/workflows/release-template.yml`

---

### `publish_mvp_staging.sh`

**Propósito**: Publicar MVP (briefing) en entorno STAGING

**Uso**:
```bash
export IONOS_SSH_HOST="usuario@servidor.ionos.com"
./tools/publish_mvp_staging.sh
```

**Requiere**: Credenciales SSH de IONOS

**Acciones**:
- Copia módulo briefing vía SSH
- Configura permisos
- Valida deployment

---

### `publish_showcase_page_staging.sh`

**Propósito**: Publicar página showcase final en STAGING

**Uso**:
```bash
export IONOS_SSH_HOST="usuario@servidor.ionos.com"
./tools/publish_showcase_page_staging.sh
```

**Genera**: Página HTML con estado del sistema (workflows, audit, etc.)

**Requiere**: Credenciales SSH de IONOS

---

## 🔒 Scripts de Seguridad y Privacidad

### `staging_privacy.sh`

**Propósito**: Configurar robots.txt anti-index en STAGING

**Uso**:
```bash
export IONOS_SSH_HOST="usuario@servidor.ionos.com"
./tools/staging_privacy.sh
```

**Crea**: `robots.txt` con `Disallow: /`

**Requiere**: Credenciales SSH de IONOS

---

## 🔍 Scripts de Auditoría y Remediación

### `remediate.sh`

**Propósito**: Auto-remediación de issues detectados en auditorías

**Uso**:
```bash
./tools/remediate.sh <ACTION> [ARGS...]
```

**Acciones disponibles**:
- `rotate_wp_app_password`: Rotar password de WordPress
- `retry_verify`: Reintentar workflow verify-*
- `clear_cache`: Limpiar cachés de deployment

**Workflow**: `.github/workflows/audit-and-remediate.yml`

**Llamado por**: `apps/briefing/modules/briefing_audit/audit_engine.py`

---

## 🧪 Testing y Validación

### Ejecutar todos los Python tools

```bash
python tools/check_env.py
python tools/lint_docs.py
```

### Ejecutar scripts bash con dry-run

La mayoría de scripts bash soportan modo de prueba:

```bash
# Ejemplo con package_template.sh
DRY_RUN=1 ./tools/package_template.sh
```

### Validar permisos

```bash
# Listar scripts sin permisos de ejecución
find tools -name "*.sh" ! -perm -u+x

# Corregir permisos
chmod +x tools/*.sh
```

---

## 🔄 Workflows que Usan Tools

| Tool | Workflow | Trigger |
|------|----------|---------|
| `package_template.sh` | `release-template.yml` | Tag push `v*` |
| `rotate_wp_app_password.sh` | `rotate-app-password.yml` | Schedule (trimestral) |
| `remediate.sh` | `audit-and-remediate.yml` | Schedule (diario) |
| `check_env.py` | CI — Briefing | Push, PR |

---

## 📚 Documentación Relacionada

- **Ops**: [docs/ops/load_staging_credentials.md](../docs/ops/load_staging_credentials.md)
- **Fase 10**: [docs/ci/phase10_template/](../docs/ci/phase10_template/)
- **Bitácora**: [apps/briefing/docs/internal/briefing_system/ci/082_bitacora_fase7_conexion_wp_real.md](../apps/briefing/docs/internal/briefing_system/ci/082_bitacora_fase7_conexion_wp_real.md)

---

## 🆘 Troubleshooting

### Script no ejecutable

```bash
chmod +x tools/<script>.sh
```

### Variable de entorno no configurada

```bash
# Verificar variables requeridas
grep "export" tools/<script>.sh

# Configurar temporalmente
export VAR_NAME="value"
./tools/<script>.sh

# Configurar permanentemente
echo 'export VAR_NAME="value"' >> ~/.bashrc
source ~/.bashrc
```

### Error: "gh: command not found"

```bash
# Ubuntu/Debian
sudo apt install gh

# macOS
brew install gh

# Autenticar
gh auth login
```

### Error: "jq: command not found"

```bash
# Ubuntu/Debian
sudo apt-get install jq

# macOS
brew install jq
```

---

## 📝 Contribuir

Al agregar nuevos tools:

### Checklist

- [ ] Shebang correcto (`#!/usr/bin/env bash` o `#!/usr/bin/env python3`)
- [ ] Permisos de ejecución (`chmod +x`)
- [ ] Validación de variables requeridas
- [ ] Modo de ayuda (`-h` o `--help`)
- [ ] Documentación en encabezado
- [ ] Actualizar este README
- [ ] Tests manuales en local
- [ ] HOWTO dedicado si es complejo
- [ ] Integración en CI (si aplica)

### Template de Script Bash

```bash
#!/usr/bin/env bash
#
# script_name.sh
# Descripción breve del propósito
#
# Requisitos:
# - Requisito 1
# - Requisito 2
#
# Uso:
#   ./tools/script_name.sh [ARGS...]
#

set -euo pipefail

# Funciones de logging
log_info() { echo -e "\033[0;34mℹ\033[0m $*"; }
log_success() { echo -e "\033[0;32m✅\033[0m $*"; }
log_warning() { echo -e "\033[1;33m⚠️\033[0m $*"; }
log_error() { echo -e "\033[0;31m❌\033[0m $*"; }

# Tu código aquí...
```

### Template de Script Python

```python
#!/usr/bin/env python3
"""
script_name.py
Descripción breve del propósito

Requisitos:
- Python 3.8+
- Librería X

Uso:
    python tools/script_name.py [ARGS...]
"""

import sys
from pathlib import Path

def main():
    """Entry point"""
    # Tu código aquí...
    pass

if __name__ == "__main__":
    main()
```

---

## 🔒 Seguridad

⚠️ **IMPORTANTE**:

- **NO** commitear secrets en scripts
- **NO** logear valores sensibles
- **Usar** variables de entorno para secrets
- **Validar** inputs del usuario
- **Sanitizar** outputs en logs
- **Documentar** requisitos de permisos

---

**Última actualización**: 2025-10-21  
**Mantenedor**: RunArt DevOps Team
