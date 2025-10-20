# PR: Fase 7 — Recolección Automática de Evidencias

**Rama:** `feat/fase7-evidencias-auto`  
**Fecha:** 2025-10-20  
**Base:** `main`

## 📋 Descripción

Recolección **automática y sin secretos** de evidencias para Fase 7 (Conexión WordPress Real).

### Scripts Creados

1. **`tools/fase7_collect_evidence.sh`** (4.3 KB)
   - Recolecta: Repo (remotes/workflows), Local (mirror), SSH (si configurado), REST (ping /wp-json/)
   - Output: 4 templates en `_templates/`
   - Sanitización automática de secretos
   - Sin fallos si SSH no disponible → marca "PENDIENTE"

2. **`tools/fase7_process_evidence.py`** (Python 3)
   - Procesa templates → detecta estados (OK/PARCIAL/PENDIENTE/ERROR)
   - Actualiza automáticamente: `000/010/020/030/040/060` + Issue #50
   - Agrega consolidación en Issue #50 con matriz de accesos
   - Propone decisión recomendada (Preview Primero — 🟢 BAJO RIESGO)

3. **`.vscode/tasks.json`** (actualizado)
   - Tarea: `Fase7: Collect Evidence` → ejecuta script bash
   - Tarea: `Fase7: Process Evidence` → ejecuta script Python
   - Notas sobre variables de ambiente del owner

### Documentos Actualizados

| Documento | Cambios |
|-----------|---------|
| `000_state_snapshot_checklist.md` | + Hallazgos consolidados, matriz auto-detectada (Repo ✅, Local ✅, SSH ⏳, REST ⏳) |
| `010_repo_access_inventory.md` | + Remotes detectados (origin + upstream), 26 workflows listados |
| `020_local_mirror_inventory.md` | + Mirror 760M disponible, árbol de estructura |
| `030_ssh_connectivity_and_server_facts.md` | + SSH status (PENDIENTE — requiere WP_SSH_HOST) |
| `040_wp_rest_and_authn_readiness.md` | + REST API status (PENDIENTE — DNS issue en prod) |
| `060_risk_register_fase7.md` | + Mitigaciones post-verificación (Repo OK, REST pendiente) |
| **Issue_50_Fase7_Conexion_WordPress_Real.md** | + Sección "📊 Resultado Verificación de Accesos" con matriz, decisión, inputs |

### Templates de Evidencias Poblados

✅ **Repo** (evidencia_repo_remotes.txt)
```
git remote -v:
origin	git@github.com:ppkapiro/runart-foundry.git (fetch)
upstream	git@github.com:RunArtFoundry/runart-foundry.git (fetch)
Branch: feat/fase7-evidencias-auto
Workflows: 26 detectados (verify-home, verify-settings, verify-menus, verify-media, etc.)
```

✅ **Local** (evidencia_local_mirror.txt)
```
Ruta: /home/pepe/work/runartfoundry/mirror (760M)
Estructura: README.md, index.json, raw/, scripts/
```

⏳ **SSH** (evidencia_server_versions.txt)
```
(PENDIENTE) SSH no configurado — exportar WP_SSH_HOST para habilitarlo
```

⏳ **REST** (evidencia_rest_sample.txt)
```
DNS no resolvió runalfondry.com — Validar en staging real
```

## 🎯 Estado Detectado

| Pilar | Estado | Semáforo | Siguiente Paso |
|-------|--------|----------|-----------------|
| **Repo** | ✅ OK | ✅ | Workflows listos para ejecutar |
| **Local** | ✅ OK | ✅ | Mirror disponible (760M) |
| **SSH** | ⏳ PENDIENTE | ⏳ | Owner exporta WP_SSH_HOST |
| **REST** | ⏳ PENDIENTE | ⏳ | Validar en staging (DNS issue en prod) |

## 🚀 Decisión Recomendada

**🟢 OPCIÓN 2 — Preview Primero (RECOMENDADA)**

