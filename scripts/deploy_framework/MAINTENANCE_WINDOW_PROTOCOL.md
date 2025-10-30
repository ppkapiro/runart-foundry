# Protocolo de Ventana de Mantenimiento STAGING

**RunArt Foundry** — Gestión segura del entorno staging

---

## 🎯 Propósito

Permitir trabajar activamente en staging (escritura real, pruebas, aprobaciones) de forma controlada y documentada, sin que scripts automáticos restauren el modo protegido sin previo aviso.

---

## 📋 Definiciones

### MODO PROTEGIDO (default)

Estado seguro del entorno staging:

```bash
READ_ONLY=1       # Solo lectura en repositorio
DRY_RUN=1         # Simulación sin cambios reales
REAL_DEPLOY=0     # Deploys deshabilitados
```

**Características**:
- ✅ Navegación y consultas funcionan
- ✅ Endpoints REST devuelven datos
- ❌ No se pueden escribir archivos en data/
- ❌ Aprobaciones se registran en fallback (queued)
- ❌ No se pueden hacer deploys reales

---

### VENTANA ABIERTA (modo trabajo)

Estado de trabajo activo en staging:

```bash
READ_ONLY=0       # Escritura habilitada en repositorio
DRY_RUN=0         # Ejecución real de comandos
REAL_DEPLOY=1     # Deploys habilitados
```

**Características**:
- ✅ Escritura en data/assistants/rewrite/
- ✅ Escritura en wp-content/uploads/runart-jobs/
- ✅ Aprobaciones se guardan en approvals.json
- ✅ Endpoints REST ejecutan cambios reales
- ✅ Panel Editorial IA-Visual totalmente funcional
- ✅ Deploys reales permitidos

---

## 🔧 Scripts

### Abrir Ventana

```bash
source scripts/deploy_framework/open_staging_window.sh
```

**Qué hace**:
1. Muestra estado previo de variables
2. Configura READ_ONLY=0, DRY_RUN=0, REAL_DEPLOY=1
3. Muestra estado nuevo
4. Genera timestamp de apertura
5. Recuerda cerrar cuando termines

**Cuándo usar**:
- Antes de probar Panel Editorial IA-Visual
- Antes de aprobar/rechazar contenidos
- Antes de ejecutar scripts que escriben datos
- Antes de hacer deploys reales en staging

---

### Cerrar Ventana

```bash
source scripts/deploy_framework/close_staging_window.sh
```

**Qué hace**:
1. Muestra estado previo de variables
2. Restaura READ_ONLY=1, DRY_RUN=1, REAL_DEPLOY=0
3. Muestra estado nuevo (protegido)
4. Genera timestamp de cierre

**Cuándo usar**:
- Después de terminar pruebas activas
- Antes de dejar staging sin supervisión
- Al finalizar la sesión de trabajo
- Después de completar aprobaciones

---

## 📝 Protocolo de Uso

### 1. Antes de empezar a trabajar

```bash
# Abrir ventana
source scripts/deploy_framework/open_staging_window.sh

# Verificar estado
echo "READ_ONLY=$READ_ONLY (debe ser 0)"
echo "DRY_RUN=$DRY_RUN (debe ser 0)"
echo "REAL_DEPLOY=$REAL_DEPLOY (debe ser 1)"
```

### 2. Durante el trabajo

- ✅ Probar Panel Editorial IA-Visual
- ✅ Aprobar/rechazar contenidos
- ✅ Ejecutar scripts de validación
- ✅ Hacer deploys de plugins
- ✅ Escribir logs y datos

### 3. Al terminar

```bash
# Cerrar ventana
source scripts/deploy_framework/close_staging_window.sh

# Verificar estado protegido
echo "READ_ONLY=$READ_ONLY (debe ser 1)"
echo "DRY_RUN=$DRY_RUN (debe ser 1)"
echo "REAL_DEPLOY=$REAL_DEPLOY (debe ser 0)"
```

### 4. Documentar en bitácora

Añadir entrada en `_reports/BITACORA_AUDITORIA_V2.md`:

```markdown
### 🟢 AAAA-MM-DDTHH:MM:SSZ — VENTANA DE MANTENIMIENTO STAGING ABIERTA
**Responsable:** [tu-nombre]
**Timestamp apertura:** [timestamp]
**Acciones realizadas:**
- [acción 1]
- [acción 2]
**Timestamp cierre:** [timestamp]
**Estado:** CERRADA
```

---

## ⚠️ Políticas Importantes

### 1. NO cierre automático

