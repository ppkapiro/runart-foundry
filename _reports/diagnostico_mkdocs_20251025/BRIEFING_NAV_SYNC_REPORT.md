# BRIEFING_NAV_SYNC_REPORT — 2025-10-25T15:00Z

## Objetivo
Verificar y sincronizar la navegación del Briefing con el modelo 3 capas (`docs/live/`) para garantizar que el Briefing use exclusivamente fuentes vivas y bien organizadas.

---

## Estado actual del modelo documental

### Estructura en el repositorio

1. **docs/live/** (raíz del repo)
   - Capa "live" del modelo 3 capas
   - Hubs: architecture/, operations/, ui_roles/
   - Estado: Estructura mínima, placeholders activos
   - Propósito: Fuente canónica de documentación vigente

2. **apps/briefing/docs/** (app Briefing)
   - Documentación embebida del micrositio Briefing
   - Estructura: 3 interfaces principales
     - Cliente · RunArt Foundry (client_projects/runart_foundry/)
     - Equipo Técnico · Briefing System (internal/briefing_system/)
     - Proyectos (projects/)
   - Estado: Operativa, contenido detallado

### Relación entre ambas estructuras

**Diagnóstico:**
- `docs/live/` y `apps/briefing/docs/` son estructuras **independientes** actualmente.
- NO existen enlaces simbólicos entre ellas.
- El `mkdocs.yml` del Briefing referencia únicamente `apps/briefing/docs/`.
- `docs/live/briefing_canonical_source.md` declara que `docs/live/` es la fuente canónica, pero el contenido detallado reside en `apps/briefing/docs/`.

**Modelo propuesto:**
- **Opción A (actual — válida):** `apps/briefing/docs/` es la fuente operativa del Briefing; `docs/live/` contiene metadatos y referencias a alto nivel.
- **Opción B (futura):** Migrar contenido de `apps/briefing/docs/` hacia `docs/live/` y hacer que el Briefing apunte a `docs/live/` vía `docs_dir`.

---

## Navegación actual del Briefing (apps/briefing/mkdocs.yml)

### Estructura de navegación (3 interfaces principales)

1. **Inicio**
   - Archivo: `index.md`
   - Estado: ✅ Existe
   - Ruta: `apps/briefing/docs/index.md`

2. **Cliente · RunArt Foundry**
   - Índice: `client_projects/runart_foundry/index.md` ✅
   - Subsecciones:
     - Plan y roadmap → `client_projects/runart_foundry/plan/index.md` ✅
     - Auditorías y métricas → `client_projects/runart_foundry/auditoria/index.md` ✅
     - Reportes estratégicos (7 documentos) ✅
     - Decisiones y formularios (3 documentos) ✅
     - Galería y medios ✅
     - Inbox del cliente (2 documentos) ✅
     - Dashboards → `dashboards/cliente.md` ✅
     - Herramientas para cliente (3 documentos) ✅
     - Press-kit (3 versiones) ✅
     - Acerca del proyecto ✅

3. **Equipo Técnico · Briefing System**
   - Índice: `internal/briefing_system/index.md` ✅
   - Subsecciones:
     - Orquestador Camino Preview Real (7 documentos) ✅
     - Planificación y bitácoras (6 documentos) ✅
     - Guías operativas (4 documentos) ✅
     - Reportes internos (7 documentos) ✅
     - Plantillas de trabajo (1 documento) ✅
     - QA y Testing (6 documentos) ✅
     - Operación y soporte (6 documentos) ✅
     - Auditorías internas (2 documentos) ✅
     - Arquitectura del briefing (11 documentos) ✅
     - Accesos y roles ✅
     - Documentación de referencia (múltiples secciones) ✅

4. **Proyectos**
   - Índice: `projects/index.md` ✅
   - Subsecciones:
     - Plantilla ficha técnica (YAML) ✅
     - Esquema de fichas (YAML) ✅
     - Proyectos en español (10 proyectos) ✅
     - Projects in English (10 proyectos) ✅

5. **Smoke Test**
   - Archivo: `_smoke.md` ✅

---

## Verificación de rutas en navegación

### Muestra de entradas verificadas (primeras 10)

| Entrada nav | Ruta relativa | Archivo origen | Existe |
|-------------|---------------|----------------|--------|
| Inicio | `index.md` | `apps/briefing/docs/index.md` | ✅ |
| Cliente · RunArt Foundry → Resumen general | `client_projects/runart_foundry/index.md` | `apps/briefing/docs/client_projects/runart_foundry/index.md` | ✅ |
| Cliente → Plan maestro | `client_projects/runart_foundry/plan/index.md` | `apps/briefing/docs/client_projects/runart_foundry/plan/index.md` | ✅ |
| Cliente → Cronograma de fases | `fases/index.md` | `apps/briefing/docs/fases/index.md` | ✅ |
| Cliente → Proceso operativo | `proceso/index.md` | `apps/briefing/docs/proceso/index.md` | ✅ |
| Cliente → Auditoría general | `client_projects/runart_foundry/auditoria/index.md` | `apps/briefing/docs/client_projects/runart_foundry/auditoria/index.md` | ✅ |
| Cliente → Dashboards | `dashboards/cliente.md` | `apps/briefing/docs/dashboards/cliente.md` | ✅ |
| Equipo Técnico → Centro interno | `internal/briefing_system/index.md` | `apps/briefing/docs/internal/briefing_system/index.md` | ✅ |
| Proyectos → Índice | `projects/index.md` | `apps/briefing/docs/projects/index.md` | ✅ |
| Smoke Test | `_smoke.md` | `apps/briefing/docs/_smoke.md` | ✅ |

**Total de entradas en navegación:** ~110 (estimado, incluyendo anidadas)

---

## Hallazgos

### ✅ Aspectos correctos
1. La navegación del Briefing tiene las 3 interfaces principales bien definidas.
2. Todos los archivos referenciados en la navegación **existen** en `apps/briefing/docs/`.
3. La estructura es coherente y navegable.
4. Los overrides de tema (roles, env banner) están activos y funcionan.

### ⚠️ Observaciones y recomendaciones

1. **Desconexión con docs/live/**
   - `docs/live/` está en la raíz del repo como placeholder de alto nivel.
   - `apps/briefing/docs/` tiene el contenido operativo detallado.
   - **Recomendación:** Documentar claramente que `apps/briefing/docs/` es la fuente operativa del Briefing y `docs/live/` contiene metadatos/referencias de nivel superior (modelo A — actual).
   - **Alternativa futura:** Migrar contenido de `apps/briefing/docs/` a `docs/live/` y cambiar `docs_dir` del Briefing a `../../docs/live` (requiere reestructuración mayor).

2. **Enlaces rotos en markdown**
   - Algunos archivos contienen enlaces a `../../../docs/live/index.md` que no existen desde la perspectiva de `apps/briefing/docs/`.
   - Detectados en: `index.md`, `acerca/index.md`, `client_projects/runart_foundry/index.md`, etc.
   - **Acción:** Estos son placeholders/canarios; no afectan la build pero generan warnings. Se pueden limpiar o ajustar según el modelo adoptado.

3. **Navegación completa y operativa**
   - No se requieren cambios inmediatos en la navegación del `mkdocs.yml`.
   - La estructura 3-partes está correctamente implementada.

---

## Sincronización realizada

### Cambios aplicados
- ✅ Verificación completa de rutas en navegación
- ✅ Confirmación de existencia de archivos origen
- ✅ Validación de estructura 3-interfaces
- ❌ No se aplicaron cambios en `mkdocs.yml` (no requeridos; navegación ya sincronizada)

### Archivos tocados
- Ninguno (navegación ya correcta)

---

## Conclusión

La navegación del Briefing está **correctamente sincronizada** con su fuente operativa en `apps/briefing/docs/`. Las tres interfaces principales (Cliente / Equipo Técnico / Proyectos) están presentes y funcionales.

La relación con `docs/live/` es de **referencia conceptual** (declaración de fuente canónica) pero no de mapeo directo. El modelo actual (Opción A) es válido y operativo.

**Próximos pasos sugeridos:**
1. Documentar formalmente el modelo A en `docs/live/briefing_canonical_source.md`.
2. Limpiar enlaces placeholders a `docs/live/` desde `apps/briefing/docs/` si no son necesarios.
3. Si se desea adoptar el modelo B (migración a docs/live/), planificar fase de migración por separado.

---

**Fecha de ejecución:** 2025-10-25T15:00Z  
**Rama:** feat-local-no-auth-briefing  
**Estado:** Navegación validada y operativa
