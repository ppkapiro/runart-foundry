# 🚀 Guía Rápida — Scripts de Automatización Fase 7

**Ubicación:** `/tools/`  
**Fecha creación:** 2025-10-20  
**Status:** ✅ Listos para usar

---

## 📋 Índice

1. **Script 1: Recolección** (`fase7_collect_evidence.sh`)
2. **Script 2: Procesamiento** (`fase7_process_evidence.py`)
3. **Tareas VS Code** (`.vscode/tasks.json`)
4. **Variables de Ambiente** (opcional)

---

## 1️⃣ Script de Recolección

### Ubicación
```
tools/fase7_collect_evidence.sh
```

### Qué Hace
- Recolecta **Repo** (git remotes, branches, workflows)
- Recolecta **Local** (mirror local, árbol de estructura)
- Recolecta **SSH** (si está configurado — versiones SO, PHP, Web, DB)
- Recolecta **REST** (ping a /wp-json/, status HTTP)

### Cómo Ejecutar

#### Opción 1: Desde Terminal
```bash
cd /home/pepe/work/runartfoundry
bash tools/fase7_collect_evidence.sh
```

#### Opción 2: Desde VS Code (Tarea)
1. `Ctrl+Shift+P` (o `Cmd+Shift+P`)
2. Buscar: `Run Task`
3. Seleccionar: `Fase7: Collect Evidence`
4. Terminal se abrirá con output

### Output
Genera 4 archivos en `_templates/`:
- ✅ `evidencia_repo_remotes.txt` — Git remotes + workflows
- ✅ `evidencia_local_mirror.txt` — Árbol del mirror local
- ✅ `evidencia_server_versions.txt` — Información servidor (SSH)
- ✅ `evidencia_rest_sample.txt` — Ping a /wp-json/

### Variables de Ambiente (Opcional)

El script acepta variables para personalizar:

```bash
# Ubicación del mirror local (default: ./mirror)
export WP_LOCAL_MIRROR_DIR="/ruta/custom/mirror"

# SSH a servidor (default: vacío → PENDIENTE)
export WP_SSH_HOST="usuario@hostname"
export WP_SSH_PORT=22

# URL base para REST API probe (default: https://runalfondry.com)
export WP_BASE_PROBE_URL="https://staging.example.com"
```

### Ejemplo: Ejecutar con SSH
```bash
export WP_SSH_HOST="github-actions@prod.server.com"
bash tools/fase7_collect_evidence.sh
```

### Ejemplo: Ejecutar con Mirror Custom
```bash
export WP_LOCAL_MIRROR_DIR="~/Downloads/wordpress-snapshot-2025-10-20"
bash tools/fase7_collect_evidence.sh
```

### Notas
- ✅ **No requiere credenciales reales** — Solo recolecta datos públicos
- ✅ **Sanitización automática** — Enmasca Authorization headers, tokens, passwords
- ✅ **Sin fallos si SSH no disponible** — Marca "(PENDIENTE)" y continúa
- ✅ **Idempotente** — Puedes ejecutar múltiples veces

---

## 2️⃣ Script de Procesamiento

### Ubicación
```
tools/fase7_process_evidence.py
```

### Qué Hace
- Lee los 4 templates generados por el script de recolección
- Detecta estados automáticamente: ✅ OK / 🟡 PARCIAL / ⏳ PENDIENTE / 🔴 ERROR
- Actualiza automáticamente:
  - `000_state_snapshot_checklist.md` (matriz + hallazgos)
  - `010_repo_access_inventory.md` (remotes + workflows)
  - `020_local_mirror_inventory.md` (estructura mirror)
  - `030_ssh_connectivity_and_server_facts.md` (status SSH)
  - `040_wp_rest_and_authn_readiness.md` (REST readiness)
  - `060_risk_register_fase7.md` (mitigaciones)
  - `Issue_50_Fase7_Conexion_WordPress_Real.md` (consolidación + ADR)

### Cómo Ejecutar

#### Opción 1: Desde Terminal
```bash
cd /home/pepe/work/runartfoundry
python3 tools/fase7_process_evidence.py
```

#### Opción 2: Desde VS Code (Tarea)
1. `Ctrl+Shift+P` (o `Cmd+Shift+P`)
2. Buscar: `Run Task`
3. Seleccionar: `Fase7: Process Evidence`
4. Terminal se abrirá con output

### Output
```
======================================================================
FASE 7 — PROCESAMIENTO AUTOMÁTICO DE EVIDENCIAS
======================================================================

📊 Detectando estados de evidencias...

  REPO   → ✅ OK
  LOCAL  → ✅ OK
  SSH    → ⏳ PENDIENTE
  REST   → ⏳ PENDIENTE

📝 Actualizando documentos...

  ✅ 000_state_snapshot_checklist.md — Hallazgos consolidados
  ✅ 010_repo_access_inventory.md — Remotes y workflows actualizados
  ...
  ✅ Issue_50_Fase7_Conexion_WordPress_Real.md — Consolidado de evidencias

======================================================================
✅ CONSOLIDACIÓN COMPLETADA
======================================================================
```

### Requisitos
- Python 3.6+
- Acceso a git repo (para obtener ROOT_DIR)
- Templates poblados (ejecutar script recolección primero)

### Notas
- ✅ **Idempotente** — Puedes ejecutar múltiples veces
- ✅ **No modifica templates** — Solo lee (actualiza documentos)
- ✅ **Respeta formatos Markdown** — Inserta secciones sin romper estructura
- ✅ **Sin dependencias externas** — Usa solo librerías stdlib Python

