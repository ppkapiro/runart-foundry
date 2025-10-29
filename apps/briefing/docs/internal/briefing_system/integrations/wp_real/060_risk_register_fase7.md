# ⚠️ Registro de Riesgos — Fase 7

**Documento:** `060_risk_register_fase7.md`  
**Objetivo:** Identificar, valorar y mitigar riesgos de la Fase 7 (Conmutación a WordPress Real).  
**Fecha:** 2025-10-20

---

## 🎯 Matriz de Riesgos

### Leyenda
- **Probabilidad:** Baja (1/3) | Media (2/3) | Alta (3/3)
- **Impacto:** Bajo (<$1k, <8h labor) | Medio ($1-5k, 8-24h labor) | Alto (>$5k, >24h labor)
- **Riesgo:** Bajo (Prob×Impacto ≤ 2) | Medio (3-4) | Alto (≥ 5)

---

## 📊 Tabla de Riesgos

| ID | Riesgo | Prob | Impact | Riesgo | Mitigación | Estado | Evidencia |
|-----|--------|------|--------|--------|-----------|--------|-----------|
| **R1** | Credenciales expuestas en logs/commits | Alta | Alto | **ALTO** | GitHub Secrets + enmascaramiento; revisar artifacts | 🟢 Mitigado | `_templates/evidencia_*.txt` |
| **R2** | REST API no disponible en prod | Media | Alto | **MEDIO** | Verificar `/wp-json/` accesible; revisar WAF | ⏳ Pendiente | `040_wp_rest_and_authn_readiness.md` |
| **R3** | Application Passwords no soportadas | Media | Medio | **MEDIO** | Confirmar WordPress 5.6+; alternativa basic auth | ⏳ Pendiente | Validación de versión |
| **R4** | Auth=KO por credenciales erróneas | Alta | Bajo | **MEDIO** | Doblar-check URL/usuario/password antes de cargar | ⏳ Pendiente | Test manual |
| **R5** | Cambios de tema rompen funcionalidad | Media | Alto | **MEDIO** | Aplicar SOLO en staging; validar antes de prod | ⏳ Pendiente | Pre-validación |
| **R6** | Staging no refleja exactamente prod | Media | Medio | **MEDIO** | Usar copia fresca de BD prod; sincronizar arquivos | ⏳ Pendiente | Validación de staging |
| **R7** | Base de datos corrompida en descarga | Baja | Alto | **MEDIO** | Backup antes de cualquier cambio; checksums | ⏳ Pendiente | 020_local_mirror_inventory.md |
| **R8** | Conectividad SSH interrumpida | Baja | Bajo | **BAJO** | SSH key configurada; reconexión automática | ⏳ Pendiente | 030_ssh_connectivity.md |
| **R9** | Workflows ejecutan contra URL equivocada | Media | Alto | **MEDIO** | Validar `WP_BASE_URL` ANTES de correr; usar staging primero | ⏳ Pendiente | Issue #50 checklist |
| **R10** | Cambios de credenciales sin notificación | Baja | Medio | **BAJO** | Owner notifica a Copilot; actualizar GitHub secrets | ⏳ Pendiente | Documentación |

---

## 🔴 Riesgos ALTOS

### **R1 — Credenciales Expuestas en Logs/Commits**

**Descripción:**
GitHub Actions logs o archivos versionados en Git podrían exponer `WP_APP_PASSWORD` o tokens.

**Probabilidad:** ⬆️ Alta (3/3)  
**Impacto:** ⬆️ Alto (>$5k, credenciales comprometidas)  
**Riesgo:** 🔴 **ALTO** (9/9)

**Mitigación:**
1. ✅ Usar GitHub Secrets (enmascarados automáticamente)
2. ✅ NO incluir credenciales en commits
3. ✅ Revisar artifacts (`*_summary.txt`) — buscar `***` en lugar de valores reales
4. ✅ No pegar `WP_APP_PASSWORD` en Issues/PRs
5. ✅ Si se expone: rotar credenciales inmediatamente

**Evidencia:**
- `_templates/evidencia_*.txt` (texto plano, SIN tokens)
- Artifacts de workflows (`verify-*_summary.txt`)

**Estado:** 🟢 **MITIGADO** (GitHub Secrets implementadas)

**Validación:**
```bash
# Comando para verificar que secrets NO aparecen en output
grep -r "WP_APP_PASSWORD" .github/workflows/verify-*.yml
# Resultado esperado: vacío (secrets NO listados directamente)

# Revisar artifacts (una vez ejecutados)
# Buscar: "***" (enmascarado) NO valores reales
```

---

## 🟡 Riesgos MEDIOS

### **R2 — REST API No Disponible en Prod**

**Descripción:**
Servidor prod podría tener REST API deshabilitada, bloqueada por WAF, o no disponible por firewall.

**Probabilidad:** 🟡 Media (2/3)  
**Impacto:** 🔴 Alto (workflows fallan, Auth=KO)  
**Riesgo:** 🟡 **MEDIO** (6/9)

