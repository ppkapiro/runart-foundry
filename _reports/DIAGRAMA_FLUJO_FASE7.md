# 🔄 Diagrama de Flujo — Automatización Fase 7

**Actualizado:** 2025-10-20  
**Status:** ✅ Listo para usar

---

## 🎯 Flujo General (High Level)

```
┌─────────────────────────────────────────────────────────────────────┐
│                   FASE 7: RECOLECCIÓN AUTOMÁTICA                    │
│                                                                     │
│  Objetivo: Recolectar evidencias (repo/local/SSH/REST)             │
│            sin secretos, consolidar documentos, proponer ADR       │
└─────────────────────────────────────────────────────────────────────┘

                            START
                              │
                              ▼
                    ┌──────────────────┐
                    │  Paso 1:         │
                    │  Ejecutar        │◄─── (Opcional: exportar
                    │  collect_        │     WP_SSH_HOST)
                    │  evidence.sh     │
                    └─────────┬────────┘
                              │
                    ┌─────────▼──────────┐
                    │  Genera 4          │
                    │  templates:        │
                    │  • repo ✅         │
                    │  • local ✅        │
                    │  • ssh ⏳          │
                    │  • rest ⏳         │
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  Paso 2:         │
                    │  Ejecutar        │
                    │  process_        │
                    │  evidence.py     │
                    └─────────┬────────┘
                              │
                    ┌─────────▼──────────────────┐
                    │  Detecta estados:          │
                    │  • Repo: OK                │
                    │  • Local: OK               │
                    │  • SSH: PENDIENTE          │
                    │  • REST: PENDIENTE         │
                    └─────────┬──────────────────┘
                              │
                    ┌─────────▼──────────────────────┐
                    │  Actualiza documentos:         │
                    │  • 000_state_snapshot          │
                    │  • 010_repo_access             │
                    │  • 020_local_mirror            │
                    │  • 030_ssh_connectivity        │
                    │  • 040_wp_rest                 │
                    │  • 060_risk_register           │
                    │  • Issue_50 (consolidado)      │
                    └─────────┬──────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  Propone ADR:    │
                    │  🟢 Preview      │
                    │     Primero      │
                    │  (BAJO RIESGO)   │
                    └─────────┬────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  Paso 3:         │
                    │  git add + push  │
                    │  Crear PR        │
                    └─────────┬────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  Owner revisa:   │
                    │  • Issue #50     │
                    │  • ADR           │
                    │  • Decide:       │
                    │    Preview /     │
                    │    Styling /     │
                    │    Mixto         │
                    └─────────┬────────┘
                              │
         ┌────────────────────┼────────────────────┐
         │                    │                    │
         ▼                    ▼                    ▼
    ┌─────────┐          ┌─────────┐          ┌─────────┐
    │ Preview │          │ Styling │          │  Mixto  │
    │ Primero │          │ Primero │          │Coordinado
    │(Escogido)          │         │          │         │
    └────┬────┘          └────┬────┘          └────┬────┘
         │                    │                    │
         ▼                    ▼                    ▼
    ┌─────────────┐    ┌────────────┐    ┌──────────────┐
    │ Owner:      │    │ Owner:     │    │ Owner:       │
    │ • Prepara   │    │ • Listar   │    │ • Preparar   │
    │   staging   │    │   cambios  │    │   staging    │
    │ • Copia BD  │    │   tema     │    │ • Listar     │
    │ • Crea user │    │ • Aplica en│    │   cambios    │
    │ • App Pass  │    │   staging  │    │ • Coordinar  │
    └────┬────────┘    │ • Valida   │    │   ambas      │
         │             └────┬───────┘    └──────┬───────┘
         │                  │                   │
         ▼                  ▼                   ▼
    ┌────────────┐     ┌───────────┐     ┌──────────┐
    │ 070_preview│     │ Ejecuta   │     │  Ejecuta │
    │_staging_   │     │ workflows │     │ workflows│
    │ plan.md    │     │ en staging│     │ ambas    │
    └────┬───────┘     │           │     │          │
         │             └─────┬─────┘     └────┬─────┘
         │                   │                │
         ▼                   ▼                ▼
    ┌─────────────────────────────────────────┐
    │  Copilot: Ejecutar workflows (verify-*) │
    │  • verify-home                          │
    │  • verify-settings                      │
    │  • verify-menus                         │
    │  • verify-media                         │
    └────────────────────┬────────────────────┘
                         │
                         ▼
                    ┌──────────────┐
                    │  ¿OK?        │
                    └──┬───────┬───┘
                       │       │
                    SÍ │       │ NO
                       │       │
                       ▼       ▼
                    OK     ROLLBACK
                       │    (revert a
                       │    staging/
                       │    placeholder)
                       │       │
                       └───┬───┘
                           │
                           ▼
                    ┌──────────────────┐
                    │ ✅ FASE 7        │
                    │ COMPLETADA       │
                    └──────────────────┘
```

