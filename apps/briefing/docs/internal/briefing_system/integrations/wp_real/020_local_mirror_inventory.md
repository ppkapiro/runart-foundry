# 📦 Inventario de Descarga Local (Mirror)

**Documento:** `020_local_mirror_inventory.md`  
**Objetivo:** Describir qué contenido se descargó localmente del sitio WordPress.  
**Entrada:** Árbol de directorios, tipos de activos, checksums

---

## 📂 Árbol de Directorios Local

**Ubicación esperada:** `mirror/` o similar en el repositorio.

**Status:** 🟡 Pendiente descripción del owner

### Estructura Alto-Nivel

```
(será completado con evidencia)

Ej:
mirror/
├── raw/
│   ├── 2025-10-01/
│   │   ├── wp-content/
│   │   ├── wp-config-sample.php
│   │   └── index.php
│   └── 2025-10-15/
│       └── ... (snapshot más reciente)
├── index.json
├── README.md
└── scripts/
    └── sync.sh
```

---

## 🎯 Qué Se Descargó (Tipos de Activos)

**Status:** 🟡 Pendiente confirmación del owner

Marca lo que se descargó:

### Base de Datos
- [ ] SQL dump (completo)
- [ ] SQL dump (solo esquema)
- [ ] SQL dump (solo datos)
- **Ubicación:** (si aplica)
- **Tamaño:** (si aplica)
- **Última actualización:** (si aplica)

### WordPress Core
- [ ] `wp-admin/`
- [ ] `wp-includes/`
- [ ] `wp-content/` (raíz)
- **Completo:** (Sí/No)

### Temas
- [ ] Tema principal
- [ ] Tema hijo (child theme)
- [ ] Otros temas
- **Nombres:** (listar, ej: "Divi", "GeneratePress Child")
- **Ubicación:** `wp-content/themes/`

### Plugins
- [ ] Plugins activos
- [ ] Plugins inactivos
- [ ] Todos (completos)
- **Cantidad:** (ej: 15 plugins)
- **Ubicación:** `wp-content/plugins/`
- **Tamaño total:** (ej: 450 MB)

### Uploads / Media
- [ ] Carpeta `wp-content/uploads/` (completa)
- [ ] Solo metadatos (JSON)
- [ ] Galería de imágenes
- **Tamaño total:** (ej: 1.2 GB)
- **Últimas modificaciones:** (rango de fechas)

### Configuración
- [ ] `wp-config.php` (sample/sin credenciales)
- [ ] `.htaccess` (si aplica)
- [ ] `robots.txt`
- [ ] Otros

### Datos Específicos de Contenido
- [ ] Posts/Páginas (JSON/XML)
- [ ] Usuarios (metadatos sanitizados)
- [ ] Menús (JSON)
- [ ] Taxonomías (categorías, tags)
- [ ] Metadatos (custom fields)

---

## 🔐 NO Versionarse (Exclusiones)

**Nunca subir a Git:**

```
# Sensibles
wp-config.php (con credenciales)
.env
.env.local
*.key
*.pem
*.crt
secrets/

# Masivos
wp-content/uploads/ (usar .gitkeep)
node_modules/
wp-content/plugins/*/ (versionar solo lista)

# Temporales
*.sql (dumps)
*.tar.gz
*.zip
_tmp/
_cache/
```

### Plantilla de `.gitignore` Local

```bash
# Si necesitas un .gitignore específico en _templates/ o mirror/:

# Archivos sensibles
*.sql
wp-config.php
wp-config-*.php
.env
.env.*
*.key
*.pem
*.crt

# Secretos
secrets/
credentials/
_credentials/

# Contenido masivo
wp-content/uploads/
uploads/
wp-content/plugins/*/
wp-content/themes/*/

# Temporales
*.zip
*.tar.gz
*.tgz
_tmp/
_cache/
.DS_Store
Thumbs.db
```

---

## 📊 Checksums (Si Aplica)

**Status:** 🟡 Pendiente si el owner dispone de checksums

Útil para validar integridad de descargas.

### Archivos Críticos
- **wp-config-sample.php:** (MD5 o SHA256, si aplica)
- **index.php:** (si aplica)
- **Carpeta wp-content/uploads/:** (hash de árbol, si aplica)

### Cómo Generar Checksums (Referencia)
```bash
# Un archivo
sha256sum archivo.php > archivo.php.sha256

# Una carpeta (árbol completo)
find wp-content/uploads -type f -exec sha256sum {} + > uploads.sha256

# Validar después
sha256sum -c uploads.sha256
```

**Checksums capturados:**
```
(será completado si aplica)
```

---

## 📏 Estadísticas de Descarga

**Status:** 🟡 Pendiente confirmación

| Aspecto | Valor |
|--------|-------|
| **Fecha de descarga** | (ej: 2025-10-01) |
| **Última actualización local** | (ej: 2025-10-15) |
| **Tamaño total** | (ej: 2.5 GB) |
| **Número de archivos** | (ej: 15,000) |
| **Directorio raíz** | (ej: `mirror/raw/2025-10-15/`) |
| **Método de descarga** | (SFTP, wget, rsync, otro) |
| **Completitud** | (100%, parcial, qué está excluido) |

---

## ✅ Checklist de Validación

- [ ] Árbol completo descrito (alto nivel)
- [ ] Tipos de activos identificados (DB, themes, plugins, uploads)
- [ ] Tamaños aproximados registrados
- [ ] NO hay archivos sensibles versionados
- [ ] `.gitignore` local aplicado (si necesario)
- [ ] Checksums validados (si aplica)
- [ ] Última descarga documentada con fecha

---

## 🔗 Referencias

- Documento central: `000_state_snapshot_checklist.md`
- README: `README.md` (en esta carpeta)
- Plantillas: `_templates/evidencia_*.txt`

---

## 🎯 Plantilla para Owner: Descripción de Árbol Local

**Copia, completa y pega en `_templates/evidencia_local_mirror.txt`:**

```
=== ÁRBOL LOCAL DE DESCARGA ===
Fecha: [YYYY-MM-DD]
Ubicación: [ruta local]
Tamaño total: [X GB]

== CONTENIDO ==
✓/✗ Base de datos SQL: [ubicación y tamaño]
✓/✗ wp-admin/: [Sí/No, tamaño]
✓/✗ wp-includes/: [Sí/No, tamaño]
✓/✗ wp-content/: [Sí/No, tamaño]
  ├─ wp-content/themes/: [nombres]
  ├─ wp-content/plugins/: [cantidad, tamaño total]
  └─ wp-content/uploads/: [tamaño]
✓/✗ wp-config-sample.php: [Sí/No]
✓/✗ .htaccess: [Sí/No]

== ARCHIVOS EXCLUIDOS (NO VERSIONADOS) ==
- wp-config.php (si existe)
- .env (si existe)
- Certificados (*.key, *.pem, *.crt)
- Dumps SQL completos (versionar solo resumen)
- wp-content/uploads/ (demasiado pesado)

== NOTAS ==
[Cualquier observación especial]
```

---

**Estado:** 🟡 Pendiente descripción del owner  
**Última actualización:** 2025-10-20  
**Próxima revisión:** Tras recepción de evidencia de árbol local