**Mitigación:**
1. Validar `/wp-json/` responde HTTP 200 o 401 (antes de cargar credenciales)
2. Revisar WAF/firewall rules
3. Confirmar XML-RPC habilitado O REST API core activo
4. Test con `curl` antes de ejecutar workflows

**Evidencia:**
- `040_wp_rest_and_authn_readiness.md`
- `_templates/evidencia_rest_sample.txt`

**Estado:** ⏳ **PENDIENTE VALIDACIÓN**

**Próxima acción:** Owner valida acceso a `wp-json/` antes de Fase 7 ejecución.

---

### **R3 — Application Passwords No Soportadas**

**Descripción:**
Si WordPress < 5.6 o no está habilitada, no podremos usar Application Passwords.

**Probabilidad:** 🟡 Media (2/3)  
**Impacto:** 🟡 Medio (usar Basic Auth alternativo, downgrade seguridad)  
**Riesgo:** 🟡 **MEDIO** (4/9)

**Mitigación:**
1. Confirmar WordPress 5.6+ en servidor
2. Si <5.6: usar Basic Auth en lugar de Application Passwords (menos seguro, pero funciona)
3. Documentar en `040_wp_rest_and_authn_readiness.md`

**Evidencia:**
- `030_ssh_connectivity_and_server_facts.md` (versión de WP)
- WP-Admin → Tools → Site Health

**Estado:** ⏳ **PENDIENTE VALIDACIÓN**

---

### **R4 — Auth=KO por Credenciales Erróneas**

**Descripción:**
Owner carga credenciales incorrectas (URL, usuario, password equivocados).

**Probabilidad:** ⬆️ Alta (3/3)  
**Impacto:** ↓ Bajo (fácil de corregir)  
**Riesgo:** 🟡 **MEDIO** (3/9)

**Mitigación:**
1. Triple-check antes de cargar en GitHub
2. Ejecutar test manual primero (curl con credenciales locales)
3. Si Auth=KO → revisa URL, usuario, password; reintentar
4. No modificar code; solo re-validar credenciales

**Evidencia:**
- `000_state_snapshot_checklist.md` (Hallazgos)
- Issue #50 (diagnóstico)

**Estado:** ⏳ **PENDIENTE EJECUCIÓN**

---

### **R5 — Cambios de Tema Rompen Funcionalidad**

**Descripción:**
Ajustes de tema/child-theme podrían romper layouts, menús, o plugins integrados.

**Probabilidad:** 🟡 Media (2/3)  
**Impacto:** ⬆️ Alto (sitio inutilizable)  
**Riesgo:** 🟡 **MEDIO** (6/9)

**Mitigación:**
1. Aplicar SOLO en staging primero
2. Validar cambios antes de replicar a prod
3. Tener rollback plan (revert de cambios)
4. Backup antes de cada cambio significativo

**Evidencia:**
- `050_decision_record_styling_vs_preview.md` (decisión elegida)
- Notas de cambios en Issue #50

**Estado:** ⏳ **PENDIENTE DECISIÓN** (Styling vs Preview)

---

### **R6 — Staging No Refleja Exactamente Prod**

**Descripción:**
Si se usa staging, podría estar desactualizado (BD vieja, archivos outdated).

**Probabilidad:** 🟡 Media (2/3)  
**Impacto:** 🟡 Medio (workflows fallan en staging pero funciona en prod)  
**Riesgo:** 🟡 **MEDIO** (4/9)

**Mitigación:**
1. Usar copia **fresca** de BD prod (no >7 días vieja)
2. Sincronizar archivos (`wp-content/uploads/`) regularmente
3. Documentar cuándo se sincronizó staging
4. Ejecutar verify-* en AMBOS (staging + prod) para comparar

**Evidencia:**
- Fecha de sincronización en `020_local_mirror_inventory.md`
- Artifacts comparados (staging vs prod)

**Estado:** ⏳ **PENDIENTE SETUP DE STAGING**

---

### **R7 — Base de Datos Corrompida en Descarga**

**Descripción:**
El dump de BD descargado podría estar corrupto o incompleto.

**Probabilidad:** ↓ Baja (1/3)  
**Impacto:** ⬆️ Alto (datos inservibles)  
**Riesgo:** 🟡 **MEDIO** (3/9)

**Mitigación:**
1. Generar checksums en servidor antes de descargar
2. Validar checksums después de descarga
3. Mantener backup de BD prod intacto
4. NO sobrescribir prod con dump corrupto

**Evidencia:**
- Checksums en `020_local_mirror_inventory.md`
- Logs de descarga

**Estado:** ⏳ **PENDIENTE VALIDACIÓN**

---

### **R9 — Workflows Ejecutan Contra URL Equivocada**

**Descripción:**
Si `WP_BASE_URL` está mal, workflows se ejecutan contra servidor equivocado.

