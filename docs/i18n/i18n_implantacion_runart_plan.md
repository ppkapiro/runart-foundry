# PLAN DE IMPLEMENTACIÓN i18n: RUNART FOUNDRY

**Fecha**: 2025-01-22  
**Scope**: Roadmap técnico completo para implementación i18n en RunArt Foundry  
**Blueprint**: Basado en arquitectura Pepecapiro WordPress Theme  
**Timeline**: 16-24 horas de desarrollo + testing  

---

## RESUMEN EJECUTIVO

**OBJETIVO**: Implementar sistema i18n robusto en RunArt Foundry usando blueprint Pepecapiro  
**ENFOQUE**: Adaptación incremental con Polylang + text domain customizado  
**RESULTADO**: Sitio bilingüe ES/EN con SEO completo y navegación intuitiva  

---

## 1. ARQUITECTURA OBJETIVO

### Tech Stack Final
```yaml
CMS: WordPress 6.0+
i18n Plugin: Polylang  
Text Domain: 'runart-foundry'
Languages: ES (primary), EN (secondary)
URL Structure: ES (root), EN (/en/)
SEO: hreflang + canonical + meta bilingüe
```

### File Structure Post-Implementation
```
wp-content/themes/runart-foundry/
├── languages/
│   ├── runart-foundry.pot          # Translation template
│   ├── runart-foundry-es_ES.po     # Spanish translations  
│   └── runart-foundry-en_US.po     # English translations
├── functions.php                   # i18n core setup
├── header.php                      # Language switcher
├── inc/
│   ├── i18n-setup.php             # i18n configuration
│   ├── hreflang.php               # SEO multilingüe
│   └── navigation.php             # Menús bilingües
└── templates/
    ├── page-contact-es.php        # Contacto español
    └── page-contact-en.php        # Contact English
```

---

## 2. IMPLEMENTATION ROADMAP

### 🎯 FASE 1: FOUNDATION SETUP (6-8 horas)

#### 1.1 Plugin Installation & Configuration
```bash
# Tareas técnicas
- Install Polylang plugin via WP Staging
- Configure languages: ES (español), EN (english)
- Set ES como idioma predeterminado
- Configure URL structure: ES (root), EN (/en/)
- Verify plugin activation + basic functionality
```

**Deliverables**:
- [ ] Polylang installed & active
- [ ] Language configuration saved  
- [ ] URL structure working
- [ ] Admin interface accessible

#### 1.2 Text Domain Implementation
```php
// functions.php addition
function runart_foundry_i18n_setup() {
    load_theme_textdomain('runart-foundry', get_template_directory() . '/languages');
}
add_action('after_setup_theme', 'runart_foundry_i18n_setup');
```

**Deliverables**:
- [ ] Text domain 'runart-foundry' defined
- [ ] load_theme_textdomain() implemented
- [ ] Languages directory created
- [ ] POT file generated

#### 1.3 Core i18n Functions
```php
// inc/i18n-setup.php (new file)
function runart_get_current_language() {
    return function_exists('pll_current_language') ? 
           pll_current_language('slug') : 'es';
}

function runart_is_english() {
    return runart_get_current_language() === 'en';
}

function runart_get_home_url($lang = null) {
    return function_exists('pll_home_url') ? 
           pll_home_url($lang) : home_url('/');
}
```

**Testing**:
- [ ] Functions return correct values
- [ ] Fallbacks work without Polylang
- [ ] No PHP errors in logs

---

### 🎯 FASE 2: NAVIGATION & SWITCHER (4-5 horas)

#### 2.1 Bilingual Menu System
```php
// inc/navigation.php (new file)
function runart_register_bilingual_menus() {
    register_nav_menus([
        'primary-es' => __('Menú Principal (Español)', 'runart-foundry'),
        'primary-en' => __('Primary Menu (English)', 'runart-foundry'),
        'footer-es'  => __('Menú Footer (Español)', 'runart-foundry'),
        'footer-en'  => __('Footer Menu (English)', 'runart-foundry'),
    ]);
}
add_action('init', 'runart_register_bilingual_menus');

function runart_get_current_menu($location) {
    $lang = runart_get_current_language();
    $menu_location = $location . '-' . $lang;
    return has_nav_menu($menu_location) ? $menu_location : $location . '-es';
}
```

