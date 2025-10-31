# Hoja de Ruta Ejecutable — RunArt Foundry (Base Técnica)

**Fecha de generación:** 31 de octubre de 2025  
**Proyecto:** RunArt Foundry  
**Repositorio:** ppkapiro/runart-foundry  
**Rama activa:** feat/ai-visual-implementation  
**Sistema operativo:** Linux (WSL/Ubuntu)

---

## 1. Estado Actual de la Infraestructura

### 1.1 Estructura de Directorios Detectada

El proyecto **NO utiliza** las rutas convencionales `/local/`, `/staging/`, `/production/`, `/automation/` o `/infrastructure/` mencionadas en el Plan Maestro.

**Estructura real del proyecto (monorepo):**

```
runartfoundry/
├── .github/workflows/      # 60+ workflows de CI/CD (GitHub Actions)
├── .vscode/                # Configuración VS Code
├── docs/                   # Documentación principal del proyecto
│   ├── DEPLOY_RUNBOOK.md   # Manual de operaciones y deploy
│   ├── Deployment_Master.md # Arquitectura de deployment
│   ├── Bridge_API.md       # Documentación WP-CLI Bridge
│   ├── ci/                 # Documentación CI/CD
│   ├── architecture/       # ADRs y arquitectura
│   ├── ops/                # Runbooks operativos
│   ├── integration_wp_staging_lite/ # 23 documentos integración staging
│   └── ui_roles/           # Documentación roles UI
├── mirror/                 # Snapshots del sitio cliente (SFTP/wget)
│   ├── raw/                # Snapshots sin procesar
│   └── scripts/            # Scripts de sincronización
├── audits/                 # Auditorías rendimiento/SEO/accesibilidad
│   └── reports/            # Reportes de auditoría (2025-10-01_ssh_config_status.md)
├── tools/                  # Scripts operativos y de staging
│   ├── ionos_create_staging.sh          # Creación staging IONOS
│   ├── ionos_create_staging_db.sh       # Creación BD staging
│   ├── staging_*.sh                     # 129 scripts de staging
│   ├── repair_*.sh                      # Scripts de reparación
│   ├── deploy_wp_ssh.sh                 # Deploy SSH
│   └── runart-ai-visual-panel/          # Plugin IA Visual (activo)
├── scripts/                # Scripts globales del proyecto
│   ├── deploy_framework/               # Framework de deployment
│   │   └── deploy_plugin_via_rest.sh   # Deploy vía REST API
│   └── setup_ssh_and_push.sh           # Configuración SSH
├── plugins/                # Plugins WordPress (wpcli-bridge, etc.)
├── wp-content/             # Contenido WordPress
│   └── mu-plugins/         # Must-use plugins (wp-staging-lite activo)
├── src/                    # Código fuente editable
├── data/                   # Datos del proyecto
├── _reports/               # Reportes generados (127 archivos post-purga)
├── _dist/                  # Builds distribuibles
├── _artifacts/             # Artefactos de builds
├── _tmp/                   # Archivos temporales
├── _backup_purge_briefing_ia_2025_10_31/  # Backup reciente (143 MB)
├── tests/                  # Suite de tests
├── .env                    # Variables de entorno (SFTP, DB)
├── .env.staging            # Variables específicas staging
├── README.md               # Documentación principal
├── STATUS.md               # Estado del proyecto
├── NEXT_PHASE.md           # Próxima iteración
└── Makefile                # Tareas automatizadas
```

### 1.2 Ausencia de Rutas Esperadas

**Rutas NO encontradas:**
- `/local/` - No existe (el proyecto entero es el entorno local)
- `/staging/` - No existe (staging está en servidor IONOS remoto)
- `/production/` - No existe (producción en servidor IONOS remoto)
- `/automation/` - No existe (se usa `.github/workflows/` y `scripts/`)
- `/infrastructure/` - **Creada ahora** para este documento

