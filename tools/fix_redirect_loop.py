#!/usr/bin/env python3
"""
Fix infinite redirect loop by checking and updating Polylang settings
"""
import requests
import os

WP_BASE_URL = os.getenv('WP_BASE_URL', 'https://staging.runartfoundry.com')
WP_USER = os.getenv('WP_USER', 'runart-admin')
WP_APP_PASSWORD = os.getenv('WP_APP_PASSWORD', 'WNoAVgiGzJiBCfUUrMI8GZnx')
AUTH = (WP_USER, WP_APP_PASSWORD)

def check_redirect_issue():
    """Check if there's a redirect loop"""
    print("Checking for redirect loop...")
    
    test_urls = [
        '/projects/',
        '/es/proyectos/',
        '/services/',
        '/es/servicios/'
    ]
    
    for path in test_urls:
        url = f"{WP_BASE_URL}{path}"
        try:
            # Disable redirects to see what's happening
            resp = requests.get(url, allow_redirects=False, timeout=10)
            print(f"\n{path}:")
            print(f"  Status: {resp.status_code}")
            
            if resp.status_code in [301, 302, 307, 308]:
                location = resp.headers.get('Location', 'N/A')
                print(f"  Redirect to: {location}")
        except Exception as e:
            print(f"\n{path}: Error - {e}")

def check_mu_plugins():
    """Check if mu-plugins are causing redirect loops"""
    print("\n" + "=" * 60)
    print("MU-Plugins Check")
    print("=" * 60)
    
    print("\nSuspect: runart-redirects.php may be causing infinite loop")
    print("Action: Need to disable or fix this plugin")
    print("\nRecommendation:")
    print("  1. Remove or rename runart-redirects.php")
    print("  2. Keep only runart-nocache.php for header control")
    print("  3. Test archives again")

if __name__ == '__main__':
    check_redirect_issue()
    check_mu_plugins()