---

## 📝 Detalle: Paso 1 (Recolección)

```
tools/fase7_collect_evidence.sh
           │
           ├─── [Repo] ──────────┬──→ git remote -v
           │                     ├──→ git rev-parse HEAD
           │                     └──→ ls .github/workflows/
           │
           ├─── [Local] ─────────┬──→ du -sh /mirror
           │                     ├──→ tree /mirror -L 2
           │                     └──→ Estructura + tamaños
           │
           ├─── [SSH] ──────┬────┬──→ ssh "$HOST" 'uname -a'
           │   (opcional)   ├──→ ssh "$HOST" 'php -v'
           │                ├──→ ssh "$HOST" 'nginx -v'
           │                └──→ ssh "$HOST" 'mysql -V'
           │
           └─── [REST] ─────┬──→ curl /wp-json/ (HTTP status)
                   (ping)   └──→ curl /wp-json/wp/v2/users/me
                                  (sin auth → esperar 401)

                              ▼

                       4 TEMPLATES POBLADOS:
                       ✅ evidencia_repo_remotes.txt
                       ✅ evidencia_local_mirror.txt
                       ✅ evidencia_server_versions.txt (opt)
                       ✅ evidencia_rest_sample.txt
```

---

## 📝 Detalle: Paso 2 (Procesamiento)

```
tools/fase7_process_evidence.py
           │
           ├─── LEE templates ──→ Detecta estados
           │                       ✅ OK / 🟡 PARCIAL
           │                       ⏳ PENDIENTE / 🔴 ERROR
           │
           └─── ACTUALIZA documentos:
                   │
                   ├──→ 000_state_snapshot_checklist.md
                   │    + Hallazgos consolidados
                   │    + Matriz: Repo|Local|SSH|REST
                   │    + Interpretación
                   │    + Acciones inmediatas
                   │
                   ├──→ 010_repo_access_inventory.md
                   │    + Remotes detectados
                   │    + Workflows listados (26)
                   │
                   ├──→ 020_local_mirror_inventory.md
                   │    + Mirror 760M disponible
                   │    + Árbol de estructura
                   │
                   ├──→ 030_ssh_connectivity_and_server_facts.md
                   │    + SSH status (PENDIENTE si no config)
                   │    + Instrucciones para owner
                   │
                   ├──→ 040_wp_rest_and_authn_readiness.md
                   │    + REST API status
                   │    + Notas de validación
                   │
                   ├──→ 060_risk_register_fase7.md
                   │    + Mitigaciones post-verificación
                   │    + R1/R2 actualizados según evidencia
                   │
                   └──→ Issue_50_Fase7_Conexion_WordPress_Real.md
                        + NUEVA sección: "Resultado Verificación"
                        + Matriz de estado
                        + Decisión recomendada (🟢 Preview)
                        + Inputs del owner
                        + Checklists próximos

                              ▼

                       CONSOLIDACIÓN COMPLETADA
                       + ADR Propuesto (Preview Primero)
                       + Plan Operativo Ready (070)
```

---

## 🎯 Decisión: Matriz de Evaluación