**Interpretación:**
- El proyecto usa un **modelo distribuido**: desarrollo local (VS Code/WSL), staging remoto (IONOS), producción remota (IONOS).
- No hay carpetas locales que representen staging/producción; se accede vía SSH/SFTP/REST API.
- Los scripts de automatización están distribuidos en `tools/`, `scripts/` y `.github/workflows/`.

### 1.3 Rutas Principales Confirmadas

| Ruta | Propósito | Estado |
|------|-----------|--------|
| `docs/` | Documentación completa del proyecto | ✅ Activo (180+ archivos) |
| `mirror/` | Snapshots del sitio cliente | ✅ Activo (sincronización periódica) |
| `tools/` | Scripts operativos (staging, reparación, IONOS) | ✅ Activo (129 scripts) |
| `scripts/` | Scripts globales y framework deployment | ✅ Activo |
| `.github/workflows/` | CI/CD con GitHub Actions | ✅ Activo (60+ workflows) |
| `plugins/` | Plugins WordPress (wpcli-bridge) | ✅ Activo |
| `wp-content/mu-plugins/` | Must-use plugins (wp-staging-lite) | ✅ Activo |
| `audits/` | Reportes de auditorías | ✅ Activo |
| `_reports/` | Reportes técnicos generados | ✅ Activo (127 archivos) |

---

## 2. Conectividad y Accesos Verificados

### 2.1 Conectividad Git con GitHub

**Estado:** ✅ **OPERATIVO**

```bash
# Repositorios remotos configurados
origin    git@github.com:ppkapiro/runart-foundry.git (fetch/push)
upstream  git@github.com:RunArtFoundry/runart-foundry.git (fetch/push)
```

**Pruebas realizadas:**
```bash
$ git fetch --dry-run origin
From github.com:ppkapiro/runart-foundry
   9a7eaaf6..8caf7580  main -> origin/main
✅ Git fetch exitoso
```

**Observaciones:**
- Autenticación SSH funcionando correctamente
- Dos remotos configurados: `origin` (fork personal) y `upstream` (organización)
- Rama actual: `feat/ai-visual-implementation` con cambios locales pendientes (purga Briefing/IA Visual ejecutada)

### 2.2 Conectividad SSH hacia IONOS

**Estado:** ✅ **OPERATIVO**

**Configuración SSH detectada:**
```
~/.ssh/id_ed25519       # Clave privada principal
~/.ssh/id_ed25519.pub   # Clave pública
~/.ssh/config           # Configuración host "pepecapiro"
```

**Host configurado en ~/.ssh/config:**
```
Host pepecapiro
  HostName 157.173.214.43
  Port 65002
  User u525829715
  IdentityFile ~/.ssh/id_ed25519
  IdentitiesOnly yes
  ServerAliveInterval 30
  ServerAliveCountMax 4
```

**Prueba de conectividad:**
```bash
$ ssh -o BatchMode=yes -p 65002 u525829715@157.173.214.43 'pwd'
✅ SSH conectado
/home/u525829715
```

**Versiones detectadas en servidor:**
- **PHP:** 8.2.28 (cli) (NTS)
- **MySQL:** MariaDB 11.8.3 (client 15.2)

**Observaciones:**
- Autenticación por clave SSH funcionando correctamente
- Modo `BatchMode` habilitado (sin solicitud de contraseña)
- Conexión estable con `ServerAliveInterval`

### 2.3 Acceso SFTP/FTP

**Configuración (.env):**
```bash
SFTP_HOST=access958591985.webspace-data.io
SFTP_PORT=22
SFTP_USER=u111876951
# SFTP_PASS= (vacío; se usa clave SSH)
```

**Estado:** ⚠️ **NO VERIFICADO** (requiere test manual)

**Observación:**
- Usuario SFTP (`u111876951`) **diferente** de usuario SSH (`u525829715`)
- Host SFTP (`access958591985...`) **diferente** de host SSH (`157.173.214.43`)
- Sugiere dos cuentas IONOS separadas o subdominios diferentes

