# PR: Integración i18n/SEO — Checklist

## Resumen
- Objetivo: _Descripción breve_
- Ámbito: _i18n / SEO / Workflows / Scripts / Docs_

## Checklist de Calidad

### General
- [ ] Sin secretos en código (keys/tokens/passwords)
- [ ] Docs actualizados (si aplica)
- [ ] CI verde (build/lint/tests)

### i18n
- [ ] EN/ES consistentes (slugs, menús, páginas)
- [ ] 0 hardcodeos de dominio (usar home_url / variables)
- [ ] Auto-traducción: provider seleccionado (TRANSLATION_PROVIDER)
- [ ] Logs JSON: provider_selected, model

### SEO
- [ ] Hreflang en, es, x-default correctos
- [ ] OG locale en_US ↔ es_ES bidireccional
- [ ] html[lang] correcto por idioma
- [ ] Canonical self-reference por idioma
- [ ] Language switcher con aria-current

### Workflows
- [ ] Variables: APP_ENV, WP_BASE_URL
- [ ] Secrets: referenciados (no en código)
- [ ] Auto-merge: añadir label `auto-merge` si procede

## Evidencias
- URLs/Capturas: 
- Logs/artifacts: 

## Rollback (rápido)
- _Describe en 1-2 líneas cómo revertir_
