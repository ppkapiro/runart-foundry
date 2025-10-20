# 🖥️ Conectividad SSH y Hechos del Servidor

**Documento:** `030_ssh_connectivity_and_server_facts.md`  
**Objetivo:** Verificar accesibilidad SSH y documentar stack del servidor (sanitizado).  
**Entrada:** Salidas de `uname -a`, `php -v`, `nginx -v`/`apachectl -v`, etc.

---

## 🔌 Conectividad SSH

**Status:** 🟡 Pendiente confirmación del owner

### Detalles de Conexión

| Aspecto | Valor |
|--------|-------|
| **Hostname/IP** | (ej: `prod.runalfoundry.com` o IP pública) |
| **Puerto SSH** | (típicamente 22, ej: 2222 si custom) |
| **Usuario SSH** | (ej: `ubuntu`, `ec2-user`, `root` - NO exponer) |
| **Proveedor Hosting** | (ej: AWS EC2, DigitalOcean, Linode, VPS custom) |
| **Acceso confirmado** | ✅ Sí / 🔴 No / 🟡 Pendiente |
| **Notas** | (tunneling, bastion host, restricciones IP, etc.) |

### Status de Conectividad
- [ ] SSH conecta exitosamente
- [ ] No hay restricciones por IP/firewall
- [ ] No hay firewall bloqueando puerto 22
- [ ] SSH key configurada (no pedir contraseña)
- [ ] Timeout razonable (~30 segundos)

---

## 📋 Sistema Operativo

**Status:** 🟡 Pendiente captura de `uname -a`

### Salida de `uname -a` (Sanitizada)

**Comando:** `ssh usuario@hostname 'uname -a'`

```
(será completado con evidencia)

Ej:
Linux prod-server 5.15.0-56-generic #62-Ubuntu SMP Fri Nov 11 22:58:18 UTC 2022 x86_64 GNU/Linux
```

### Análisis
- **SO:** (Linux, BSD, etc.)
- **Kernel:** (versión, ej: 5.15.0)
- **Arquitectura:** (x86_64, ARM, etc.)
- **Distribución:** (Ubuntu, Debian, CentOS, etc. - si es visible)

---

## 🐘 PHP

**Status:** 🟡 Pendiente captura de `php -v`

### Salida de `php -v`

**Comando:** `ssh usuario@hostname 'php -v'` o desde WP-Admin → Tools → Site Health

```
(será completado con evidencia)

Ej:
PHP 8.2.0 (cli) (built: Nov 15 2022 12:00:00)
Copyright (c) The PHP Group
Zend Engine v4.2.0, Copyright (c) Zend Technologies
    with Xdebug v3.2.0, Copyright (c) 2002-2022, by Dario Zenatti
```

### Validación
- [ ] PHP versión ≥ 7.4 (recomendado ≥ 8.0)
- [ ] Extensiones necesarias presentes (curl, openssl, json, mbstring, etc.)
- [ ] OPcache habilitada (rendimiento)

---

## 🌐 Servidor Web

### Nginx

**Comando:** `nginx -v` o `nginx -V`

```
(será completado con evidencia)

Ej:
nginx version: nginx/1.24.0 (Ubuntu)
```

### Apache

**Comando:** `apachectl -v` o `apache2ctl -v`

```
(será completado con evidencia)

Ej:
Server version: Apache/2.4.52 (Ubuntu)
Server built:   2022-11-15 12:00:00 UTC
```

### Validación
- [ ] Servidor web accesible por HTTPS
- [ ] Certificado SSL/TLS válido
- [ ] Redirección HTTP → HTTPS funciona
- [ ] Headers de seguridad presentes (X-Frame-Options, etc.)

---

## 🗄️ Base de Datos

**Status:** 🟡 Pendiente captura de información de BD

### MySQL / MariaDB

**Comando:** `ssh usuario@hostname 'mysql -V'`

```
(será completado con evidencia)

Ej:
mysql  Ver 8.0.35-0ubuntu0.22.04.1 for Linux on x86_64 ((Ubuntu))
```

### Validación
- [ ] BD accesible desde el servidor
- [ ] Versión soportada (MySQL 5.7+, MariaDB 10.1+)
- [ ] Backups regulares confirmados (si aplica)

---

