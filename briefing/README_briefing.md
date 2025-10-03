# Estado del Proyecto — Octubre 2025

## Estado del proyecto
- [x] **Fase 0 – Diagnóstico** (cerrada)
- [x] **Fase 1 – Pilotos y estructura base** (cerrada)
- [x] **Fase 2 – Automatización y control** (cerrada) — ver [Corte de Control — Fase 2](./_reports/corte_control_fase2.md)
- [ ] **Fase ARQ – Sistema briefing interno** (en curso)

📎 Referencia: [Arquitectura del Briefing](docs/briefing_arquitectura.md)

### Visibilidad por rol

| Sección / módulo | Equipo | Cliente | Visitante |
| --- | :---: | :---: | :---: |
| Reportes (cliente) | ✅ | ✅ | 🔒 |
| Reportes (interno) | ✅ | 🔒 | 🔒 |
| Decisiones e Inbox | ✅ | 🔒 | 🔒 |
| Documentación técnica | ✅ | ✅ | 🔒 |
| Press-kit | ✅ | ✅ | 🔒 |
| Plan & Roadmap / Proceso | ✅ | ✅ | 🔒 |

> Nota: La segmentación actual se controla con `overrides/roles.js` y las clases `interno` en la navegación de `mkdocs.yml`.

### Acciones pendientes (tras corte Fase 2)
- Sustituir imágenes dummy por optimizadas en las fichas piloto e intermedias.  
- Corregir/validar enlaces externos con alerta.  
- Confirmar PDFs v0/v1 publicados (ES/EN).  
- Reejecutar corte de control tras las correcciones.  

### Roadmap inmediato
- **Fase 3 – Escalamiento de fichas y contenidos**  
   Ampliar de 10 a 20–30 proyectos documentados, con bio extendida, narrativa corporativa definitiva y testimonios reales.  

- **Fase 4 – Traducción bilingüe**  
   Traducir fichas y press-kit al inglés con consistencia en PDFs y navegación.  

*(Ver [Master Plan](./_reports/2025-10-02_master_plan.md) para roadmap completo hasta Fase 8.)*

---

# RUN Art Foundry — Micrositio Briefing (submódulo)

## Qué es
Micrositio privado (MkDocs Material) para documentar plan, fases, auditoría, proceso y captura de **Decisiones** (formulario → Cloudflare Worker + KV) con acceso restringido (Cloudflare Access).

## Estructura
- `mkdocs.yml` configuración del micrositio.
- `docs/` contenido en Markdown.
- `overrides/` meta `noindex` y ajustes del tema.
- `functions/api/` Pages Functions (decisiones.js, inbox.js) con binding `DECISIONES`.
- `wrangler.toml` configuración de Pages con bindings KV.

## Requisitos
- Python 3.11+ y `pip install mkdocs mkdocs-material`.
- Cloudflare Pages (build de MkDocs), Cloudflare Access y KV (namespace `DECISIONES`).
- Pages Functions para los endpoints de API (sin necesidad de workers.dev).

## Estado del deployment

### ✅ Completado
- **Sitio local**: http://127.0.0.1:8000 (ejecutar `cd briefing && .venv/bin/mkdocs serve`)
- **Cloudflare Pages**: https://dcf7222b.runart-briefing.pages.dev (también https://runart-briefing.pages.dev)
- **KV Namespaces**:
  - Production: `6418ac6ace59487c97bda9c3a50ab10e`
  - Preview: `e68d7a05dce645478e25c397d4c34c08`

### ✅ Arquitectura final (Pages Functions)

**Backend**: Los endpoints de API ahora corren como **Cloudflare Pages Functions** integradas en el mismo dominio de Pages, sin necesidad de workers.dev:
- `POST https://runart-briefing.pages.dev/api/decisiones`
- `GET https://runart-briefing.pages.dev/api/inbox`

**Bindings KV**:
- Production: `6418ac6ace59487c97bda9c3a50ab10e`
- Preview: `e68d7a05dce645478e25c397d4c34c08`
- Configurados en `wrangler.toml`

