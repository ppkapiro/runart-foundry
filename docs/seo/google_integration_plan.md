# Plan de Integración con Google Search Console (Producción)

Estado: Preparado (no ejecutar en staging)

## 1) Verificación de Propiedad
- Método recomendado: Archivo HTML en raíz del sitio productivo
- Alternativas: DNS TXT para dominio raíz o etiqueta HTML en `<head>`

## 2) Sitemaps Bilingües
- URL esperada: `https://www.runartfoundry.com/sitemap_index.xml`
- Debe incluir secciones por idioma (EN/ES)

## 3) Hreflang y Meta Tags
- Verificar `hreflang` EN/ES + `x-default`
- OG tags por idioma (`og:locale`, `og:title`, `og:description`)

## 4) Pasos
1. Activar plugin SEO en producción (Yoast/RankMath) y generar sitemaps
2. Subir archivo de verificación HTML de GSC
3. Verificar propiedad en GSC
4. Enviar `sitemap_index.xml`
5. Revisar Cobertura, Indexación, Mejoras, Internacionalización

## 5) Post-Despliegue
- Monitorizar Search Console semanalmente
- Resolver errores de internacionalización y cobertura
