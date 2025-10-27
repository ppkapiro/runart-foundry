#!/usr/bin/env python3
"""
RunArt Foundry - Link Pages Translations
Vincula traducciones EN ↔ ES para páginas principales
"""
import requests
import os
import time

# Configuration
WP_BASE_URL = os.getenv('WP_BASE_URL', 'https://staging.runartfoundry.com')
WP_USER = os.getenv('WP_USER', 'runart-admin')
WP_APP_PASSWORD = os.getenv('WP_APP_PASSWORD', 'WNoAVgiGzJiBCfUUrMI8GZnx')
AUTH = (WP_USER, WP_APP_PASSWORD)

# Translation mappings EN → ES
PAGES = {
    3512: 3517,  # Home → Inicio
    3513: 3518,  # About → Sobre nosotros
    3514: 3519,  # Services → Servicios
    # 3515: Contact (needs ES translation)
}

def link_pages(en_id: int, es_id: int) -> bool:
    """Link EN ↔ ES page translation via Polylang meta"""
    print(f"Linking {en_id} (EN) ↔ {es_id} (ES)...")
    
    for post_id, lang in [(en_id, 'en'), (es_id, 'es')]:
        url = f"{WP_BASE_URL}/wp-json/wp/v2/pages/{post_id}"
        
        # Update with Polylang meta
        data = {
            "meta": {
                "_pll_lang": lang,
                "_pll_translations_en": en_id,
                "_pll_translations_es": es_id
            }
        }
        
        resp = requests.post(url, auth=AUTH, json=data, timeout=30)
        if resp.status_code != 200:
            print(f"  ✗ Failed to update meta for {post_id}: {resp.status_code} - {resp.text}")
            return False
    
    print(f"  ✓ Linked successfully")
    return True

def main():
    print(f"🔗 Linking {len(PAGES)} page pairs...\n")
    
    success = 0
    failed = 0
    
    for en_id, es_id in PAGES.items():
        if link_pages(en_id, es_id):
            success += 1
        else:
            failed += 1
        time.sleep(0.5)
    
    print(f"\n✅ Summary: {success} linked, {failed} failed")

if __name__ == '__main__':
    main()