### ⚠️ Acción requerida (usuario)

1. **Activar Cloudflare Access** (privacidad - OBLIGATORIO):
   - Ir a: https://dash.cloudflare.com/a2c7fc66f00eab69373e448193ae7201/pages
   - Seleccionar proyecto `runart-briefing`
   - En Settings → Access → Enable Access
   - Crear regla "Allow" solo para correo de Uldis
   - Una vez activo, el header `Cf-Access-Authenticated-User-Email` poblará el usuario real

2. **Opcional - CI/CD con GitHub Actions**:
   - Crear secretos en GitHub:
     - `CF_API_TOKEN`: Token de API de Cloudflare
     - `CF_ACCOUNT_ID`: `a2c7fc66f00eab69373e448193ae7201`
   - Mover `.github/workflows/briefing_pages.yml` a la raíz del repo (si el repo Git incluye todo el proyecto)

## Pasos sugeridos (usuario)
1) Servir en local:
   ```bash
   cd briefing
   .venv/bin/mkdocs serve
   # O si prefieres recrear el entorno:
   python -m venv .venv
   .venv/bin/pip install --upgrade pip
   .venv/bin/pip install mkdocs mkdocs-material
   .venv/bin/mkdocs serve
   ```
   
2) Build y redeploy:
   ```bash
   cd briefing
   .venv/bin/mkdocs build
   npx wrangler pages deploy site --project-name runart-briefing
   ```

## Operativa

### Promover fichas del inbox → YAML
1. Abrir **Actions → Promote Inbox → YAML** y lanzar `Run workflow`.
2. Verificar o ajustar el parámetro `source_url` (por defecto: `/api/inbox`).
3. Tras la ejecución se generan automáticamente:
   - `docs/projects/<slug>.yaml` (ficha preliminar en español).
   - `docs/projects/en/<slug>.yaml` (stub en inglés).
   - `assets/<year>/<slug>/.gitkeep` (carpeta para medios futuros).
4. El menú del briefing añade la sección **“Nuevas fichas (ES)”** con los slugs generados.
5. Consultar `briefing/_reports/fase1_fichas.md` y `briefing/_logs/briefing_run.log` para el registro de la promoción.

### Capturar fichas con el editor guiado
1. Ir a **Herramientas → Editor** en la navegación interna (rol equipo).
2. Completar los campos requeridos (slug, título, artista, año) y cargar listas con el formato `https://url | detalle`.
3. Revisar la vista previa YAML y, si es correcto, copiarla o enviarla directo al inbox (`/api/decisiones`).
4. Cada envío añade `token_origen: editor_v1` y un comentario interno para trazabilidad.
5. Antes de promover, ejecutar `python scripts/validate_projects.py` desde `briefing/` para confirmar que la ficha cumple el esquema.

### Build & QA (ARQ-2)
1. Preparar entorno: `make venv`
2. Compilar sitio: `make build`
3. Servir en local: `make serve`
4. Validar una ficha: `python scripts/validate_projects.py /ruta/al/archivo.yaml`

## Archivos creados
```
briefing/
├─ mkdocs.yml
├─ README_briefing.md
├─ docs/
│  ├─ index.md
│  ├─ plan/index.md
│  ├─ fases/index.md
│  ├─ auditoria/index.md
│  ├─ proceso/index.md
│  ├─ galeria/index.md
│  ├─ decisiones/
│  │  ├─ index.md
│  │  └─ contenido-sitio-viejo.md
│  ├─ inbox/index.md
│  ├─ acerca/index.md
│  └─ robots.txt
├─ overrides/
│  └─ main.html
└─ workers/
   └─ decisiones.js
```

## Próximos pasos
1. Ejecutar los comandos de instalación y servir en local (ver arriba).
2. Revisar y personalizar el contenido de cada página `.md`.
3. Actualizar las URLs de los endpoints del Worker en los archivos de formularios.
4. Configurar Cloudflare Pages, Access y KV según la documentación.
