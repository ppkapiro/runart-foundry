# RunArt Base Theme

Tema base bilingüe (EN predeterminado, ES alternativo) para RunArt Foundry con soporte Polylang y SEO dual.

## Características
- Text Domain: `runart-base`
- Soporte Polylang: language switcher en header (`pll_the_languages`) si está disponible
- Menús: `primary`, `footer`
- x-default `hreflang` añadido a `<head>` (EN predeterminado)

## Estructura
```
runart-base/
  ├── style.css
  ├── functions.php
  ├── header.php
  ├── footer.php
  ├── index.php
  └── languages/
```

## Activación
1. Subir carpeta `runart-base` a `wp-content/themes/` del staging
2. En wp-admin → Apariencia → Temas → Activar "RunArt Base"
3. Apariencia → Menús → Asignar menús por idioma (Polylang)

## i18n
- `load_theme_textdomain('runart-base', get_template_directory() . '/languages')`
- Generar POT y PO/MO con WP-CLI:

```bash
wp i18n make-pot wp-content/themes/runart-base wp-content/themes/runart-base/languages/runart-base.pot
```

