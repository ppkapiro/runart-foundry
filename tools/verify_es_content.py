#!/usr/bin/env python3
"""
Verify Spanish content is properly published and linked
"""
import requests
import os

WP_BASE_URL = os.getenv('WP_BASE_URL', 'https://staging.runartfoundry.com')
WP_USER = os.getenv('WP_USER', 'runart-admin')
WP_APP_PASSWORD = os.getenv('WP_APP_PASSWORD', 'WNoAVgiGzJiBCfUUrMI8GZnx')
AUTH = (WP_USER, WP_APP_PASSWORD)

def verify_cpt_es_content(cpt: str):
    """Verify ES content for a specific CPT"""
    endpoint = 'posts' if cpt == 'post' else cpt
    url = f"{WP_BASE_URL}/wp-json/wp/v2/{endpoint}?lang=es&status=publish&per_page=100"
    
    resp = requests.get(url, auth=AUTH, timeout=30)
    if resp.status_code != 200:
        print(f"✗ Failed to fetch {cpt} (ES): {resp.status_code}")
        return []
    
    posts = resp.json()
    print(f"\n{cpt.upper()} (ES): {len(posts)} published")
    
    for post in posts:
        title = post['title']['rendered']
        link = post['link']
        print(f"  • {title}")
        print(f"    → {link}")
    
    return posts

def purge_cache():
    """Purge WordPress cache via REST API"""
    # Trigger cache flush via custom endpoint or transient delete
    print("Purging cache...")
    # Note: REST API doesn't have direct cache flush, would need plugin or custom endpoint
    print("  ⚠ Manual cache purge needed via wp-cli or browser")

def main():
    print("=" * 60)
    print("Spanish Content Verification")
    print("=" * 60)
    
    cpts = ['project', 'service', 'testimonial', 'post']
    total_es = 0
    
    for cpt in cpts:
        posts = verify_cpt_es_content(cpt)
        total_es += len(posts)
    
    print("\n" + "=" * 60)
    print(f"Total ES content published: {total_es}/16")
    
    if total_es < 16:
        print("\n⚠ WARNING: Not all ES content is published!")
        print("Expected: 16 (5 projects + 5 services + 3 testimonials + 3 posts)")
    else:
        print("\n✓ All ES content published successfully!")
    
    print("\nNext steps:")
    print("  1. Clear browser cache (Ctrl+Shift+R)")
    print("  2. Test archive URLs:")
    print("     - /es/proyectos/")
    print("     - /es/servicios/")
    print("     - /es/testimonios/")
    print("     - /es/blog/")

if __name__ == '__main__':
    main()