**Scripts de validación NO deben cerrar la ventana automáticamente.**

Scripts actualizados:
- `tools/test_staging_write.sh` — Ya NO restaura READ_ONLY/DRY_RUN
- `tools/staging_full_validation.sh` — Ya NO cierra la ventana

### 2. Documentación obligatoria

**Toda apertura/cierre debe documentarse en bitácora.**

### 3. Responsabilidad del usuario

**El usuario es responsable de cerrar la ventana cuando termine.**

Si olvidas cerrarla:
- Staging queda con escritura habilitada
- Otros usuarios/scripts pueden modificar datos
- Riesgo de cambios no intencionados

### 4. Verificación de estado

**Siempre verificar el estado antes de trabajar:**

```bash
# Verificar estado actual
echo "READ_ONLY=${READ_ONLY:-undefined}"
echo "DRY_RUN=${DRY_RUN:-undefined}"
echo "REAL_DEPLOY=${REAL_DEPLOY:-undefined}"
```

---

## 🔍 Verificación de Funcionamiento

### Con ventana CERRADA (modo protegido)

```bash
# Intentar escribir en runart-jobs/
touch wp-content/uploads/runart-jobs/test.json
# Resultado esperado: puede fallar o escribir con permisos limitados

# Endpoint de aprobación
curl -X POST https://staging.runartfoundry.com/wp-json/runart/content/enriched-approve \
  -H "Content-Type: application/json" \
  -d '{"id":"page_42","status":"approved"}'
# Resultado esperado: {"status":"queued","message":"staging en modo solo lectura"}
```

### Con ventana ABIERTA (modo trabajo)

```bash
# Intentar escribir en runart-jobs/
echo '{"test":"ok"}' > wp-content/uploads/runart-jobs/test.json
# Resultado esperado: escritura exitosa

# Endpoint de aprobación
curl -X POST https://staging.runartfoundry.com/wp-json/runart/content/enriched-approve \
  -H "Content-Type: application/json" \
  -d '{"id":"page_42","status":"approved"}'
# Resultado esperado: {"ok":true,"message":"Aprobación registrada correctamente"}
```

---

## 📊 Checklist de Uso

Antes de trabajar:
- [ ] Abrir ventana con `open_staging_window.sh`
- [ ] Verificar READ_ONLY=0, DRY_RUN=0, REAL_DEPLOY=1
- [ ] Documentar apertura en bitácora

Durante el trabajo:
- [ ] Realizar pruebas necesarias
- [ ] Aprobar/rechazar contenidos
- [ ] Ejecutar scripts de validación
- [ ] Verificar que cambios se aplican correctamente

Al terminar:
- [ ] Cerrar ventana con `close_staging_window.sh`
- [ ] Verificar READ_ONLY=1, DRY_RUN=1, REAL_DEPLOY=0
- [ ] Documentar cierre en bitácora
- [ ] Confirmar que staging está protegido

---

## 🆘 Troubleshooting

### Problema: Variables no se exportan

**Síntoma**: Después de ejecutar script, `echo $READ_ONLY` está vacío

**Solución**: Usar `source` en lugar de `bash`:
```bash
# ❌ Mal
bash scripts/deploy_framework/open_staging_window.sh

# ✅ Bien
source scripts/deploy_framework/open_staging_window.sh
```

---

### Problema: Ventana se cierra sola

**Síntoma**: Después de ejecutar script, variables vuelven a 1

**Solución**: Verificar que scripts de validación estén actualizados:
```bash
# Verificar que no restauren READ_ONLY
grep -n "READ_ONLY=1" tools/*.sh
# No debería haber restauración automática
```

---

### Problema: No recuerdo si cerré la ventana

**Solución**: Verificar estado actual:
```bash
echo "READ_ONLY=${READ_ONLY:-undefined}"
echo "DRY_RUN=${DRY_RUN:-undefined}"

# Si están en 0, la ventana está abierta
# Cerrar con:
source scripts/deploy_framework/close_staging_window.sh
```

---

## 📚 Referencias

- **Scripts**: `scripts/deploy_framework/{open,close}_staging_window.sh`
- **Bitácora**: `_reports/BITACORA_AUDITORIA_V2.md`
- **Validación**: `tools/staging_full_validation.sh`
- **Panel Editorial**: https://staging.runartfoundry.com/en/panel-editorial-ia-visual/

---

**Última actualización**: 2025-10-30  
**Versión**: 1.0  
**Fase**: F10-d — Protocolo de ventana de mantenimiento
