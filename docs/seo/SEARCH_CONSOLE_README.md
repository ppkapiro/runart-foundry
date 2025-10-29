# Google Search Console - Configuración para Producción

## Objetivo
Registrar el sitio en Google Search Console cuando esté en producción (`runartfoundry.com`) para monitoreo SEO, indexación y envío de sitemaps bilingües (EN/ES).

⚠️ **IMPORTANTE**: NO registrar staging.runartfoundry.com en Search Console.

---

## Requisitos Previos
- Sitio en producción accesible públicamente
- Cuenta de Google (mismo que usarás para Analytics si aplica)
- Sitemaps bilingües generados:
  - `/sitemap_index.xml` (índice principal)
  - `/sitemap-en.xml` (páginas EN)
  - `/sitemap-es.xml` (páginas ES)

---

## Paso 1: Verificación de Propiedad

### Método A: HTML File Upload (Recomendado para WordPress)
1. Accede a [Google Search Console](https://search.google.com/search-console/)
2. Clic en **Agregar propiedad**
3. Selecciona **URL prefix** → `https://runartfoundry.com`
4. Elige método **HTML file**
5. Descarga el archivo de verificación (ej: `googleXXXXXXXXXXXX.html`)
6. Sube el archivo a la raíz de WordPress:
   ```bash
   # Via SSH/SFTP al docroot
   /path/to/htdocs/googleXXXXXXXXXXXX.html
   ```
7. Verifica acceso: `https://runartfoundry.com/googleXXXXXXXXXXXX.html` → debe devolver contenido
8. Clic **Verificar** en Search Console

### Método B: HTML Tag (si usas plugin SEO)
1. Usa un plugin como Yoast SEO o RankMath que tenga campo para "Search Console Verification"
2. Pega el meta tag en el campo correspondiente
3. Guarda y clic **Verificar** en Search Console

### Método C: DNS TXT Record (si tienes acceso a DNS)
1. Añade registro TXT en tu proveedor DNS:
   ```
   google-site-verification=XXXXXXXXXXXXXXXXXXXX
   ```
2. Espera propagación DNS (5-30 min)
3. Clic **Verificar** en Search Console

---

## Paso 2: Configurar Property para Versiones de Idioma

Google recomienda una property única para un sitio con subdirectorios de idioma (`/es/`):

- **Property**: `https://runartfoundry.com` (cubre `/` y `/es/`)
- Search Console detectará automáticamente las variantes de idioma via hreflang

**No es necesario** crear properties separadas para `/es/`.

---

## Paso 3: Enviar Sitemaps

1. En Search Console → **Sitemaps** (menú izquierdo)
2. Añadir sitemap principal:
   ```
   https://runartfoundry.com/sitemap_index.xml
   ```
3. Opcional (si quieres monitoreo granular):
   - `https://runartfoundry.com/sitemap-en.xml`
   - `https://runartfoundry.com/sitemap-es.xml`
4. Clic **Enviar**
5. Espera 24-48h para ver estado de indexación

---

## Paso 4: Validar Hreflang

1. En Search Console → **International Targeting** → **Language**
2. Verifica que no haya errores de hreflang:
   - `<link rel="alternate" hreflang="en" href="https://runartfoundry.com/" />`
   - `<link rel="alternate" hreflang="es" href="https://runartfoundry.com/es/" />`
   - `<link rel="alternate" hreflang="x-default" href="https://runartfoundry.com/" />`

3. Usa herramienta de inspección de URL para validar páginas clave:
   - `https://runartfoundry.com/` (EN)
   - `https://runartfoundry.com/es/` (ES)

---

## Paso 5: Monitoreo y Alertas

### Configurar alertas de email
- Search Console → **Settings** → **Email notifications**
- Activar alertas para:
  - Critical issues (errores de indexación)
  - Manual actions (penalizaciones)
  - Security issues (hacks, malware)

### Dashboards recomendados
- **Coverage**: estado de indexación de páginas
- **Performance**: clics, impresiones, CTR, posición promedio por query
- **Core Web Vitals**: métricas de rendimiento (LCP, FID, CLS)
- **Mobile Usability**: problemas de usabilidad móvil

---

## Validación Post-Configuración

### Checklist ✅
- [ ] Propiedad verificada en Search Console
- [ ] Sitemap enviado y sin errores
- [ ] Hreflang validado (0 errores)
- [ ] Páginas principales indexadas (consulta: `site:runartfoundry.com`)
- [ ] URLs móviles sin problemas
- [ ] Alertas de email configuradas

### Comandos de validación
```bash
# Verificar sitemaps accesibles
curl -I https://runartfoundry.com/sitemap_index.xml
curl -I https://runartfoundry.com/sitemap-en.xml
curl -I https://runartfoundry.com/sitemap-es.xml

# Verificar hreflang en HTML
curl -s https://runartfoundry.com/ | grep hreflang
curl -s https://runartfoundry.com/es/ | grep hreflang

# Verificar que Google ve las páginas (espera 48h post-submit)
curl -A "Googlebot" https://runartfoundry.com/
```

---

## Frecuencia de Revisión

| Métrica | Frecuencia |
|---------|-----------|
| Coverage issues | Semanal |
| Performance trends | Quincenal |
| Core Web Vitals | Mensual |
| Hreflang errors | Post-deployment |
| Sitemap status | Post-cambios masivos |

---

## Troubleshooting

### Sitemap no detectado
- Verifica que `robots.txt` incluya: `Sitemap: https://runartfoundry.com/sitemap_index.xml`
- Confirma que el sitemap sea XML válido (no HTML error page)

### Hreflang errors
- Cada página debe tener hreflang recíproco (EN apunta a ES, ES apunta a EN)
- x-default debe apuntar a una versión concreta (EN en este caso)
- URLs deben ser absolutas y accesibles (no 404)

### Páginas no indexadas
- Revisa `robots.txt` no bloquee las páginas
- Confirma que no haya `noindex` meta tag
- Verifica que las páginas devuelvan 200 OK (no 301/302 en cadena)

---

## Integración con Analytics (Opcional)

Si usas Google Analytics 4:
1. Vincula Search Console con GA4 en **Admin** → **Product Links** → **Search Console**
2. Verás datos de queries en GA4 bajo **Reports** → **Acquisition** → **Search Console**

---

## Notas de Seguridad
- Mantén el archivo de verificación HTML en el servidor indefinidamente (Search Console lo rechecquea periódicamente)
- Si usas plugin SEO, mantén el meta tag activo
- No compartas el token de verificación públicamente

---

## Referencias
- [Search Console Help](https://support.google.com/webmasters/)
- [Hreflang Best Practices](https://developers.google.com/search/docs/specialty/international/localized-versions)
- [Sitemap Guidelines](https://developers.google.com/search/docs/crawling-indexing/sitemaps/build-sitemap)

---

**Estado**: Documento preparado para ejecución en producción.  
**Última actualización**: 2025-10-23  
**Responsable**: Pepe Capiro