### 2.4 Acceso a Base de Datos

**Configuración (.env):**
```bash
DB_HOST=db5012671937.hosting-data.io
DB_PORT=3306
DB_USER=dbu2309272
DB_NAME=dbs10646556
# DB_PASS= (vacío; se solicita cuando sea necesario)
```

**Estado:** ⚠️ **NO VERIFICADO** (requiere test con credenciales)

**Observaciones:**
- Base de datos MySQL/MariaDB en host remoto de IONOS
- Credenciales no almacenadas en `.env` (seguridad correcta)

### 2.5 DNS y Dominio

**Dominio principal:** runartfoundry.com

**Prueba DNS:**
```bash
$ nslookup runartfoundry.com
Name:   runartfoundry.com
Address: 74.208.236.254
```

**Estado:** ✅ **RESOLVIENDO CORRECTAMENTE**

**Observaciones:**
- DNS apuntando a IP 74.208.236.254
- Confirma hosting activo

### 2.6 WordPress REST API

**Configuración detectada:**
- **Application Password:** Documentado en `docs/DEPLOY_RUNBOOK.md` y `docs/CIERRE_AUTOMATIZACION_TOTAL.md`
- **Método de autenticación:** WordPress Application Passwords (REST API)
- **Workflows relacionados:**
  - `verify-staging.yml` - Verificación diaria salud staging
  - `verify-home.yml`, `verify-menus.yml`, `verify-media.yml`, `verify-settings.yml` - Verificaciones programadas

**Estado:** ⚠️ **NO VERIFICADO EN TIEMPO REAL** (credenciales no expuestas)

**Observaciones:**
- Framework de deployment utiliza REST API para operaciones
- Script `scripts/deploy_framework/deploy_plugin_via_rest.sh` implementa deploy vía API
- Rotación programada de Application Password documentada

---

## 3. Repositorios y Workflows Activos

### 3.1 Repositorios Git

| Repositorio | Tipo | URL | Estado |
|-------------|------|-----|--------|
| **origin** | Fork personal | `git@github.com:ppkapiro/runart-foundry.git` | ✅ Activo |
| **upstream** | Organización | `git@github.com:RunArtFoundry/runart-foundry.git` | ✅ Activo |

### 3.2 Workflows GitHub Actions Activos

**Total de workflows:** 60+ archivos en `.github/workflows/`

**Workflows clave identificados:**

#### Deployment & Verificación
| Workflow | Propósito | Trigger |
|----------|-----------|---------|
| `verify-staging.yml` | Health check staging diario | Schedule (cron) + manual |
| `deploy-verify.yml` | Verificación post-deploy producción | Workflow completion |
| `pages-prod.yml` | Deploy Cloudflare Pages producción | Push a main |
| `pages-deploy.yml` | Deploy genérico Pages | Push |
| `pages-preview.yml` | Preview environments | PR |

#### Verificaciones Programadas
| Workflow | Propósito | Frecuencia |
|----------|-----------|------------|
| `verify-home.yml` | Auth, show_on_front, Home ES/EN | Cada 6h + manual |
| `verify-menus.yml` | Menus WP, drift detection | Cada 12h + manual |
| `verify-media.yml` | Media manifest, asignaciones | Diario + manual |
| `verify-settings.yml` | Timezone, permalinks, start_of_week | Cada 24h + manual |

#### Mantenimiento & Operaciones
| Workflow | Propósito | Trigger |
|----------|-----------|---------|
| `wpcli-bridge.yml` | Build/deploy WP-CLI Bridge | Manual + schedule |
| `wpcli-bridge-maintenance.yml` | Mantenimiento Bridge | Schedule |
| `healthcheck.yml` | Health check general | Schedule |
| `smoke-tests.yml` | Tests de humo | Manual |
| `rotate-app-password.yml` | Rotación Application Password | Manual + reminder |
| `rotate-reminder.yml` | Recordatorio rotación | Schedule |

