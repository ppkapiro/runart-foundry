## Pull Request Checklist

**Por favor, marca todas las casillas que apliquen antes de solicitar revisión.**

### 📋 Checklist de Gobernanza (Individual)

- [ ] **Ubicación correcta**: Los archivos están en las carpetas adecuadas según [docs/proyecto_estructura_y_gobernanza.md](../docs/proyecto_estructura_y_gobernanza.md)
- [ ] **Nomenclatura**: Los archivos siguen convenciones (kebab-case, prefijo de fecha `YYYY-MM-DD` si aplica)
- [ ] **Tamaño**: Todos los archivos son <10 MB (si >10 MB, está justificado o excluido)
- [ ] **Contenido sensible**: NO se incluyen credenciales, tokens, API keys, IPs privadas
- [ ] **Logs**: Los archivos `.log` están en carpetas `_logs/` y excluidos en `.gitignore`
- [ ] **Build artifacts**: NO se suben `site/`, `node_modules/`, `dist/`, `.cache/`, `build/`
- [ ] **Reportes**: Los reportes están en `briefing/_reports/` o `audits/reports/` (NO en raíz)
- [ ] **Mensaje de commit**: Los commits tienen prefijo de módulo y descripción clara (ej: `briefing: Añadir endpoint`)
- [ ] **Documentación**: Se actualizó README o docs si el cambio lo requiere
- [ ] **Tests locales**: El código fue probado localmente antes del commit

### 🔍 Validación Automática

- [ ] **CI pasando**: El workflow `structure-guard.yml` pasó sin errores
- [ ] **Script local ejecutado**: Ejecuté `scripts/validate_structure.sh --staged-only` localmente

### 📝 Descripción del PR

**¿Qué cambia este PR?**
<!-- Describe brevemente los cambios -->

**¿Por qué es necesario este cambio?**
<!-- Justifica el cambio: bug fix, nueva funcionalidad, refactorización, etc. -->

**¿Cómo se puede probar?**
<!-- Pasos para verificar los cambios -->
1. 
2. 
3. 

### 🏷️ Tipo de Cambio

Marca el tipo de cambio que aplica:

- [ ] 🐛 Bug fix (corrección de error)
- [ ] ✨ Nueva funcionalidad
- [ ] 📝 Documentación
- [ ] 🔧 Configuración (CI, scripts, hooks)
- [ ] ♻️ Refactorización
- [ ] 🎨 Mejora de UI/UX
- [ ] ⚡ Mejora de performance
- [ ] 🔒 Seguridad

### 📦 Módulo Afectado

Marca el módulo principal que afecta este PR:

- [ ] `briefing/` - Micrositio Cloudflare Pages
- [ ] `audits/` - Auditorías del sitio
- [ ] `mirror/` - Snapshots del sitio
- [ ] `docs/` - Documentación
- [ ] `scripts/` - Scripts y utilidades
- [ ] `.github/` - CI/CD y workflows
- [ ] Otro: _______________________

### 🔗 Referencias

<!-- Enlaces a issues, documentos, discusiones relacionadas -->

- Relacionado con issue #
- Documentación: [docs/proyecto_estructura_y_gobernanza.md](../docs/proyecto_estructura_y_gobernanza.md)

---

### 📖 Recursos

- [Documento de Gobernanza](../docs/proyecto_estructura_y_gobernanza.md)
- [README Principal](../README.md)
- [Validador de Estructura](../scripts/validate_structure.sh)

---

**Nota para revisores**: Verificar que el PR cumple con las reglas de gobernanza y que el checklist está completo.