```
┌────────────────────────────────────────────────────────────────┐
│                    3 OPCIONES EVALUADAS                        │
└────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ OPCIÓN 1: Styling Primero                                       │
├─────────────────────────────────────────────────────────────────┤
│ Duración: ~1 semana                                             │
│ Riesgo: 🟡 MEDIO-ALTO                                           │
│ Approach: Cambiar tema → staging → prod                        │
│ Ventajas:                                                       │
│   + Rápido para cambios UI puros                               │
│   + Sin credenciales en staging                                │
│ Desventajas:                                                    │
│   - Workflows aún no validados en sitio real                   │
│   - Si falla en prod, impacto directo                          │
│   - No prueba REST API antes de pasar credenciales             │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ OPCIÓN 2: Preview Primero ⭐ RECOMENDADA                        │
├─────────────────────────────────────────────────────────────────┤
│ Duración: ~2 semanas                                            │
│ Riesgo: 🟢 BAJO                                                 │
│ Approach: Staging con creds real → workflows → prod            │
│ Ventajas:                                                       │
│   + Valida workflows contra WordPress REAL sin prod            │
│   + Identifica bloqueadores ANTES (como REST API)              │
│   + Si falla, staging absorbe el impacto                       │
│   + Prueba credenciales en entorno seguro primero              │
│   + Reversible: Si falla, simplemente revertir variables       │
│ Desventajas:                                                    │
│   - 2 semanas vs 1 semana                                      │
│   - Requiere infraestructura staging (owner prep)              │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ OPCIÓN 3: Mixto Coordinado                                      │
├─────────────────────────────────────────────────────────────────┤
│ Duración: ~1.5 semanas                                          │
│ Riesgo: 🟡 MEDIO                                                │
│ Approach: Cambios críticos staging + styling en paralelo       │
│ Ventajas:                                                       │
│   + Balance entre velocidad y seguridad                         │
│   + Algunas validaciones antes de prod                          │
│ Desventajas:                                                    │
│   - Coordinación más compleja                                  │
│   - Riesgo residual si algo falla en paralelo                  │
│   - Menos predictible que Preview Primero                      │
└─────────────────────────────────────────────────────────────────┘

          🟢 RECOMENDACIÓN: OPCIÓN 2 — PREVIEW PRIMERO
          
          Razón principal: Identifica bloqueadores ANTES de prod
          (Como REST API que falló en DNS)
```

---

## 🚀 Flujo: Decisión → Ejecución

```
┌──────────────────────────────────────────────────────────────────┐
│ OWNER ELIGE EN ISSUE #50                                        │
└──────────────────────────────────────────────────────────────────┘

        ┌─────────────────────────────────────────┐
        │  OWNER MARCA CHECKBOX EN ISSUE #50:      │
        │  "He decidido: [✓] Preview Primero"     │
        └──────────────┬──────────────────────────┘
                       │
         ┌─────────────▼─────────────────────────────────────┐
         │ COPILOT NOTIFICADO: PROCEDER CON 070 PLAN        │
         └─────────────┬─────────────────────────────────────┘
                       │
    ┌──────────────────▼──────────────────────────────────────┐
    │ 070_preview_staging_plan.md                            │
    │                                                         │
    │ 1. Owner prepara staging:                              │
    │    • Hostname: staging.runalfondry.com                │
    │    • BD fresca importada                              │
    │    • wp-content/ replicado (uploads, plugins, theme)  │
    │    • Usuario WP técnico creado                        │
    │    • Application Password generado                    │
    │                                                         │
    │ 2. Owner carga variables en GitHub:                    │
    │    • WP_BASE_URL = https://staging.runalfondry.com   │
    │    • WP_USER = github-actions                         │
    │    • WP_APP_PASSWORD = *** (secret)                  │
    │                                                         │
    │ 3. Copilot ejecuta workflows en staging:               │
    │    • verify-home (HTTP + structure check)             │
    │    • verify-settings (WordPress settings)             │
    │    • verify-menus (Navigation OK?)                    │
    │    • verify-media (Media library accessible?)         │
    │                                                         │
    │ 4. Si todos OK → cambiar variables a prod:            │
    │    • WP_BASE_URL = https://runalfondry.com           │
    │    • Ejecutar workflows en prod                       │
    │    • Validación final                                 │
    │                                                         │
    │ 5. Resultado: ✅ FASE 7 COMPLETADA                   │
    └─────────────────────────────────────────────────────────┘
```

---

## 📊 Timeline Estimado