#### CI/CD & Testing
| Workflow | Propósito | Trigger |
|----------|-----------|---------|
| `ci.yml` | Integración continua | PR + push |
| `build-wpcli-bridge.yml` | Build Bridge plugin | Push |
| `install-wpcli-bridge.yml` | Instalación Bridge | Manual |
| `manual-plugin-deploy.yml` | Deploy manual plugins | Manual |

#### Auditoría & Seguridad
| Workflow | Propósito | Trigger |
|----------|-----------|---------|
| `audit-rest.yml` | Auditoría REST API | Manual |
| `audit-content-rest.yml` | Auditoría contenido REST | Manual |
| `status-audit.yml` | Auditoría estado | Schedule |
| `forensics-collect.yml` | Recolección forense | Manual |

#### Staging Management
| Workflow | Propósito | Trigger |
|----------|-----------|---------|
| `staging-cleanup-*.yml` | Limpieza staging temporal | Manual |
| `run-repair.yml` | Reparaciones automáticas | Manual |

#### Documentación
| Workflow | Propósito | Trigger |
|----------|-----------|---------|
| `docs-lint.yml` | Linting documentación | Push |
| `docs-validate-strict.yml` | Validación estricta docs | PR |
| `docs-stale-dryrun.yml` | Detección docs obsoletos | Schedule |

### 3.3 Workflows Eliminados Recientemente

**Eliminados en purga del 31/10/2025:**
- `briefing-status-publish.yml` (265 líneas)
- `briefing_deploy.yml` (100 líneas)

**Razón:** Eliminación completa del sistema Briefing (micrositio Cloudflare MkDocs obsoleto).

### 3.4 Estado de Deployment Keys

**Estado:** ⚠️ **NO INSPECCIONADO DIRECTAMENTE**

**Observaciones:**
- Los workflows funcionan correctamente, lo que sugiere Deploy Keys activas
- Autenticación SSH con GitHub funcional (git fetch exitoso)
- Requiere inspección manual en GitHub Settings → Deploy keys

---

## 4. Observaciones Técnicas

### 4.1 Modelo de Infraestructura Real vs. Esperado

**Diferencia crítica:**
El proyecto **NO sigue** la estructura `/local/`, `/staging/`, `/production/` del Plan Maestro.

**Modelo real:**
```
┌─────────────────────────────────────────────────────────┐
│ ENTORNO LOCAL (VS Code/WSL)                             │
│ /home/pepe/work/runartfoundry/                          │
│ - Desarrollo                                            │
│ - Scripts (tools/, scripts/)                            │
│ - Documentación (docs/)                                 │
│ - Mirror (snapshots locales)                            │
│ - Git (origin/upstream)                                 │
└────────────┬────────────────────────────────────────────┘
             │
             ├─── SSH ───► IONOS Servidor 1 (pepecapiro)
             │             157.173.214.43:65002
             │             User: u525829715
             │             PHP 8.2.28, MariaDB 11.8.3
             │             ✅ Conectado
             │
             ├─── SFTP ──► IONOS Servidor 2 (mirror sync)
             │             access958591985.webspace-data.io:22
             │             User: u111876951
             │             ⚠️ No verificado
             │
             ├─── MySQL ─► IONOS DB
             │             db5012671937.hosting-data.io:3306
             │             ⚠️ No verificado
             │
             └─── Git ───► GitHub (origin/upstream)
                           ✅ Conectado
```

### 4.2 Redundancias y Desincronizaciones Detectadas

#### 4.2.1 Múltiples Usuarios IONOS
- **SSH:** `u525829715` en `157.173.214.43`
- **SFTP:** `u111876951` en `access958591985.webspace-data.io`
- **DB:** `dbu2309272` en `db5012671937.hosting-data.io`

**Implicaciones:**
- Posibles múltiples cuentas IONOS o subdominios
- Requiere clarificación de cuál es staging y cuál es producción
- **Acción requerida:** Mapear usuarios a entornos específicos