#### 2.2 Language Switcher Implementation
```php
// header.php modification
function runart_language_switcher() {
    if (!function_exists('pll_the_languages')) return;
    
    $languages = pll_the_languages([
        'show_flags' => 1,
        'show_names' => 1,
        'hide_if_empty' => 0,
        'force_home' => 0,
        'raw' => 1
    ]);
    
    if (empty($languages)) return;
    
    echo '<div class="language-switcher">';
    foreach ($languages as $lang) {
        $class = $lang['current_lang'] ? 'current' : '';
        echo sprintf(
            '<a href="%s" class="lang-link %s" hreflang="%s">%s %s</a>',
            esc_url($lang['url']),
            esc_attr($class),
            esc_attr($lang['slug']),
            $lang['flag'],
            esc_html($lang['name'])
        );
    }
    echo '</div>';
}
```

**Deliverables**:
- [ ] Menús separados ES/EN creados
- [ ] Language switcher funcional en header
- [ ] CSS para styling del switcher
- [ ] Responsive design para móviles

---

### 🎯 FASE 3: SEO MULTILINGÜE (5-6 horas)

#### 3.1 Hreflang Implementation
```php
// inc/hreflang.php (new file)
function runart_add_hreflang_tags() {
    if (!function_exists('pll_the_languages')) return;
    
    $languages = pll_the_languages(['raw' => 1]);
    if (empty($languages)) return;
    
    // Current page hreflangs
    foreach ($languages as $code => $data) {
        if (!empty($data['url'])) {
            printf(
                '<link rel="alternate" hreflang="%s" href="%s" />' . "\n",
                esc_attr($code),
                esc_url($data['url'])
            );
        }
    }
    
    // x-default to Spanish (primary language)
    $default_url = function_exists('pll_home_url') ? pll_home_url('es') : home_url('/');
    printf(
        '<link rel="alternate" hreflang="x-default" href="%s" />' . "\n",
        esc_url($default_url)
    );
}
add_action('wp_head', 'runart_add_hreflang_tags');
```

#### 3.2 Canonical URLs & Meta Tags
```php
function runart_multilingual_seo_meta() {
    $lang = runart_get_current_language();
    $is_english = runart_is_english();
    
    // Custom meta per language
    if (is_front_page()) {
        $title = $is_english ? 
                 'Art & Automation Without Drama' : 
                 'Arte y Automatización Sin Drama';
        $description = $is_english ?
                      'We create digital experiences and streamline processes.' :
                      'Creamos experiencias digitales y simplificamos procesos.';
    } else {
        $title = wp_get_document_title();
        $description = get_bloginfo('description');
    }
    
    // Open Graph + Twitter Cards
    echo '<meta property="og:title" content="' . esc_attr($title) . '" />' . "\n";
    echo '<meta property="og:description" content="' . esc_attr($description) . '" />' . "\n";
    echo '<meta property="og:locale" content="' . ($is_english ? 'en_US' : 'es_ES') . '" />' . "\n";
    
    // Canonical
    $canonical = function_exists('pll_canonical_url') ? pll_canonical_url() : get_permalink();
    echo '<link rel="canonical" href="' . esc_url($canonical) . '" />' . "\n";
}
add_action('wp_head', 'runart_multilingual_seo_meta');
```

#### 3.3 Sitemap Configuration
```php
// Ensure sitemaps include all languages
function runart_multilingual_sitemap_support() {
    // If using Yoast/RankMath, verify Polylang integration
    // Fallback: custom sitemap generation if needed
}
```

**Deliverables**:
- [ ] hreflang tags en todas las páginas
- [ ] Canonical URLs correctos
- [ ] Meta tags bilingües
- [ ] Sitemap con ambos idiomas

---

### 🎯 FASE 4: CONTENT LOCALIZATION (3-4 horas)

#### 4.1 String Localization Audit
```bash
# Identify hardcoded strings in templates
grep -r "Contact\|About\|Home\|Services" wp-content/themes/runart-foundry/
grep -r "Contacto\|Acerca\|Inicio\|Servicios" wp-content/themes/runart-foundry/

# Replace with localized versions
# "Contact" → __('Contact', 'runart-foundry')
# "About" → __('About', 'runart-foundry')
```

