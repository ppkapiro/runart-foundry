#!/usr/bin/env python3
"""
RunArt Foundry - Link and Publish Translations
Vincula traducciones EN ↔ ES y publica drafts via REST API
"""
import requests
import os
import json
import time
from typing import Dict

# Configuration
WP_BASE_URL = os.getenv('WP_BASE_URL', 'https://staging.runartfoundry.com')
WP_USER = os.getenv('WP_USER', 'runart-admin')
WP_APP_PASSWORD = os.getenv('WP_APP_PASSWORD', 'WNoAVgiGzJiBCfUUrMI8GZnx')
AUTH = (WP_USER, WP_APP_PASSWORD)

# Translation mappings EN → ES (from translation logs)
TRANSLATIONS = {
    # Projects
    3548: 3563,  # Arquidiócesis de La Habana
    3547: 3564,  # Escultura Monumental Oliva
    3546: 3565,  # Carole Feuerman
    3545: 3566,  # Roberto Fabelo
    3544: 3567,  # Monumento Williams Carmona
    
    # Services
    3553: 3568,  # Ediciones Limitadas
    3552: 3569,  # Consultoría Técnica
    3551: 3570,  # Restauración
    3550: 3571,  # Pátinas
    3549: 3572,  # Fundición Artística
    
    # Testimonials
    3556: 3573,  # Carole Feuerman
    3555: 3574,  # Roberto Fabelo
    3554: 3575,  # Williams Carmona
    
    # Posts
    3559: 3576,  # Pátinas en Bronce
    3558: 3577,  # Proceso Cera Perdida
    3557: 3578,  # Guía Aleaciones
}

def get_post_type(post_id: int) -> str:
    """Get post type from post ID"""
    url = f"{WP_BASE_URL}/wp-json/wp/v2/posts/{post_id}"
    
    # Try posts endpoint first
    resp = requests.get(url, auth=AUTH, timeout=30)
    if resp.status_code == 200:
        return 'posts'
    
    # Try other CPTs
    for cpt in ['project', 'service', 'testimonial']:
        url = f"{WP_BASE_URL}/wp-json/wp/v2/{cpt}/{post_id}"
        resp = requests.get(url, auth=AUTH, timeout=30)
        if resp.status_code == 200:
            return cpt
    
    return None

def publish_draft(post_id: int, post_type: str) -> bool:
    """Publish a draft post"""
    endpoint = 'posts' if post_type == 'post' else post_type
    url = f"{WP_BASE_URL}/wp-json/wp/v2/{endpoint}/{post_id}"
    
    data = {"status": "publish"}
    resp = requests.post(url, auth=AUTH, json=data, timeout=30)
    
    return resp.status_code == 200

def link_translation(en_id: int, es_id: int) -> bool:
    """Link EN ↔ ES translation via Polylang meta"""
    # Set language via meta
    for post_id, lang in [(en_id, 'en'), (es_id, 'es')]:
        # Get post type
        post_type = get_post_type(post_id)
        if not post_type:
            print(f"  ✗ Post {post_id} not found")
            return False
        
        endpoint = 'posts' if post_type == 'post' else post_type
        url = f"{WP_BASE_URL}/wp-json/wp/v2/{endpoint}/{post_id}"
        
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
            print(f"  ✗ Failed to update meta for {post_id}: {resp.status_code}")
            return False
    
    return True

def main():
    print(f"[{time.strftime('%H:%M:%S')}] ============================================================")
    print(f"[{time.strftime('%H:%M:%S')}] RunArt Translation Linking & Publishing")
    print(f"[{time.strftime('%H:%M:%S')}] ============================================================")
    
    linked = 0
    published = 0
    errors = []
    
    for en_id, es_id in TRANSLATIONS.items():
        print(f"\n[{time.strftime('%H:%M:%S')}] Processing EN:{en_id} ↔ ES:{es_id}")
        
        # Get post types
        en_type = get_post_type(en_id)
        es_type = get_post_type(es_id)
        
        if not en_type or not es_type:
            error_msg = f"Post not found: EN:{en_id} ({en_type}), ES:{es_id} ({es_type})"
            errors.append(error_msg)
            print(f"  ✗ {error_msg}")
            continue
        
        # Link translation
        if link_translation(en_id, es_id):
            linked += 1
            print(f"  ✓ Linked: EN:{en_id} ↔ ES:{es_id}")
        else:
            errors.append(f"Failed to link EN:{en_id} ↔ ES:{es_id}")
            print(f"  ✗ Failed to link")
            continue
        
        # Publish draft
        if publish_draft(es_id, es_type):
            published += 1
            print(f"  ✓ Published: ES:{es_id}")
        else:
            errors.append(f"Failed to publish ES:{es_id}")
            print(f"  ✗ Failed to publish")
        
        time.sleep(0.5)  # Rate-limit
    
    # Summary
    print(f"\n[{time.strftime('%H:%M:%S')}] ============================================================")
    print(f"[{time.strftime('%H:%M:%S')}] Summary:")
    print(f"  • Translations linked: {linked}/16")
    print(f"  • Drafts published: {published}/16")
    
    if errors:
        print(f"\n[{time.strftime('%H:%M:%S')}] [ERROR] {len(errors)} errors encountered:")
        for error in errors:
            print(f"  - {error}")
        return 1
    
    print(f"\n[{time.strftime('%H:%M:%S')}] ✓ Process completed successfully")
    return 0

if __name__ == '__main__':
    exit(main())