#### 4.2.2 Configuración SSH Duplicada
En `~/.ssh/config`:
```
Host pepecapiro
  HostName 157.173.214.43
  Port 65002
  User u525829715
  IdentityFile ~/.ssh/id_ed25519
  ...

Host pepecapiro  # DUPLICADO
  HostName 157.173.214.43
  User u525829715
  Port 65002
  IdentityFile /home/pepe/.ssh/id_ed25519
  ...
```

**Problema:** Entrada duplicada (probablemente error manual).  
**Acción requerida:** Limpiar `~/.ssh/config` eliminando duplicado.

#### 4.2.3 Ausencia de Documentación de Staging vs. Producción

**Problema detectado:**
- Los scripts `tools/ionos_*.sh` mencionan "staging"
- El workflow `verify-staging.yml` verifica "staging"
- Pero NO hay documentación clara que identifique:
  - ¿Cuál servidor IONOS es staging?
  - ¿Cuál servidor IONOS es producción?
  - ¿Qué credenciales corresponden a cada uno?

**Evidencia parcial:**
- `docs/Deployment_Master.md` menciona "Servidor staging (IONOS)" con `WP_SSH_HOST`, `WP_SSH_USER`, `WP_SSH_PASS` en GitHub Secrets
- `_reports/IONOS_STAGING_CONFIG_20251029.md` y otros reportes mencionan staging

**Acción requerida:** Crear documento de inventario de servidores IONOS (staging vs. producción).

### 4.3 Purga Reciente del Sistema Briefing

**Fecha:** 31 de octubre de 2025  
**Operación:** Eliminación completa del micrositio Briefing y sistema IA Visual

**Elementos eliminados:**
- `apps/briefing/` (442 MB, 674 archivos)
- Workflows `briefing_*.yml` (2 archivos)
- Documentación FASE4 y bitácoras (3 documentos, 1,630 líneas)
- Plugins IA Visual obsoletos
- Total: ~443 MB, ~810 archivos

**Backup creado:**
- Ubicación: `_backup_purge_briefing_ia_2025_10_31/`
- Archivo: `backup_briefing_ia_visual.tar.gz` (143 MB, 28,075 archivos)

**Elementos preservados:**
- `mirror/` (todos los snapshots)
- `tools/staging_*.sh` (129 scripts)
- `wp-content/mu-plugins/wp-staging-lite/` (integración activa)
- `plugins/runart-wpcli-bridge/` (Bridge API activo)
- `docs/integration_wp_staging_lite/` (23 documentos)

**Implicación:** El proyecto está en proceso de limpieza técnica y consolidación.

### 4.4 Estado de la Rama feat/ai-visual-implementation

**Cambios locales pendientes (git status):**
```
## feat/ai-visual-implementation...origin/feat/ai-visual-implementation
 D .github/workflows/briefing-status-publish.yml
 D .github/workflows/briefing_deploy.yml
 D apps/briefing/ (442 MB eliminados)
 D _reports/FASE4/ (196 KB eliminados)
 D data/assistants/ (32 KB eliminados)
 M STATUS.md
 M tools/cache_purge_pages.sh
 M tools/ionos_create_staging.sh
 ?? PURGA_BRIEFING_IA_FINAL_2025_10_31.md
 ?? _backup_purge_briefing_ia_2025_10_31/
 ?? estructura_directorio_*.md
 ?? informe_inventario_briefing_y_rest.md
```

**Observaciones:**
- Rama con cambios significativos no commiteados
- Purga técnica ejecutada pero no integrada a Git
- **Acción requerida:** Decidir estrategia de commit/PR para la purga

### 4.5 Configuraciones Obsoletas o Incompletas

#### 4.5.1 Variables de Entorno sin Contraseñas
`.env` tiene campos vacíos:
```bash
# SFTP_PASS=   # (vacío)
# DB_PASS=     # (vacío)
```

**Estado:** ✅ **CORRECTO** (seguridad por diseño)  
**Observación:** Las contraseñas NO deben estar en archivos de texto plano.

