# 🔐 Disponibilidad REST API y Autenticación

**Documento:** `040_wp_rest_and_authn_readiness.md`  
**Objetivo:** Verificar disponibilidad de endpoints REST y compatibilidad con Application Passwords.  
**Entrada:** Status HTTP de endpoints, confirmación de Application Passwords en WP-Admin

---

## 📡 Endpoint Base REST

**Status:** 🟡 Pendiente confirmación

### URL Base Esperada

```
https://runalfondry.com/wp-json/
```

### Disponibilidad

**Comando para verificar (SIN credenciales):**
```bash
curl -i https://runalfondry.com/wp-json/
```

**Respuesta esperada:**
```
HTTP/1.1 200 OK
Content-Type: application/json
Cache-Control: public, max-age=3600

{
  "namespace": "wp/v2",
  "endpoints": [...]
}
```

| Aspecto | Valor |
|--------|-------|
| **HTTP Status** | (ej: 200 OK, 401 Unauthorized, 403 Forbidden, 404 Not Found) |
| **Accesible públicamente** | ✅ Sí / 🔴 No / 🟡 Parcialmente |
| **Cache habilitado** | (ej: Cache-Control: public, max-age=3600) |
| **CORS headers** | (ej: Access-Control-Allow-*) |
| **Versión WP JSON** | (ej: wp/v2) |

### Validación
- [ ] Endpoint `.../wp-json/` responde con status 200 o 401
- [ ] NO devuelve 404 (endpoint no existe)
- [ ] NO devuelve 503 (deshabilitado)
- [ ] Headers de caché presentes (opcional pero recomendado)

---

## 🔑 Application Passwords (Autenticación)

**Status:** 🟡 Pendiente confirmación del owner

### Verificar en WP-Admin

**Ruta:** Administración de WordPress → Users → Tu usuario → Application Passwords

### Requisitos
- [ ] WordPress versión 5.6+ (Application Passwords nativa)
- [ ] Opción habilitada en WP-Admin (Settings → Network Settings si es multisitio)
- [ ] Usuario tiene rol suficiente (Editor o superior)

### Instrucciones para Owner

1. **Accede a WP-Admin**
   ```
   https://runalfondry.com/wp-admin/
   ```

2. **Ve a Users → Tu usuario**
   ```
   https://runalfondry.com/wp-admin/users.php
   (Click en tu nombre de usuario)
   ```

3. **Busca "Application Passwords"**
   - Si no lo ves, tu servidor podría no tener WP 5.6+ o está deshabilitado

4. **Crea una nueva Application Password**
   - Nombre: `github-actions` (recomendado)
   - Copia la contraseña generada (aparece una sola vez)

5. **Guarda en GitHub**
   - Settings → Secrets and variables → Actions → Secrets
   - Name: `WP_APP_PASSWORD`
   - Value: (pega aquí)

### Verificación de Compatibilidad

**Comando para verificar autenticación (SIN credenciales reales):**
```bash
# NO incluyas credenciales en este test
curl -i -u "dummy-user:dummy-password" \
  https://runalfondry.com/wp-json/wp/v2/users/me
```

**Respuesta esperada:**
```
HTTP/1.1 401 Unauthorized

(No incluir credenciales reales en la evidencia)
```

---

## 📋 Endpoints a Validar

Todos estos deben ser accesibles (con autenticación cuando sea necesario):

### 1. Users (Autenticación)

**Endpoint:** `GET /wp-json/wp/v2/users/me`

| Aspecto | Status Esperado |
|--------|-----------------|
| **Sin autenticación** | 401 Unauthorized ✓ |
| **Con Application Password** | 200 OK ✓ |
| **Con contraseña incorrecta** | 401 Unauthorized ✓ |

**Verificación manual:**
```bash
# En WP-Admin, copiar usuario y confirmar que es válido
# Luego, verify-home ejecutará este endpoint con credenciales reales
```

### 2. Settings (Configuración)

**Endpoint:** `GET /wp-json/wp/v2/settings`

| Aspecto | Validación |
|--------|-----------|
| **Acceso público** | Limitado (algunos fields) |
| **Con autenticación** | Acceso completo |
| **Campos esperados** | `timezone_string`, `permalink_structure`, `start_of_week`, `show_on_front`, `page_on_front` |

**Verificación posterior (con Auth):**
```bash
curl -u "usuario:password" \
  https://runalfondry.com/wp-json/wp/v2/settings
```

### 3. Pages (Páginas)

**Endpoint:** `GET /wp-json/wp/v2/pages`

| Aspecto | Validación |
|--------|-----------|
| **Acceso público** | Visible (publicadas) |
| **Draft/scheduled** | Solo con autenticación |
| **Esperado** | Al menos 1 página inicial |

### 4. Menus (Menús)

**Endpoint:** `/wp-json/menus/v1/menus` (si existe REST API para menús)