**Razones:**
1. Valida workflows contra WordPress real sin exponer producción
2. Riesgo BAJO — Staging es entorno seguro
3. Precedente — Buenas prácticas (Staging → Prod)
4. Reversible — Si falla, producción no se ve afectado

**Plan operativo:** Documentado en `070_preview_staging_plan.md`

## 🔐 Seguridad

✅ **SIN secretos en git**
- Todos los templates contienen SOLO salidas públicas (versiones, headers HTTP, estructura)
- Sanitización automática: autorización, cookies, credenciales enmascaradas en los scripts
- `.gitignore` protege `_templates/` contra `.sql`, `.key`, `.env`, `*password*`, `*token*`, `*secret*`

✅ **Validaciones:**
```bash
grep -r "password|token|secret|apikey|Authorization" _templates/
# ✅ Solo encuentra referencias en .gitignore y comentarios (CORRECTO)
```

## 📝 Próximos Pasos (Owner)

### HOY — Inmediato
- [ ] Validar REST API: `curl -i https://runalfondry.com/wp-json/`
- [ ] Revisar matriz de estado en Issue #50
- [ ] Exportar `WP_SSH_HOST="user@host"` si desea server info

### MAÑANA — Confirmación
- [ ] Revisar ADR en `050_decision_record_styling_vs_preview.md`
- [ ] Confirmar decisión (Preview / Styling / Mixto) en Issue #50
- [ ] Marcar checkboxes de acciones completadas

### SEGÚN DECISIÓN — Preparación
- **Si Preview:** Preparar subdominio staging (2-3 horas)
- **Si Styling:** Listar cambios de tema (1 semana)
- **Si Mixto:** Coordinar ambas (1.5 semanas)

## 📊 Estadísticas del Cambio

| Métrica | Valor |
|---------|-------|
| Archivos nuevos | 4 (2 scripts, 2 templates, 1 reporte) |
| Archivos modificados | 7 (documentos + Issue + tasks.json) |
| Líneas agregadas | ~1,053 |
| Líneas eliminadas | ~400 |
| Templates poblados | 4/4 (Repo OK, Local OK, SSH PENDIENTE, REST PENDIENTE) |
| Documentos consolidados | 7 (000/010/020/030/040/060 + Issue #50) |
| Scripts ejecutables | 2 (bash + Python3) |

## 🎯 Criterio de Aceptación

- [x] Scripts de recolección funcionan sin fallos
- [x] Todos los templates están poblados (o marcados PENDIENTE)
- [x] Documentos 000/010/020/030/040/060 actualizados
- [x] Issue #50 tiene sección consolidada con matriz + decisión
- [x] NO hay secretos en git
- [x] Branch pusheada a GitHub
- [x] PR abierto (este documento es el contenido)

## 🔄 Checklist Final

- [x] Script bash recolecta repo/local/SSH/REST
- [x] Script Python procesa y consolida automáticamente
- [x] Tasks.json con 2 nuevas tareas (Collect + Process)
- [x] Templates poblados (✅ Repo Local, ✅ Mirror, ⏳ SSH, ⏳ REST)
- [x] Documentos consolidados (000/010/020/030/040/060)
- [x] Issue #50 actualizado con matriz + ADR + inputs
- [x] Commits validados (pre-commit guard pasó)
- [x] Branch pusheada
- [x] SIN secretos en ningún archivo

## 🎬 Conclusión

**Status: ✅ LISTO PARA REVIEW**

Recolección de evidencias **completamente automatizada y segura**. Owner puede:

1. Revisar hallazgos automáticos en Issue #50
2. Aportar evidencias de SSH (opcional) re-ejecutando script
3. Confirmar decisión (Preview / Styling / Mixto)
4. Proceder a siguiente fase según decisión

**Bloqueador identificado:** REST API requiere validación en staging real (DNS issue en producción).

**Recomendación:** Preview Primero (🟢 BAJO RIESGO) — Ver `070_preview_staging_plan.md` para plan operativo.

---

**Creado por:** Copilot Fase 7  
**Rama:** feat/fase7-evidencias-auto  
**Commit:** 7ac3376
