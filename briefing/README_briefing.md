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