#### 4.5.2 Ausencia de .env.production
Se detecta:
- `.env` (genérico)
- `.env.staging` (específico staging)
- `.env.example` (template)

**Falta:** `.env.production` (específico producción)

**Acción sugerida:** Crear `.env.production` si se requiere configuración diferenciada.

---

## 5. Próximos Pasos

### 5.1 Acciones Inmediatas (Prioritarias)

1. **Mapear servidores IONOS a entornos**
   - [ ] Crear documento: `docs/infrastructure/inventario_servidores_ionos.md`
   - [ ] Identificar cuál servidor/usuario es staging y cuál es producción
   - [ ] Verificar conectividad SFTP (`u111876951@access958591985...`)
   - [ ] Verificar conectividad DB (`dbu2309272@db5012671937...`)

2. **Limpiar configuración SSH duplicada**
   - [ ] Editar `~/.ssh/config` y eliminar entrada duplicada `Host pepecapiro`
   - [ ] Validar conexión SSH después de limpieza

3. **Documentar inventario de credenciales**
   - [ ] Crear documento: `docs/infrastructure/inventario_credenciales.md` (NO committed)
   - [ ] Listar todos los usuarios, hosts, puertos por entorno
   - [ ] Incluir en `.gitignore` para evitar commit accidental

4. **Verificar Deploy Keys de GitHub**
   - [ ] Acceder a GitHub Settings → Deploy keys
   - [ ] Listar keys activas y su propósito
   - [ ] Documentar en `docs/infrastructure/github_deploy_keys.md`

5. **Integrar purga de Briefing/IA Visual**
   - [ ] Revisar cambios locales (`git status`)
   - [ ] Decidir: ¿commit directo o PR?
   - [ ] Actualizar `CHANGELOG.md` con registro de purga
   - [ ] Push a `feat/ai-visual-implementation` o crear PR a `main`

### 5.2 Tareas de Consolidación (Corto Plazo)