| Aspecto | Validación |
|--------|-----------|
| **Plugin requerido** | REST API Menus o similar |
| **Disponible** | ✅ Sí / 🔴 No |
| **Idiomas (si Polylang)** | `/wp-json/menus/v1/menus?lang=es`, `/...?lang=en` |

---

## 🛡️ Notas de Seguridad

### Caché y CDN
- [ ] Respuestas JSON cacheadas (si aplica)
- [ ] CDN delante de WordPress (CloudFlare, etc.)
- [ ] Headers `X-Cache` presentes (para diagnóstico)

### WAF (Web Application Firewall)
- [ ] CloudFlare u otro WAF frente al sitio
- [ ] Rate limiting en endpoints sensibles
- [ ] Verificar que WAF NO bloquea `users/me` (es seguro, requiere auth)

### Protecciones Adicionales
- [ ] XML-RPC deshabilitado (legacy, no necesario para REST)
- [ ] WP-Admin protegido por IP (opcional)
- [ ] Logs de intentos fallidos activos

---

## 📋 Plantilla de Evidencia REST

### Archivo: `_templates/evidencia_rest_sample.txt`

**Copia, completa y pega (SIN credenciales):**

```
=== VERIFICACIÓN REST API ===
Fecha: [YYYY-MM-DD]

== ENDPOINT BASE ==
GET https://runalfondry.com/wp-json/
HTTP Status: [ej: 200 OK]
Content-Type: application/json
Accesible: Sí / No

== USERS/ME (SIN CREDENCIALES) ==
GET https://runalfondry.com/wp-json/wp/v2/users/me
HTTP Status: 401 Unauthorized (esperado sin auth)

== SETTINGS ==
GET https://runalfondry.com/wp-json/wp/v2/settings
HTTP Status: 200 OK (acceso público limitado)

== PAGES ==
GET https://runalfondry.com/wp-json/wp/v2/pages
HTTP Status: 200 OK
Páginas detectadas: [cantidad, ej: 5]

== MENUS ==
GET https://runalfondry.com/wp-json/menus/v1/menus (si existe)
HTTP Status: [200 OK / 404 Not Found]
Plugin detectado: Sí / No / No verif

== APPLICATION PASSWORDS ==
Habilitadas en WP-Admin: Sí / No
Usuario tiene permisos: Sí / No
Creada nueva: Sí / No

== NOTAS ==
[Observaciones especiales]
```

---

## ✅ Checklist de Validación

### Pre-Conmutación a Auth=OK

- [ ] Endpoint `/wp-json/` accesible (HTTP 200 o 401)
- [ ] WordPress versión 5.6+ confirmada
- [ ] Application Passwords habilitadas en WP-Admin
- [ ] Usuario tiene rol Editor o superior
- [ ] Usuario puede generar Application Passwords
- [ ] Endpoint `/wp-json/wp/v2/users/me` devuelve 401 sin auth ✓
- [ ] URL base (`WP_BASE_URL`) es HTTPS
- [ ] SSL/TLS certificado válido (no self-signed)
- [ ] NO hay WAF bloqueando endpoints necesarios
- [ ] Headers de seguridad presentes (si aplica)

---

## 🔄 Flujo de Autenticación (Diagrama)

```
┌─ Workflows verify-* ─────────────────────────────────┐
│                                                       │
├─ Variables/Secrets cargados en GitHub                │
│  ├─ WP_BASE_URL = https://runalfondry.com           │
│  ├─ WP_USER = github-actions                         │
│  └─ WP_APP_PASSWORD = (GitHub Secret, enmascarado)  │
│                                                       │
├─ Workflow ejecutado (ej: verify-home)               │
│  ├─ Leer WP_BASE_URL, WP_USER, WP_APP_PASSWORD      │
│  ├─ GET /wp-json/wp/v2/users/me                     │
│  │   Con Authorization: Basic <base64>              │
│  └─ Respuesta esperada: HTTP 200 OK (Auth=OK)       │
│                                                       │
└─ Artifact generado con "mode=real; Auth=OK"          │
```

---

## 🎯 Próximos Pasos (Tras Validación)

1. ✅ Owner confirma endpoints accesibles
2. ✅ Owner crea Application Password y lo carga en GitHub
3. ✅ Copilot ejecuta `verify-home` manualmente
4. ✅ Si status es 200 + Auth=OK → Proceder con otros workflows
5. ✅ Si status es 401 → Revisar credenciales y reintentar

---

## 🔗 Referencias

- Documento central: `000_state_snapshot_checklist.md`
- README: `README.md` (en esta carpeta)
- Plantillas: `_templates/evidencia_rest_sample.txt`

---

**Estado:** 🟡 Pendiente confirmación REST  
**Última actualización:** 2025-10-20  
**Próxima revisión:** Tras verificación de endpoints