#### 4.2 Template Customization
```php
// templates/page-contact-es.php
get_header(); ?>
<div class="contact-page contact-es">
    <h1><?php echo __('Contacto', 'runart-foundry'); ?></h1>
    <p><?php echo __('Envíanos un mensaje y te responderemos pronto.', 'runart-foundry'); ?></p>
    <!-- Spanish-specific contact form -->
</div>
<?php get_footer();

// templates/page-contact-en.php  
get_header(); ?>
<div class="contact-page contact-en">
    <h1><?php echo __('Contact', 'runart-foundry'); ?></h1>
    <p><?php echo __('Send us a message and we\'ll get back to you soon.', 'runart-foundry'); ?></p>
    <!-- English-specific contact form -->
</div>
<?php get_footer();
```

#### 4.3 POT File Generation & Translations
```bash
# Generate POT file
wp i18n make-pot wp-content/themes/runart-foundry wp-content/themes/runart-foundry/languages/runart-foundry.pot

# Create language files
cp runart-foundry.pot runart-foundry-es_ES.po
cp runart-foundry.pot runart-foundry-en_US.po

# Manual translation or use PoEdit
```

**Deliverables**:
- [ ] Todos los strings hardcoded localizados
- [ ] Templates específicos para contenido crítico
- [ ] POT file actualizado
- [ ] Traducciones ES/EN completadas

---

### 🎯 FASE 5: TESTING & OPTIMIZATION (4-5 horas)

#### 5.1 Functional Testing
```bash
Testing Checklist:
- [ ] Language switcher cambia idioma correctamente
- [ ] URLs muestran estructura correcta (/en/)
- [ ] Menús aparecen en idioma correspondiente
- [ ] Contenido se muestra en idioma seleccionado
- [ ] Fallbacks funcionan sin Polylang
- [ ] 404 pages manejan idiomas correctamente
```

#### 5.2 SEO Validation
```bash
# Check hreflang implementation
curl -I https://staging.runartfoundry.com/ | grep hreflang
curl -I https://staging.runartfoundry.com/en/ | grep hreflang

# Validate sitemaps
wget https://staging.runartfoundry.com/sitemap.xml
xmllint --format sitemap.xml | grep -i "es\|en"

# Test search indexing
robots.txt check + search console submission
```

#### 5.3 Performance Testing
```bash
# Page speed both languages
lighthouse https://staging.runartfoundry.com/      # ES
lighthouse https://staging.runartfoundry.com/en/   # EN

# Mobile responsive testing
# Cross-browser compatibility (Chrome, Firefox, Safari)
```

#### 5.4 User Acceptance Testing
```bash
User Journey Testing:
- [ ] Visitor lands on ES (default)
- [ ] Switches to EN via flag/switcher
- [ ] Navigates between pages maintaining language
- [ ] Submits forms in correct language
- [ ] Search results respect language selection
```

**Deliverables**:
- [ ] Functional test suite passed
- [ ] SEO validation complete
- [ ] Performance benchmarks met
- [ ] UAT sign-off obtained

---

## 3. DEPLOYMENT STRATEGY

### STAGING IMPLEMENTATION
```bash
# Phase 1: WP Staging Environment
1. Install Polylang in staging
2. Configure basic ES/EN setup
3. Test core functionality
4. Validate URL structure

# Phase 2: Theme Modifications
1. Implement text domain changes
2. Add language switcher
3. Setup bilingual menus
4. Test navigation flow

# Phase 3: SEO Implementation
1. Add hreflang tags
2. Implement canonical URLs
3. Test meta tag generation
4. Validate sitemap functionality

# Phase 4: Content & Testing
1. Localize hardcoded strings
2. Create bilingual content
3. Comprehensive testing
4. Performance optimization
```

### PRODUCTION DEPLOYMENT
```bash
# Pre-deployment
- [ ] Full staging testing complete
- [ ] Backup production site
- [ ] DNS/CDN configuration ready
- [ ] Rollback plan prepared

# Deployment
- [ ] Deploy code changes
- [ ] Install/configure Polylang
- [ ] Import staging configuration
- [ ] Verify live functionality

# Post-deployment
- [ ] Monitor error logs
- [ ] Test live URLs
- [ ] Submit updated sitemaps
- [ ] Monitor search rankings
```

---

## 4. RESOURCE ALLOCATION

### HUMAN RESOURCES
```yaml
Developer (WordPress/PHP): 16-20h
- Core implementation + testing

Frontend Developer: 4-6h  
- Language switcher styling + responsive

SEO Specialist: 2-3h
- hreflang validation + optimization

Translator: 3-4h
- Spanish/English content review

QA Tester: 4-5h
- Cross-browser + device testing

Project Manager: 2-3h
- Coordination + timeline management

TOTAL: 31-41 hours team effort
```

