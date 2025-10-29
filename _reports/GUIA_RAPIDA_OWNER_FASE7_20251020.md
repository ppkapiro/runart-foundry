# 🚀 Guía Rápida para Owner — Fase 7 (Conmutación a WordPress Real)

**Fecha:** 2025-10-20  
**Estado:** ⏳ Esperando carga de credenciales  
**Rama:** `feat/fase7-wp-connection`  
**Duración estimada:** 5 minutos

---

## ⚡ Paso 1: Generar Application Password en WordPress

1. Accede a WordPress Admin (`https://tu-wp.com/wp-admin/`)
2. Navega a **Users → Tu usuario** (ej: admin)
3. Desplázate a la sección **Application Passwords**
4. Ingresa un nombre: **`github-actions`**
5. Haz clic en **"Create Application Password"**
6. ✅ **Copia la contraseña generada** (aparece una única vez)
   - Se ve algo como: `xxxx xxxx xxxx xxxx xxxx xxxx xxxx xxxx`
7. **NO cierres esta página** hasta completar Paso 2

---

## ⚡ Paso 2: Cargar `WP_BASE_URL` en GitHub (Variable)

1. Abre tu repositorio en GitHub: `https://github.com/RunArtFoundry/runart-foundry`
2. Navega a **Settings → Secrets and variables → Actions**
3. Haz clic en la pestaña **Variables** (si no está visible, haz clic en "Secrets" primero, luego verás un ícono de variables)
4. Haz clic en **"New repository variable"**
5. Completa:
   - **Name:** `WP_BASE_URL`
   - **Value:** La URL real de tu sitio WordPress (ej: `https://ejemplo.com`)
6. Haz clic en **"Add variable"**
7. ✅ Verás: `WP_BASE_URL` en la lista (visible tras commit)

---

## ⚡ Paso 3: Cargar `WP_USER` en GitHub (Secret)

1. En la misma página (**Settings → Secrets and variables → Actions**)
2. Haz clic en la pestaña **Secrets**
3. Haz clic en **"New repository secret"**
4. Completa:
   - **Name:** `WP_USER`
   - **Value:** Tu usuario de WordPress (ej: `github-actions` o `admin`)
5. Haz clic en **"Add secret"**
6. ✅ Verás: `WP_USER` en la lista (enmascarado como `***`)

---

## ⚡ Paso 4: Cargar `WP_APP_PASSWORD` en GitHub (Secret)

1. En la misma página (**Settings → Secrets and variables → Actions**)
2. Haz clic en **"New repository secret"** nuevamente
3. Completa:
   - **Name:** `WP_APP_PASSWORD`
   - **Value:** **Pega aquí la contraseña generada en Paso 1**
4. Haz clic en **"Add secret"**
5. ✅ Verás: `WP_APP_PASSWORD` en la lista (enmascarado como `***`)

⚠️ **IMPORTANTE:** GitHub enmascara automáticamente los secrets. Nunca se mostrarán en logs ni commits.

---

## ✅ Verificación: Los 3 valores están cargados

Debería ver esto en **Settings → Secrets and variables → Actions**:

```
VARIABLES:
├─ WP_BASE_URL ..................... Value visible (tu URL)

SECRETS:
├─ WP_USER ......................... *** (enmascarado)
└─ WP_APP_PASSWORD ................ *** (enmascarado)
```

---

## 🔄 Próximo Paso: Ejecutar Verificaciones

Avisa a Copilot cuando hayas completado los 4 pasos. Luego:

1. **Ir a Actions → Verify Home → "Run workflow"**
   - Ejecutar con rama por defecto
   - Esperar ~30 segundos
   - **Descargar artifact** `verify-home-summary.txt`
   - Buscar: `mode=real; Auth=OK` ← ✅ Si ves esto, todo funciona

2. **Si Auth=OK:** Ejecutar `Verify Settings`, `Verify Menus`, `Verify Media` en orden

3. **Si Auth=KO:** Verificar:
   - URL correcta y accesible desde internet
   - Usuario existe en WordPress
   - Application Password no expirada
   - REST API habilitada en WordPress Admin → Settings → Permalinks → (Guardar cambios)

---

## 🆘 Troubleshooting Rápido

| Error | Causa | Solución |
|-------|-------|----------|
| `Auth=KO; http_code=401` | Usuario/password incorrecto | Regenrar Application Password en WP |
| `Auth=KO; http_code=403` | Permisos insuficientes | Usuario debe ser Editor o Admin |
| `Auth=KO; http_code=404` | URL incorrecta o REST API deshabilitada | Verificar URL; ir a WP Settings → Permalinks → Guardar |
| `Auth=KO; http_code=000` | URL no alcanzable | Verificar acceso desde internet; firewall |

---

## 📋 Checklist Final

- [ ] Generé Application Password en WordPress
- [ ] Cargué `WP_BASE_URL` en GitHub (Variables)
- [ ] Cargué `WP_USER` en GitHub (Secrets)
- [ ] Cargué `WP_APP_PASSWORD` en GitHub (Secrets)
- [ ] Verifiqué los 3 valores en Settings → Secrets and variables
- [ ] Avisé a Copilot que estoy listo

---

## 🎯 Tiempo Total Estimado

- **Generar Application Password:** 1 minuto
- **Cargar 3 valores en GitHub:** 3 minutos
- **Verificar en Settings:** 1 minuto

**Total:** ~5 minutos

---

## ❓ Preguntas Frecuentes

**P: ¿Puedo reutilizar la Application Password que usé para otra cosa?**  
R: Sí, pero no es recomendado. Lo ideal es generar una nueva específica para GitHub Actions.

**P: ¿Se expone la contraseña en los logs?**  
R: No. GitHub la enmascara automáticamente como `***`. Copilot tampoco accede a ella.

**P: ¿Puedo cambiar los valores después?**  
R: Sí. Ve a Settings → Secrets and variables, haz clic en el secret, y actualízalo.

**P: ¿Qué pasa si me equivoco al copiar la contraseña?**  
R: Deberás regenerar una nueva Application Password en WordPress.

---

## 📞 Siguiente Paso

Cuando hayas cargado los 3 valores, **comenta aquí o avisa a Copilot** para que ejecute las verificaciones.

---

**Guía generada automáticamente para Fase 7 — Conmutación a WordPress Real.**  
Última actualización: 2025-10-20
