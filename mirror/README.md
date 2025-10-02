# Mirror — Snapshots del Sitio del Cliente

## Propósito

Este directorio contiene **plantillas y metadatos** para gestionar snapshots del sitio web del cliente (WordPress).

**IMPORTANTE**: Los datos reales (dumps SQL, wp-content, archivos estáticos) **NO se suben a Git** debido a su tamaño (>760 MB). Solo se guardan plantillas, scripts y metadatos (`index.json`).

## Política de Almacenamiento

- **En Git**: Plantillas, scripts, `index.json` (metadatos)
- **Fuera de Git** (local o storage externo): Datos binarios, dumps SQL, wp-content/uploads

## Estructura

```
mirror/
├── README.md                    # Este archivo
├── index.json                   # Metadatos de snapshots (fechas, ubicación externa, checksums)
├── scripts/
│   └── fetch.sh                 # Script para capturar snapshots (plantilla comentada)
├── normalized/                  # (futuro) Datos procesados/normalizados
└── raw/                         # (gitignored) Snapshots crudos descargados
    └── YYYY-MM-DD/              # Carpeta por fecha de captura
        ├── db_dump.sql          # Dump de base de datos
        ├── site_static/         # HTML estático (wget mirror)
        └── wp-content/          # Plugins, themes, uploads (NO subir a Git)
```

## Última Captura

- **Fecha**: 1 de octubre de 2025
- **Método**: SFTP + wget
- **Tamaño total**: ~760 MB
- **Ubicación**: Local en `mirror/raw/2025-10-01/` (gitignored)
- **Alcance**:
  - ✅ Base de datos: `db_dump.sql` (vacío, 0 bytes)
  - ✅ Contenido estático: `site_static/` (956 KB)
  - ✅ WordPress: `wp-content/` (759 MB — plugins, themes, uploads)

## Ubicación Externa de Datos

**Storage recomendado** (futuro):
- Cloudflare R2
- AWS S3
- Backblaze B2
- Google Cloud Storage

**Acceso**:
- Contactar al equipo para obtener acceso a snapshots históricos
- Ver `index.json` para URLs de descarga

## Scripts de Captura

Ver `scripts/fetch.sh` para un ejemplo comentado de cómo capturar snapshots con:
- `rsync` o `sftp` para wp-content
- `wget --mirror` para HTML estático
- `mysqldump` para base de datos

## Exclusiones en `.gitignore`

El archivo `.gitignore` en la raíz excluye automáticamente:

```gitignore
# Mirror: payload excluido
mirror/raw/**
mirror/**/*.zip
mirror/**/*.sql
mirror/**/*.gz
mirror/**/wp-content/**
mirror/**/cache/**
mirror/**/backup*/
```

## Checklist de Captura

Al crear un nuevo snapshot:

- [ ] Crear carpeta `mirror/raw/YYYY-MM-DD/`
- [ ] Descargar base de datos → `db_dump.sql`
- [ ] Descargar contenido estático → `site_static/`
- [ ] Descargar wp-content → `wp-content/`
- [ ] Actualizar `index.json` con metadatos (fecha, tamaño, checksum)
- [ ] Subir snapshot a storage externo si >100 MB
- [ ] Commit solo de `index.json` actualizado (NO archivos pesados)

## Restauración

Para restaurar un snapshot:

1. Descargar desde storage externo (ver `index.json` para URL)
2. Extraer en `mirror/raw/YYYY-MM-DD/`
3. Importar base de datos: `mysql < db_dump.sql`
4. Copiar wp-content al servidor: `rsync -avz wp-content/ user@server:/path/to/wp-content/`

## Contacto

**Responsable**: @ppkapiro  
**Última actualización**: 2 de octubre de 2025
