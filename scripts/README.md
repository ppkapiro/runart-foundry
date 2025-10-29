# Scripts de RunArt Foundry

Colección de scripts de utilidad para operaciones, deployment, validación y auditoría.

## 📁 Estructura

```
scripts/
├── inventory_access_roles.sh    # Inventario de Access + KV roles
├── smoke_secret_health.sh        # Validación de secrets y health
├── runart_env_setup.sh           # Configuración de entorno local
├── runart_phase2.sh              # Setup fase 2
├── update_ci_secrets.sh          # Actualizar secrets de CI
├── validate_structure.sh         # Validar estructura del repo
└── secrets/                      # Scripts relacionados con secrets
```

## 🔧 Scripts Principales

### `inventory_access_roles.sh`

**Descripción:** Genera un inventario completo de configuraciones de Cloudflare Access y roles en KV.

**Uso:**
```bash
./scripts/inventory_access_roles.sh
```

**Salida:** `docs/internal/security/evidencia/ROLES_ACCESS_REPORT_YYYYMMDD_HHMM.md`

**Requisitos:**
- `CLOUDFLARE_API_TOKEN` configurado en `~/.runart/env`
- `CLOUDFLARE_ACCOUNT_ID` configurado en `~/.runart/env`

**Documentación:** [docs/internal/security/HOWTO_inventory_access_roles.md](../docs/internal/security/HOWTO_inventory_access_roles.md)

---

### `smoke_secret_health.sh`

**Descripción:** Valida que los secrets estén configurados correctamente y hace health checks de servicios.

**Uso:**
```bash
./scripts/smoke_secret_health.sh
```

**Checks:**
- Cloudflare API Token válido
- Account ID accesible
- Namespaces KV existentes
- Access Service Tokens válidos

---

### `runart_env_setup.sh`

**Descripción:** Configura el entorno local con secrets necesarios para desarrollo.

**Uso:**
```bash
./scripts/runart_env_setup.sh
```

**Crea:** `~/.runart/env` con variables de entorno requeridas

**Interactivo:** Solicita valores para cada secret de forma segura

---

### `validate_structure.sh`

**Descripción:** Valida la estructura del repositorio según reglas de gobernanza.

**Uso:**
```bash
./scripts/validate_structure.sh [--pr-mode|--commit-mode]
```

**Flags:**
- `--pr-mode`: Valida solo archivos modificados en PR
- `--commit-mode`: Valida todos los archivos

**Usado por:** Pre-commit hook y CI workflow "Structure & Governance Guard"

---

### `update_ci_secrets.sh`

**Descripción:** Actualiza GitHub Secrets desde valores locales.

**Uso:**
```bash
./scripts/update_ci_secrets.sh
```

**Requiere:** GitHub CLI (`gh`) autenticado

---

## 🔐 Secrets y Configuración

### Variables de Entorno Requeridas

La mayoría de scripts requieren variables en `~/.runart/env`:

```bash
CLOUDFLARE_API_TOKEN=<token>
CLOUDFLARE_ACCOUNT_ID=<account_id>
NAMESPACE_ID_RUNART_ROLES_PREVIEW=<kv_namespace_id>
ACCESS_CLIENT_ID=<access_client_id>
ACCESS_CLIENT_SECRET=<access_client_secret>
```

### Configuración Inicial

1. **Primera vez:**
   ```bash
   ./scripts/runart_env_setup.sh
   ```

2. **Validar configuración:**
   ```bash
   ./scripts/smoke_secret_health.sh
   ```

3. **Sincronizar con CI:**
   ```bash
   ./scripts/update_ci_secrets.sh
   ```

### Permisos Recomendados

```bash
chmod 600 ~/.runart/env  # Solo lectura/escritura para el usuario
chmod +x scripts/*.sh     # Hacer ejecutables los scripts
```

## 🧪 Testing y Validación

### Pre-commit Hook

El hook de pre-commit ejecuta automáticamente:
```bash
scripts/validate_structure.sh --pr-mode
```

Para omitir: `git commit --no-verify`

### Smoke Tests Locales

```bash
# Validar secrets
./scripts/smoke_secret_health.sh

# Validar estructura
./scripts/validate_structure.sh --commit-mode
```

## 📊 Reportes y Evidencia

Los scripts generan reportes en:

- `docs/internal/security/evidencia/` - Auditorías de Access y roles
- `ci_artifacts/` - Artefactos de CI (smokes, diagnósticos)
- `_reports/` - Reportes generales del proyecto

## 🔄 Workflows de CI

Algunos scripts son invocados por workflows de GitHub Actions:

| Script | Workflow | Trigger |
|--------|----------|---------|
| `validate_structure.sh` | Structure & Governance Guard | PR, Push to main |
| `smoke_secret_health.sh` | CI — Briefing | Push, PR |

## 🆘 Troubleshooting

### Error: "Permission denied"

```bash
chmod +x scripts/*.sh
```

### Error: "Variable X no configurada"

```bash
./scripts/runart_env_setup.sh
```

### Error: "jq: command not found"

```bash
# Ubuntu/Debian
sudo apt-get install jq

# macOS
brew install jq
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

## 📚 Documentación Relacionada

- [Secret Governance](../docs/internal/security/secret_governance.md)
- [Secret Changelog](../docs/internal/security/secret_changelog.md)
- [Estructura y Gobernanza](../docs/proyecto_estructura_y_gobernanza.md)

## 🔒 Seguridad

⚠️ **IMPORTANTE:**

- **NO** commitear archivos con secrets (`.env`, `~/.runart/env`)
- **NO** compartir tokens en PRs o issues
- **Rotar** tokens cada 90 días
- **Revocar** inmediatamente tokens comprometidos
- **Revisar** logs de acceso regularmente

## 📝 Contribuir

Al agregar nuevos scripts:

1. Usar `set -euo pipefail` al inicio
2. Documentar variables de entorno requeridas
3. Incluir mensajes de ayuda con `-h` o `--help`
4. Agregar validación de requisitos
5. Generar output estructurado (Markdown, JSON)
6. Actualizar este README

## ✅ Checklist de Nuevo Script

- [ ] Shebang correcto (`#!/usr/bin/env bash`)
- [ ] Permisos de ejecución (`chmod +x`)
- [ ] Validación de variables requeridas
- [ ] Mensajes de ayuda y error claros
- [ ] Documentación en este README
- [ ] HOWTO dedicado si es complejo
- [ ] Tests manuales en local
- [ ] Integración en CI (si aplica)

---

**Última actualización:** 2025-10-20  
**Mantenedor:** RunArt DevOps Team
