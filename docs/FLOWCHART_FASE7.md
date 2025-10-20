```mermaid
graph TD
    START["🟢 START: Fase 7 Preview Primero"] --> CHECK_PREP{"✅ Pre-requisitos?<br/>SSH, DNS, gh CLI, WP-Admin"}
    
    CHECK_PREP -->|NO| FAIL_PREP["🔴 BLOCKED<br/>Resuelve pre-requisitos"]
    FAIL_PREP --> END_FAIL["❌ FAILED"]
    
    CHECK_PREP -->|SÍ| FASE1["📍 FASE 1: Crear Staging (45 min)<br/>1.1 DNS | 1.2 HTTPS | 1.3 Archivos | 1.4 BD<br/>1.5 wp-config.php | 1.6 Verificación | 1.7 Usuario"]
    
    FASE1 --> CHECK_STAGING_READY{"Staging<br/>running?"}
    CHECK_STAGING_READY -->|NO| FIX_STAGING["🔧 Troubleshoot Staging"]
    FIX_STAGING --> CHECK_STAGING_READY
    
    CHECK_STAGING_READY -->|SÍ| FASE2["🔐 FASE 2: Cargar Secrets GitHub (5 min)<br/>WP_BASE_URL (staging) | WP_USER | WP_APP_PASSWORD"]
    
    FASE2 --> CHECK_SECRETS_LOADED{"Secrets<br/>en GitHub?"}
    CHECK_SECRETS_LOADED -->|NO| FIX_SECRETS["🔧 Verificar gh CLI"]
    FIX_SECRETS --> CHECK_SECRETS_LOADED
    
    CHECK_SECRETS_LOADED -->|SÍ| FASE3["▶️ FASE 3: Ejecutar verify-* STAGING (20 min)<br/>1. verify-home → Auth=OK<br/>2. verify-settings → Compliance=OK<br/>3. verify-menus → Auth=OK<br/>4. verify-media → MISSING ≤ 3"]
    
    FASE3 --> CHECK_STAGING_WF{"Todo 4/4<br/>PASSED?"}
    CHECK_STAGING_WF -->|NO| FIX_STAGING_WF["🔧 Investigar artifacts<br/>Regenerar App Password"]
    FIX_STAGING_WF --> FASE3
    
    CHECK_STAGING_WF -->|SÍ| FASE4["📋 FASE 4: Documentar Staging (10 min)<br/>Descargar artifacts | Actualizar Issue #50"]
    
    FASE4 --> FASE5["🚀 FASE 5: Promover a PROD (10 min)<br/>Cambiar WP_BASE_URL → runalfondry.com<br/>Generar App Password en WP-PROD<br/>Actualizar secret WP_APP_PASSWORD"]
    
    FASE5 --> WARNING["⚠️ ADVERTENCIA<br/>Ya estamos en PRODUCCIÓN<br/>Punto de no retorno"]
    
    WARNING --> CONFIRM_PROD{"¿Estás seguro?<br/>Staging ✅ validado?"}
    CONFIRM_PROD -->|NO| ROLLBACK_PREP["⏮️ ROLLBACK: Revert a staging<br/>WP_BASE_URL → https://staging..."]
    ROLLBACK_PREP --> END_FAIL
    
    CONFIRM_PROD -->|SÍ| FASE6["✅ FASE 6: Validar PROD (20 min)<br/>1. verify-home → Auth=OK, 200 OK<br/>2. verify-settings → Compliance=OK<br/>3. verify-menus → Auth=OK<br/>4. verify-media → MISSING ≤ 3"]
    
    FASE6 --> CHECK_PROD_WF{"Todo 4/4<br/>PASSED?"}
    CHECK_PROD_WF -->|NO| FIX_PROD_WF["🔧 Rollback: WP_BASE_URL → staging<br/>Investigar issue<br/>Reagendar"]
    FIX_PROD_WF --> END_FAIL
    
    CHECK_PROD_WF -->|SÍ| FASE7["🏁 FASE 7: Cierre Documental (20 min)<br/>Issue #50: Marcar COMPLETO<br/>CHANGELOG.md: Agregar entrada<br/>Commits + Push<br/>Merge PR → main"]
    
    FASE7 --> CHECK_CIERRE{"Cierre<br/>completado?"}
    CHECK_CIERRE -->|NO| FIX_CIERRE["🔧 Completar documentación"]
    FIX_CIERRE --> CHECK_CIERRE
    
    CHECK_CIERRE -->|SÍ| SUCCESS["🟢 SUCCESS: Fase 7 ✅ COMPLETADA<br/>PROD running con WordPress REAL"]
    SUCCESS --> END_SUCCESS["🎉 FINISHED"]
    
    style START fill:#90EE90
    style SUCCESS fill:#90EE90
    style END_SUCCESS fill:#90EE90
    style END_FAIL fill:#FF6B6B
    style FAIL_PREP fill:#FF6B6B
    style WARNING fill:#FFD700
    style CONFIRM_PROD fill:#FFD700
    style ROLLBACK_PREP fill:#FFB347
    
    classDef phase fill:#87CEEB,stroke:#333,stroke-width:2px,color:#000
    classDef check fill:#F0E68C,stroke:#333,stroke-width:2px,color:#000
    classDef action fill:#DDA0DD,stroke:#333,stroke-width:2px,color:#000
    
    class FASE1,FASE2,FASE3,FASE4,FASE5,FASE6,FASE7 phase
    class CHECK_PREP,CHECK_STAGING_READY,CHECK_SECRETS_LOADED,CHECK_STAGING_WF,CHECK_PROD_WF,CHECK_CIERRE check
    class FIX_STAGING,FIX_SECRETS,FIX_STAGING_WF,FIX_PROD_WF,FIX_CIERRE action
```