---

## 3️⃣ Tareas VS Code

### Archivo
```
.vscode/tasks.json
```

### Tareas Disponibles

#### Tarea 1: Fase7: Collect Evidence
```json
{
  "label": "Fase7: Collect Evidence",
  "type": "shell",
  "command": "bash",
  "args": ["tools/fase7_collect_evidence.sh"]
}
```

**Cómo ejecutar:**
- Menú: `Terminal` → `Run Task` → `Fase7: Collect Evidence`
- Atajo: `Ctrl+Shift+P` → buscar "Fase7: Collect"

#### Tarea 2: Fase7: Process Evidence
```json
{
  "label": "Fase7: Process Evidence",
  "type": "shell",
  "command": "python",
  "args": ["tools/fase7_process_evidence.py"]
}
```

**Cómo ejecutar:**
- Menú: `Terminal` → `Run Task` → `Fase7: Process Evidence`
- Atajo: `Ctrl+Shift+P` → buscar "Fase7: Process"

---

## 🔄 Flujo Completo (Paso a Paso)

### Paso 1: Recolectar Evidencias
```bash
# Ejecutar recolección (genera 4 templates)
bash tools/fase7_collect_evidence.sh

# Output:
# OK: evidencias escritas en:
#  - evidencia_repo_remotes.txt
#  - evidencia_local_mirror.txt
#  - evidencia_server_versions.txt
#  - evidencia_rest_sample.txt
```

### Paso 2: (Opcional) Proporcionar SSH
```bash
# Si el owner quiere que se recolecte info del servidor:
export WP_SSH_HOST="github-actions@prod.server.com"
bash tools/fase7_collect_evidence.sh
```

### Paso 3: Procesar Evidencias
```bash
# Procesar templates → actualizar documentos
python3 tools/fase7_process_evidence.py

# Output:
# ✅ CONSOLIDACIÓN COMPLETADA
# Documentos actualizados: 000/010/020/030/040/060 + Issue #50
```

### Paso 4: Revisar Cambios
```bash
# Ver qué cambió
git status
git diff 000_state_snapshot_checklist.md
```

### Paso 5: Commit y Push
```bash
git add -A
git commit -m "docs(fase7): evidencias recolectadas + consolidación"
git push origin feat/fase7-evidencias-auto
```

---

## 🔐 Seguridad

### Qué Se Recolecta ✅
- Versiones de software (php -v, nginx -v, etc.)
- Rutas públicas (directorio raíz, árbol estructura)
- Remotes git públicos (URLs sin credenciales)
- Status HTTP (headers públicos)

### Qué NO Se Recolecta ❌
- ❌ Contraseñas
- ❌ Tokens / API Keys
- ❌ Application Passwords
- ❌ Claves privadas SSH
- ❌ wp-config.php
- ❌ Cookies con credenciales

### Sanitización Automática
Scripts enmascararan automáticamente si algo sensible aparece:
```
Authorization: *** REDACTED ***
Password: *** REDACTED ***
token=***REDACTED***
```

---

## 🐛 Troubleshooting

### Script 1: Recolección

**P: SSH falla / no quiero usarlo**  
R: Simplemente no exportes `WP_SSH_HOST`. Script marcará "(PENDIENTE)" y continuará.

**P: REST API no responde**  
R: Es normal si está en producción y no tiene acceso público. Script marcará "(fallo curl)" y continuará. Validarás en staging real.

**P: Mirror local no existe**  
R: Script marcará "(PENDIENTE) No existe la ruta X". Dile al owner que descargue mirror primero.

### Script 2: Procesamiento

**P: No encuentra templates**  
R: Ejecuta script de recolección primero (Paso 1).

**P: Error "No module named re"**  
R: Algo muy raro. Python 3 siempre tiene `re` built-in. Verifica versión: `python3 --version`

**P: Documentos no se actualizaron**  
R: Verifica que archivos existen en `apps/briefing/docs/internal/.../wp_real/`. Si no, script lo crea con secciones básicas.

---

## 📊 Resultado Esperado

Tras ejecutar ambos scripts:

1. ✅ **Templates poblados** con datos reales (Repo, Local, SSH opt, REST)
2. ✅ **Documentos consolidados** con hallazgos automáticos
3. ✅ **Issue #50 actualizado** con:
   - Matriz de estado (4 pilares)
   - Decisión recomendada (Preview Primero)
   - Inputs para owner (3 acciones)
4. ✅ **ADR propuesto** (Preview Primero — BAJO RIESGO)
5. ✅ **Plan operativo ready** (070_preview_staging_plan.md)

---

## 🎯 Próximos Pasos

Tras usar estos scripts:

1. **Revisar Issue #50** — Leer consolidado + matriz de estado
2. **Owner valida REST API** — `curl -i https://runalfondry.com/wp-json/`
3. **Owner confirma decisión** — Preview / Styling / Mixto
4. **Proceder según decisión** — Ejecutar 070_preview_staging_plan.md

---

## 📞 Soporte

- Script bash: `tools/fase7_collect_evidence.sh` (4.3 KB)
- Script Python: `tools/fase7_process_evidence.py` (~15 KB)
- Ambos tienen comentarios inline + manejo de errores robusto
- No requieren dependencias externas (excepto `bash` y `python3`)

---

**Creado por:** Copilot Fase 7  
**Última actualización:** 2025-10-20 15:35 UTC  
**Status:** ✅ Producción