```
HOY (2025-10-20)
├─ 15:00 — Copilot ejecuta collect_evidence.sh
├─ 15:05 — Copilot ejecuta process_evidence.py
├─ 15:10 — Documentos consolidados + PR abierto
└─ 15:15 — Notificación al Owner

MAÑANA (2025-10-21)
├─ Owner revisa Issue #50
├─ Owner valida REST API (curl /wp-json/)
└─ Owner elige decisión (Preview/Styling/Mixto)

MAÑANA NOCHE (2025-10-21 PM)
├─ (Si Preview elegido)
├─ Owner prepara staging: ~2-3 horas
│  ├─ Hostname + SSL
│  ├─ BD importada
│  ├─ wp-content/ replicado
│  ├─ Usuario + App Password
│  └─ Variables en GitHub
└─ Owner notifica: "Staging ready"

PASADO MAÑANA (2025-10-22)
├─ Copilot ejecuta verify-* en staging (~45 min)
├─ Si OK → cambiar variables a prod
├─ Copilot ejecuta verify-* en prod (~45 min)
├─ Adjuntar artifacts en Issue #50
└─ ✅ FASE 7 COMPLETADA

Total: 2-3 DÍAS si Preview Primero elegido
       1-2 SEMANAS si Styling o Mixto elegido
```

---

## 🔑 Puntos de Control

```
┌─────────────────────────────────────────────────────────────────┐
│                    CHECKPOINTS CRÍTICOS                        │
└─────────────────────────────────────────────────────────────────┘

✅ CHECKPOINT 1: REST API Accesible
   Question: ¿/wp-json/ responde?
   If NO → 🔴 BLOQUEADOR — Habilitar en WP-Admin
   If YES → ✅ Continuar

✅ CHECKPOINT 2: Staging Disponible (si Preview elegido)
   Question: ¿Existe hostname staging con BD + wp-content?
   If NO → ⏳ Owner prepara (2-3 horas)
   If YES → ✅ Cargar variables en GitHub

✅ CHECKPOINT 3: Credenciales en GitHub
   Question: ¿WP_BASE_URL, WP_USER, WP_APP_PASSWORD loaded?
   If NO → ⏳ Owner carga secretos
   If YES → ✅ Ejecutar workflows

✅ CHECKPOINT 4: Workflows OK en Staging
   Question: ¿All 4 verify-* workflows pass?
   If NO → 🔴 BLOQUEADOR — Debug + rollback
   If YES → ✅ Cambiar variables a prod

✅ CHECKPOINT 5: Workflows OK en Producción
   Question: ¿All 4 verify-* workflows pass en prod?
   If NO → 🔴 BLOQUEADOR — Revert variables a staging
   If YES → ✅ ¡FASE 7 COMPLETADA!
```

---

## 📍 Entregables por Checkpoint

```
╔═══════════════════════════════════════════════════════════════════╗
║           Autores y Responsables por Fase                       ║
╠═══════════════════════════════════════════════════════════════════╣
║ Fase 1: Recolección (hoy 2025-10-20)                           ║
║ • Copilot: Scripts bash + Python                                ║
║ • Owner: Validar REST API (curl) — 10 min                       ║
║                                                                   ║
║ Fase 2: Consolidación (hoy 2025-10-20)                         ║
║ • Copilot: Documentos + ADR + Issue #50                        ║
║ • Owner: Revisar + confirmar decisión — 30 min                  ║
║                                                                   ║
║ Fase 3: Preparación Staging (mañana, si Preview) — 2-3 horas   ║
║ • Owner: Infraestructura                                        ║
║ • Copilot: Esperar + ejecutar workflows                        ║
║                                                                   ║
║ Fase 4: Validación + Transición (pasado mañana) — 2 horas      ║
║ • Copilot: Ejecutar verify-* staging → prod                   ║
║ • Owner: Monitorear + validar resultados                       ║
║                                                                   ║
║ Fase 5: Cierre (pasado mañana) — 30 min                        ║
║ • Copilot: Documentar artifacts + cerrar Issue #50            ║
║ • Owner: Confirmar ✅ FASE 7 completada                        ║
╚═══════════════════════════════════════════════════════════════════╝
```

---

**Creado por:** Copilot Fase 7  
**Última actualización:** 2025-10-20 15:35 UTC  
**Status:** ✅ Producción