**Probabilidad:** 🟡 Media (2/3)  
**Impacto:** ⬆️ Alto (falsos negativos, posible exposición a otro servidor)  
**Riesgo:** 🟡 **MEDIO** (6/9)

**Mitigación:**
1. **Validar `WP_BASE_URL` ANTES de cargar en GitHub**
2. Usar staging primero (para test seguro)
3. Inspeccionar workflow logs
4. Si error → actualizar variable y reintentar

**Evidencia:**
- Validación manual de URL en navegador
- Logs de workflows

**Estado:** ⏳ **PENDIENTE EJECUCIÓN**

---

## 🟢 Riesgos BAJOS

### **R8 — Conectividad SSH Interrumpida**

**Descripción:**
Conexión SSH al servidor podría caerse o haber timeouts.

**Probabilidad:** ↓ Baja (1/3)  
**Impacto:** ↓ Bajo (reconectar)  
**Riesgo:** 🟢 **BAJO** (1/9)

**Mitigación:**
1. SSH key configurada (no contraseña interactiva)
2. SSH connection pooling
3. Reintentos automáticos

**Evidencia:**
- `030_ssh_connectivity_and_server_facts.md`

**Estado:** 🟢 **BAJO RIESGO**

---

### **R10 — Cambios de Credenciales Sin Notificación**

**Descripción:**
Owner cambia credenciales en producción sin avisar a Copilot.

**Probabilidad:** ↓ Baja (1/3)  
**Impacto:** 🟡 Medio (workflows fallan)  
**Riesgo:** 🟢 **BAJO** (2/9)

**Mitigación:**
1. Documentación clara en Issue #50
2. Owner notifica en chat/comentario si cambia credenciales
3. Mantener changelog de cambios

**Evidencia:**
- Comentarios en Issue #50

**Estado:** 🟢 **BAJO RIESGO**

---

## 📋 Checklist de Gestión de Riesgos

### Antes de Ejecutar Workflows

- [ ] R1: Verificar secrets NO exponen en logs (artifacts revisados)
- [ ] R2: Validar `/wp-json/` accesible (curl test)
- [ ] R3: Confirmar WordPress 5.6+ (versión validada)
- [ ] R4: Triple-check credenciales (URL, usuario, password)
- [ ] R5: Plan de cambios de tema documentado
- [ ] R6: Staging sincronizado (si aplica)
- [ ] R7: Checksums de BD validados
- [ ] R9: `WP_BASE_URL` correcta (copy-paste verificada)

### Durante Ejecución

- [ ] Monitoreo de logs en real-time
- [ ] Status de workflows OK (Passed, no Failed)
- [ ] Artifacts generados y revisados
- [ ] No hay errores de autenticación (Auth=OK esperado)

### Después de Ejecución

- [ ] Artifacts adjuntos en Issue #50
- [ ] Hallazgos documentados
- [ ] Siguiente paso definido (staging → prod, o iteración)
- [ ] Riesgos actualizados (status: Mitigado/Residual/Nuevo)

---

## 🎯 Matriz de Decisión

Si ocurre un riesgo identificado:

| Riesgo | Acción Inmediata | Escalación | Documentar |
|--------|-----------------|-----------|-----------|
| **R1** (Credenciales expuestas) | ⛔ PARAR; rotar credenciales | Owner + Security | Issue #50 + Security log |
| **R2** (REST API no disponible) | ⛔ PARAR; revisar WAF | Owner + DevOps | `040_wp_rest_and_authn_readiness.md` |
| **R3** (App Passwords no soportadas) | ⚠️ Cambiar a Basic Auth | Owner | `040_wp_rest_and_authn_readiness.md` |
| **R4** (Credenciales erróneas) | ⚠️ Revalidar; reintentar | Owner | Issue #50 |
| **R5** (Tema rompe funcionalidad) | ⛔ PARAR; rollback cambios | Owner | Changelog |
| **R6** (Staging outdated) | ⚠️ Sincronizar; reintentar | Owner + DevOps | `020_local_mirror_inventory.md` |
| **R7** (BD corrupta) | ⛔ PARAR; usar backup | Owner + DevOps | Logs de recuperación |
| **R8** (SSH caída) | ⚠️ Reconectar | Owner | `030_ssh_connectivity.md` |
| **R9** (URL equivocada) | ⛔ PARAR; corregir variable | Owner | `000_state_snapshot_checklist.md` |
| **R10** (Credenciales cambiadas) | ⚠️ Actualizar; reintentar | Owner | Comentarios Issue |

---

## 🔗 Referencias

- Documento central: `000_state_snapshot_checklist.md`
- README: `README.md` (en esta carpeta)
- Issue #50: `issues/Issue_50_Fase7_Conexion_WordPress_Real.md`

---

**Estado:** 🟡 Riesgos identificados y mitigaciones planeadas  
**Última actualización:** 2025-10-20  
**Próxima revisión:** Tras ejecución de workflows (validar riesgos reales)
