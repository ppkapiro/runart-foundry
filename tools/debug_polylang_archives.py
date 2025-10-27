#!/usr/bin/env python3
"""
Debug Polylang archive URLs and rewrite rules
"""
import requests
import os
import json

WP_BASE_URL = os.getenv('WP_BASE_URL', 'https://staging.runartfoundry.com')
WP_USER = os.getenv('WP_USER', 'runart-admin')
WP_APP_PASSWORD = os.getenv('WP_APP_PASSWORD', 'WNoAVgiGzJiBCfUUrMI8GZnx')
AUTH = (WP_USER, WP_APP_PASSWORD)

def check_polylang_config():
    """Check Polylang configuration via options"""
    print("=" * 60)
    print("Polylang Configuration Check")
    print("=" * 60)
    
    # Check if archives are properly configured
    archives = {
        'project': {'en': '/projects/', 'es': '/es/proyectos/'},
        'service': {'en': '/services/', 'es': '/es/servicios/'},
        'testimonial': {'en': '/testimonials/', 'es': '/es/testimonios/'},
    }
    
    for cpt, urls in archives.items():
        print(f"\n{cpt.upper()} Archives:")
        for lang, url in urls.items():
            full_url = f"{WP_BASE_URL}{url}"
            resp = requests.get(full_url, timeout=10)
            
            # Check if we get 200
            if resp.status_code == 200:
                # Check if we actually have content
                if "Nothing Found" in resp.text:
                    print(f"  [{lang}] {url} → ❌ Returns 200 but shows 'Nothing Found'")
                else:
                    print(f"  [{lang}] {url} → ✅ Working")
            else:
                print(f"  [{lang}] {url} → ❌ Status {resp.status_code}")

def check_posts_in_db():
    """Check if posts actually exist in database with correct language"""
    print("\n" + "=" * 60)
    print("Database Post Check")
    print("=" * 60)
    
    cpts = ['project', 'service', 'testimonial']
    
    for cpt in cpts:
        print(f"\n{cpt.upper()}:")
        for lang in ['en', 'es']:
            endpoint = cpt
            url = f"{WP_BASE_URL}/wp-json/wp/v2/{endpoint}"
            params = {'lang': lang, 'status': 'publish', 'per_page': 100}
            
            resp = requests.get(url, auth=AUTH, params=params, timeout=30)
            if resp.status_code == 200:
                posts = resp.json()
                print(f"  [{lang}] {len(posts)} posts found in database")
                
                # Show first 3 titles
                for i, post in enumerate(posts[:3]):
                    print(f"       {i+1}. {post['title']['rendered'][:50]}")
            else:
                print(f"  [{lang}] API error: {resp.status_code}")

def check_rewrite_rules():
    """Check if rewrite rules are properly set"""
    print("\n" + "=" * 60)
    print("Rewrite Rules Check")
    print("=" * 60)
    
    # Try to get rewrite rules via REST API or direct check
    print("\nNote: Rewrite rules require wp-cli access to debug")
    print("Expected rules:")
    print("  en/projects/ → archive-project.php")
    print("  es/proyectos/ → archive-project.php (with lang=es)")
    print("  en/services/ → archive-service.php")
    print("  es/servicios/ → archive-service.php (with lang=es)")

if __name__ == '__main__':
    check_polylang_config()
    check_posts_in_db()
    check_rewrite_rules()
    
    print("\n" + "=" * 60)
    print("Recommendations:")
    print("=" * 60)
    print("1. If posts exist in DB but archives show 'Nothing Found':")
    print("   → Issue is with query or rewrite rules")
    print("2. Run: wp rewrite flush --hard --allow-root")
    print("3. Check Polylang > Settings > Custom Post Types")
    print("4. Verify archive slugs are correct")
    print("5. Clear ALL caches including browser")