### TECHNICAL RESOURCES
```yaml
Staging Environment: WP Staging Lite (✅ available)
Polylang Plugin: ~$99/year (Pro version recommended)
Translation Tools: PoEdit (free) or Lokalise (paid)
Testing Tools: Lighthouse, GTmetrix, BrowserStack
Monitoring: Google Search Console, Analytics
```

---

## 5. RISK MITIGATION

### TECHNICAL RISKS
```yaml
Risk: Polylang conflicts with existing plugins
Mitigation: Test in staging, maintain plugin compatibility matrix

Risk: URL structure changes affect SEO
Mitigation: 301 redirects + search console notifications

Risk: Performance impact from language switching
Mitigation: Caching optimization + CDN configuration  

Risk: Translation quality issues
Mitigation: Native speaker review + professional translation
```

### BUSINESS RISKS
```yaml
Risk: User confusion with language switching
Mitigation: Clear UX design + user testing

Risk: Content maintenance overhead
Mitigation: Translation workflow + CMS training

Risk: Search ranking impact during transition
Mitigation: Gradual rollout + SEO monitoring
```

---

## 6. SUCCESS METRICS & KPIs

### TECHNICAL METRICS
```yaml
Page Load Speed: <2s both languages
SEO Score: >90 (Lighthouse)
Mobile Score: >85 (PageSpeed Insights)
Error Rate: <0.1% language switching
Uptime: >99.9% post-deployment
```

### BUSINESS METRICS
```yaml
User Engagement: Language switching rate >15%
Content Consumption: Bounce rate <5% increase
Search Performance: No ranking drops >10%
User Satisfaction: Language experience rating >4.5/5
```

### MAINTENANCE METRICS
```yaml
Translation Update Time: <24h for critical content
Plugin Compatibility: 100% major updates
Support Tickets: Language-related <5% total
Content Sync: ES/EN content parity >95%
```

---

## 7. POST-IMPLEMENTATION ROADMAP

### SHORT-TERM (1-3 months)
- [ ] Monitor SEO performance
- [ ] Optimize translation workflow  
- [ ] User behavior analysis
- [ ] Performance fine-tuning

### MEDIUM-TERM (3-6 months)
- [ ] Content strategy expansion
- [ ] Additional language consideration (FR, DE)
- [ ] Advanced SEO optimization
- [ ] A/B testing language variations

### LONG-TERM (6-12 months)
- [ ] Full content localization audit
- [ ] International market expansion
- [ ] Advanced i18n features (RTL support)
- [ ] Automated translation integration

---

## 8. MAINTENANCE & SUPPORT

### ONGOING RESPONSIBILITIES
```yaml
Content Management:
- Translation updates
- New content localization
- Consistency audits

Technical Maintenance:
- Plugin updates
- Performance monitoring  
- SEO tracking
- Backup verification

User Support:
- Language switching issues
- Content feedback
- Accessibility compliance
```

### TRAINING REQUIREMENTS
```yaml
Content Team:
- Polylang admin interface
- Translation workflow
- SEO best practices

Development Team:
- i18n code patterns
- Polylang APIs
- Debugging techniques

Marketing Team:
- Multilingual analytics
- SEO monitoring
- User journey optimization
```

---

## 9. LAUNCH CHECKLIST

### PRE-LAUNCH ✅
- [ ] All code reviewed and tested
- [ ] Staging environment fully functional
- [ ] Backup procedures verified
- [ ] Team training completed
- [ ] Documentation finalized

### LAUNCH DAY 🚀
- [ ] Code deployment executed
- [ ] Plugin configuration complete
- [ ] DNS/CDN settings updated
- [ ] Functionality verified live
- [ ] Monitoring enabled

### POST-LAUNCH 📊
- [ ] Performance metrics collected
- [ ] User feedback gathered
- [ ] SEO impact assessed
- [ ] Issues resolved promptly
- [ ] Success metrics reported

---

*Implementation plan ready for execution*  
*Part of ORQUESTACIÓN COPAYLO - i18n Discovery & Portability Planning*  

**NEXT ACTION**: Create feature branch `feature/i18n-port` and begin Phase 1 implementation