6. **Crear estructura /infrastructure/**
   - [ ] Establecer `docs/infrastructure/` como directorio canónico
   - [ ] Migrar documentos relevantes de `/docs/` raíz
   - [ ] Crear índice: `docs/infrastructure/README.md`

7. **Normalizar nombres de entornos**
   - [ ] Establecer convención: `local`, `staging`, `production`
   - [ ] Renombrar/reorganizar scripts en `tools/` según convención
   - [ ] Actualizar documentación para usar términos consistentes

8. **Validar workflows críticos**
   - [ ] Ejecutar manualmente `verify-staging.yml` y verificar logs
   - [ ] Ejecutar manualmente `healthcheck.yml`
   - [ ] Revisar logs de workflows programados (cron) en Actions

9. **Crear .env.production**
   - [ ] Duplicar `.env.staging` como plantilla
   - [ ] Adaptar variables para entorno de producción
   - [ ] Añadir a `.gitignore` si no está ya

10. **Documentar Application Password**
    - [ ] Verificar existencia de Application Password activo en WP-Admin
    - [ ] Documentar fecha de última rotación
    - [ ] Agendar próxima rotación (30 días)

### 5.3 Tareas de Alineación con Plan Maestro (Medio Plazo)

11. **Reestructuración según Plan Maestro**
    - [ ] Evaluar viabilidad de adoptar estructura `/local/`, `/staging/`, `/production/`
    - [ ] Si no viable, actualizar Plan Maestro para reflejar arquitectura distribuida
    - [ ] Crear ADR (Architecture Decision Record) documentando decisión

12. **Automatización de sincronización mirror/**
    - [ ] Revisar scripts en `mirror/scripts/`
    - [ ] Verificar cronología de snapshots en `mirror/raw/`
    - [ ] Considerar workflow GitHub Actions para sincronización automática

13. **Consolidar scripts de deployment**
    - [ ] Auditar scripts en `tools/` y `scripts/deploy_framework/`
    - [ ] Identificar redundancias o scripts obsoletos
    - [ ] Crear runbook unificado: `docs/infrastructure/runbook_deployment.md`

14. **Mejorar observabilidad**
    - [ ] Revisar logs de workflows programados
    - [ ] Configurar notificaciones para fallos críticos (Slack/Email)
    - [ ] Considerar dashboard de métricas (GitHub Actions insights)

15. **Plan de migración PHP/MySQL**
    - [ ] Documentar versiones actuales (PHP 8.2.28, MariaDB 11.8.3)
    - [ ] Establecer roadmap de actualizaciones
    - [ ] Crear plan de contingencia para breaking changes

---

## Anexo: Archivos y Configuraciones Clave

### Archivos de Configuración
```
.env                   # Variables entorno genéricas
.env.staging           # Variables entorno staging
.env.example           # Template de variables
~/.ssh/config          # Configuración SSH (requiere limpieza)
~/.ssh/id_ed25519      # Clave SSH privada
.gitignore             # Exclusiones Git
Makefile               # Tareas automatizadas
```

### Documentos Clave Detectados
```
docs/DEPLOY_RUNBOOK.md              # Manual operativo principal
docs/Deployment_Master.md           # Arquitectura deployment
docs/CIERRE_AUTOMATIZACION_TOTAL.md # Automatización completa
docs/CHECKLIST_EJECUTIVA_FASE7.md   # Checklist Fase 7
docs/Bridge_API.md                  # Documentación WP-CLI Bridge
README.md                           # Documentación raíz
STATUS.md                           # Estado actual proyecto
NEXT_PHASE.md                       # Próxima iteración
CHANGELOG.md                        # Historial de cambios
```

### Scripts Operativos Clave
```
tools/ionos_create_staging.sh          # Crear staging IONOS
tools/ionos_create_staging_db.sh       # Crear BD staging
tools/staging_*.sh                     # Suite de scripts staging (129)
tools/deploy_wp_ssh.sh                 # Deploy vía SSH
scripts/deploy_framework/deploy_plugin_via_rest.sh  # Deploy vía REST
scripts/setup_ssh_and_push.sh          # Setup SSH inicial
```

### Workflows GitHub Actions Críticos
```
.github/workflows/verify-staging.yml   # Health check staging diario
.github/workflows/pages-prod.yml       # Deploy Cloudflare Pages prod
.github/workflows/verify-home.yml      # Verificación Home (6h)
.github/workflows/wpcli-bridge.yml     # Build/deploy Bridge
.github/workflows/healthcheck.yml      # Health check general
```

---

## Conclusión

Este documento base proporciona una **fotografía técnica completa** del estado actual de la infraestructura de RunArt Foundry al 31 de octubre de 2025.

**Hallazgos principales:**
1. **Arquitectura distribuida:** No utiliza estructura `/local/`, `/staging/`, `/production/` del Plan Maestro.
2. **Conectividad operativa:** SSH y Git funcionando correctamente; SFTP y DB requieren verificación.
3. **Workflows maduros:** 60+ workflows GitHub Actions activos con verificaciones programadas.
4. **Limpieza reciente:** Purga de 443 MB del sistema Briefing/IA Visual ejecutada (no commiteada).
5. **Redundancias identificadas:** Múltiples usuarios IONOS, configuración SSH duplicada, falta mapeo staging/producción.

**Estado general:** ✅ **Infraestructura operativa** con oportunidades de consolidación y alineación documental.

**Siguiente fase recomendada:**
Ejecutar "5.1 Acciones Inmediatas" (tareas 1-5) antes de desarrollar la Hoja de Ruta Ejecutable completa.

---

_Generado automáticamente por GitHub Copilot — Revisión Técnica Inicial RunArt Foundry_  
_Fecha: 31 de octubre de 2025, 22:15 UTC_  
_Sistema: Linux (WSL/Ubuntu)_  
_Repositorio: ppkapiro/runart-foundry (feat/ai-visual-implementation)_