---

# 📊 DIAGRAM EXPLICADO

## Flujo Principal (Happy Path ✅)

```
START
  ↓
Verificar pre-requisitos
  ↓
FASE 1: Crear Staging (45 min)
  ├─ DNS + HTTPS + Archivos + BD + Config + Usuario
  └─ ✅ Staging running
  ↓
FASE 2: Cargar Secrets GitHub (5 min)
  └─ ✅ WP_BASE_URL=staging, credentials en GitHub
  ↓
FASE 3: Validar Staging (20 min)
  ├─ verify-home PASSED
  ├─ verify-settings PASSED
  ├─ verify-menus PASSED
  └─ verify-media PASSED (Auth=OK todos)
  ↓
FASE 4: Documentar Staging (10 min)
  └─ ✅ Artifacts descargados, Issue #50 actualizado
  ↓
⚠️ PUNTO CRÍTICO: Promover a PRODUCCIÓN
  ↓
FASE 5: Cambiar a PROD (10 min)
  └─ WP_BASE_URL=prod, App Password regenerado
  ↓
FASE 6: Validar PROD (20 min)
  ├─ verify-home PASSED
  ├─ verify-settings PASSED
  ├─ verify-menus PASSED
  └─ verify-media PASSED (Auth=OK todos)
  ↓
FASE 7: Cierre (20 min)
  ├─ Issue #50 → COMPLETADO
  ├─ CHANGELOG.md → entry agregada
  └─ PR → merged a main
  ↓
🎉 SUCCESS
```

## Flujos de Error (Troubleshooting)

### Si Pre-requisitos No OK
```
START → ❌ Pre-requisitos KO → Resuelve (SSH/DNS/CLI) → Reinicia
```

### Si Staging No Corre
```
FASE 1 → ❌ Staging no running → Troubleshoot → Reinicia FASE 1
```

### Si Staging Workflows Fallan
```
FASE 3 → ❌ Workflow FAILED → Ver artifacts → Regenerar App Password → Reinicia FASE 3
```

### Si Prod Workflows Fallan
```
FASE 6 → ❌ Workflow FAILED → ⏮️ ROLLBACK a Staging → Investigar → Reagendar
```

## Timeline Visual

```
STAGING PHASE (1h 20 min)
├─ FASE 1: 45 min [████████████████████████████████████]
├─ FASE 2:  5 min [██]
├─ FASE 3: 20 min [██████████]
└─ FASE 4: 10 min [█████]

PRODUCTION PHASE (50 min)
├─ FASE 5: 10 min [█████]
├─ FASE 6: 20 min [██████████]
└─ FASE 7: 20 min [██████████]

TOTAL: 2h 10 min (+ 30 min buffer = 2.5-3h nominal, up to 3.5-4.5h si hay troubleshooting)
```

## Criterios de Éxito (Definition of Done)

```
Staging ✅
  ☐ verify-home: 200 OK, Auth=OK
  ☐ verify-settings: Compliance=OK, Auth=OK
  ☐ verify-menus: OK, Auth=OK
  ☐ verify-media: OK, Auth=OK, MISSING ≤ 3

Production ✅
  ☐ verify-home: 200 OK, Auth=OK
  ☐ verify-settings: Compliance=OK, Auth=OK
  ☐ verify-menus: OK, Auth=OK
  ☐ verify-media: OK, Auth=OK, MISSING ≤ 3

Documentation ✅
  ☐ Issue #50: Staging section completed
  ☐ Issue #50: Production section completed
  ☐ CHANGELOG.md: Fase 7 entry added
  ☐ Artifacts: All 8 files downloaded (4 staging + 4 prod)

Seguridad ✅
  ☐ No secrets in git (grep check passed)
  ☐ No secrets in logs
  ☐ App Passwords rotated
  ☐ Backups verified

Finalización ✅
  ☐ PR merged to main
  ☐ Branch deleted
  ☐ Fase 7 status: COMPLETADA
```
