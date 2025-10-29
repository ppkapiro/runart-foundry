# 🔗 Quick Resume: Bridge Installer

**Para el siguiente agente/sesión:**

## TL;DR

El instalador automático del plugin WP-CLI Bridge está **BLOQUEADO** porque faltan secretos admin WordPress (`WP_ADMIN_USER`/`WP_ADMIN_PASS`). Todo lo demás está **FUNCIONANDO**.

## ¿Qué funciona ahora?

✅ **Bridge comandos** (manual y cron)  
✅ **Mantenimiento semanal** (cache_flush viernes 10:00, rewrite_flush viernes 10:05)  
✅ **Health checks diarios**  
✅ **Smoke tests diarios**  
✅ **Empaquetado del plugin ZIP**  

## ¿Qué NO funciona?

❌ **Instalador automático** del plugin (workflow `install-wpcli-bridge.yml`)

## ¿Por qué?

Los secretos `WP_ADMIN_USER` y `WP_ADMIN_PASS` no existen o no están accesibles en el runner. El instalador necesita hacer login a wp-admin para subir el ZIP del plugin.

## ¿Qué hacer?

### Opción 1: Configurar secretos (recomendado)
1. Ir a GitHub → Settings → Secrets and variables → Actions
2. Si usar Environment secrets: crear/editar environment "staging"
3. Añadir:
   - `WP_ADMIN_USER` = usuario admin WordPress
   - `WP_ADMIN_PASS` = contraseña admin WordPress (NO Application Password)
4. Re-ejecutar workflow `install-wpcli-bridge`

### Opción 2: Instalación manual (workaround)
1. Descargar `tools/wpcli-bridge-plugin/` como ZIP
2. Subir a https://staging.runartfoundry.com/wp-admin/plugin-install.php?tab=upload
3. Activar plugin
4. Validar con workflow `wpcli-bridge` (command=health)

### Opción 3: Dejar como está
- Bridge funciona manualmente desde workflows
- Mantenimiento semanal funciona (tolerante a plugin ausente)
- Instalador queda documentado como "pendiente"

## Documentos clave

- **[BRIDGE_INSTALLER_PENDIENTE.md](./BRIDGE_INSTALLER_PENDIENTE.md)** — Contexto completo
- **[INDEX.md](./INDEX.md)** — Estado actualizado de Fase 11
- **[tools/wpcli-bridge-plugin/README.md](../tools/wpcli-bridge-plugin/README.md)** — Endpoints del bridge

## Archivos relevantes

```
.github/workflows/
├── install-wpcli-bridge.yml      # ❌ BLOQUEADO
├── wpcli-bridge.yml              # ✅ FUNCIONA
├── wpcli-bridge-maintenance.yml  # ✅ FUNCIONA
└── wpcli-bridge-rewrite-maintenance.yml  # ✅ FUNCIONA

tools/wpcli-bridge-plugin/
├── runart-wpcli-bridge.php       # Plugin completo
└── README.md                     # Documentación

_reports/bridge/
├── bridge_*.md                   # Reportes de comandos
└── install_*.md                  # ⚠️ No generado aún (installer bloqueado)
```

## Último commit

```
95b7009 - docs: Documentar estado del instalador Bridge (bloqueado por secretos admin)
```

## Siguiente paso

Resolver problema externo mencionado por el usuario, LUEGO retomar esto con los secretos configurados.

---

**Prioridad:** MEDIA (no-crítico; bridge funciona manualmente)  
**Última actualización:** 2025-10-21T19:55Z  
**Contacto:** GitHub Copilot (agente automatizado)