## 🌳 Ubicación de WordPress

**Status:** 🟡 Pendiente confirmación

### Rutas Esperadas

| Elemento | Ruta | Confirmado |
|----------|------|-----------|
| **WP Root** | (ej: `/var/www/html`, `/home/user/public_html`) | ⏳ |
| **wp-content/** | (típicamente dentro de WP Root) | ⏳ |
| **wp-config.php** | (típicamente en WP Root, con credenciales) | ⏳ |
| **uploads/** | (ej: `wp-content/uploads/`) | ⏳ |
| **themes/** | (ej: `wp-content/themes/`) | ⏳ |
| **plugins/** | (ej: `wp-content/plugins/`) | ⏳ |

---

## 🔐 Permisos y Propietario

**Status:** 🟡 Pendiente captura de `ls -la`

### Comando Recomendado (Sanitizado)

```bash
# Mostrar permisos de archivos clave (SIN caminos completos)
ls -la wp-config.php
ls -la wp-content/
ls -ld wp-content/uploads/
```

**Salida esperada:**
```
(será completado con evidencia)

Ej:
-rw-r--r-- 1 www-data www-data  3429 Oct 15 10:00 wp-config.php
drwxrwxr-x 5 www-data www-data  4096 Oct 15 10:00 wp-content/
drwxrwxrwx 8 www-data www-data  4096 Oct 15 10:00 wp-content/uploads/
```

### Validación
- [ ] Propietario de archivos: `www-data`, `nginx`, `apache`, o similar
- [ ] Permisos típicos: 644 (archivos), 755 (directorios)
- [ ] `wp-content/uploads/` escribible (755/775)
- [ ] `wp-config.php` NO es legible globalmente (no 644)

---

## ⚠️ Buenas Prácticas Pendientes

Checklist de hardening observado:

### Seguridad
- [ ] HTTPS/SSL forzado
- [ ] Headers de seguridad (X-Frame-Options, X-Content-Type-Options)
- [ ] Rate limiting en WP-Admin
- [ ] Protección contra ataques DDoS (CloudFlare, WAF)
- [ ] Two-Factor Authentication habilitado para admins

### Rendimiento
- [ ] Caché del lado del servidor (Redis, Memcached)
- [ ] Caché de páginas estáticas
- [ ] CDN para assets/uploads
- [ ] Compresión GZIP habilitada

### Mantenimiento
- [ ] Backups automáticos (diarios, semanales)
- [ ] Actualizaciones de WordPress automáticas
- [ ] Logs de acceso y errores guardados
- [ ] Monitoreo de disponibilidad activo

---

## 📋 Evidencias Esperadas

### Archivo: `_templates/evidencia_server_versions.txt`

**Copia, completa y pega en este archivo (texto plano, SIN sentivos):**

```
=== INFORMACIÓN DEL SERVIDOR ===
Fecha de captura: [YYYY-MM-DD]

== SO Y KERNEL ==
[Salida de `uname -a`, sanitizada]

== PHP ==
[Salida de `php -v`]

== SERVIDOR WEB ==
[Nginx versión] O [Apache versión]

== BASE DE DATOS ==
[MySQL/MariaDB versión]

== UBICACIÓN WORDPRESS ==
WP Root: [ej: /var/www/html]
Propietario: [ej: www-data:www-data]
Permisos típicos: [ej: drwxr-xr-x]

== NOTAS ==
[Observaciones especiales sobre el server]
```

---

## ✅ Checklist de Validación

- [ ] Conectividad SSH confirmada
- [ ] SO y kernel documentados
- [ ] PHP versión ≥ 7.4 confirmada
- [ ] Servidor web verificado (Nginx o Apache)
- [ ] Base de datos accesible
- [ ] Ubicación WP root confirmada
- [ ] Permisos adecuados (www-data propietario)
- [ ] Certificado SSL/TLS válido
- [ ] NO hay información sensible en evidencias

---

## 🔗 Referencias

- Documento central: `000_state_snapshot_checklist.md`
- README: `README.md` (en esta carpeta)
- Plantillas: `_templates/evidencia_server_versions.txt`

---

**Estado:** 🟡 Pendiente evidencias del owner  
**Última actualización:** 2025-10-20  
**Próxima revisión:** Tras recepción de salidas sanitizadas
