#!/usr/bin/env python3
"""
RunArt Foundry - Auto-Translate CPT Content (EN → ES)
Traduce Custom Post Types: project, service, testimonial, post
"""
import os
import json
import time
import requests
import sys
from datetime import datetime
from typing import Optional, Dict, List

# ===================================================================
# CONFIGURACIÓN
# ===================================================================
APP_ENV = os.getenv('APP_ENV', 'staging')
WP_BASE_URL = os.getenv('WP_BASE_URL', 'https://staging.runartfoundry.com')
WP_USER = os.getenv('WP_USER', 'admin')
WP_APP_PASSWORD = os.getenv('WP_APP_PASSWORD', '')

# OpenAI
OPENAI_API_KEY = os.getenv('OPENAI_API_KEY', '')
OPENAI_MODEL = os.getenv('OPENAI_MODEL', 'gpt-4o-mini')
OPENAI_TEMPERATURE = float(os.getenv('OPENAI_TEMPERATURE', '0.3'))

# Control
DRY_RUN = os.getenv('DRY_RUN', 'false').lower() == 'true'
BATCH_SIZE = int(os.getenv('TRANSLATION_BATCH_SIZE', '20'))

# Custom Post Types a traducir
CPT_TYPES = ['project', 'service', 'testimonial', 'post']

# Auth
auth = (WP_USER, WP_APP_PASSWORD) if WP_USER and WP_APP_PASSWORD else None

# Logging
LOG_DIR = os.path.join(os.path.dirname(__file__), '..', 'docs', 'ops', 'logs')
os.makedirs(LOG_DIR, exist_ok=True)
TIMESTAMP = datetime.utcnow().strftime("%Y%m%dT%H%M%SZ")
LOG_PATH = os.path.join(LOG_DIR, f'translate_cpt_{TIMESTAMP}.log')
LOG_JSON = os.path.join(LOG_DIR, f'translate_cpt_{TIMESTAMP}.json')

log_data = {
    "timestamp": TIMESTAMP,
    "environment": APP_ENV,
    "base_url": WP_BASE_URL,
    "model": OPENAI_MODEL,
    "dry_run": DRY_RUN,
    "batch_size": BATCH_SIZE,
    "translated": [],
    "errors": [],
    "stats": {}
}

def log(msg: str):
    line = f"[{datetime.utcnow().strftime('%H:%M:%S')}] {msg}"
    with open(LOG_PATH, 'a') as f:
        f.write(line + '\n')
    print(line)

def save_json():
    with open(LOG_JSON, 'w') as f:
        json.dump(log_data, f, indent=2, ensure_ascii=False)

# ===================================================================
# TRADUCTOR OPENAI
# ===================================================================
def translate_openai(text: str, context: str = '') -> Optional[str]:
    """Traduce texto EN→ES con OpenAI."""
    if DRY_RUN:
        log(f"  [DRY-RUN] Would translate: {text[:80]}...")
        return f"[TRADUCIDO] {text}"
    
    if not OPENAI_API_KEY:
        log("  [ERROR] No OPENAI_API_KEY configured")
        return None
    
    endpoint = "https://api.openai.com/v1/chat/completions"
    headers = {
        "Authorization": f"Bearer {OPENAI_API_KEY}",
        "Content-Type": "application/json"
    }
    
    system_prompt = (
        "You are a professional translator specializing in artistic bronze casting and metalwork. "
        "Translate the following text from English to Spanish accurately, preserving HTML tags, "
        "formatting, and technical terminology. Return ONLY the translated text without explanations."
    )
    
    user_prompt = f"Context: {context}\n\nTranslate this text from English to Spanish:\n\n{text}"
    
    data = {
        "model": OPENAI_MODEL,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt}
        ],
        "temperature": OPENAI_TEMPERATURE,
        "max_tokens": max(len(text) * 2, 1000)
    }
    
    for attempt in range(3):
        try:
            resp = requests.post(endpoint, headers=headers, json=data, timeout=60)
            if resp.status_code == 200:
                result = resp.json()
                translated = result['choices'][0]['message']['content'].strip()
                tokens = result.get('usage', {}).get('total_tokens', 0)
                log(f"  ✓ Translated ({tokens} tokens)")
                return translated
            elif resp.status_code == 429:
                wait = 2 ** attempt
                log(f"  ⏳ Rate limit, waiting {wait}s...")
                time.sleep(wait)
            else:
                log(f"  ✗ OpenAI error {resp.status_code}: {resp.text[:200]}")
                return None
        except Exception as e:
            log(f"  ✗ Exception: {e}")
            time.sleep(2 ** attempt)
    
    return None

# ===================================================================
# LÓGICA PRINCIPAL
# ===================================================================
def main():
    log("="*60)
    log("RunArt CPT Translation - EN → ES")
    log("="*60)
    log(f"Environment: {APP_ENV}")
    log(f"Base URL: {WP_BASE_URL}")
    log(f"Model: {OPENAI_MODEL}")
    log(f"Dry-run: {DRY_RUN}")
    log(f"Batch size: {BATCH_SIZE}")
    log("")
    
    if not auth:
        log("[ERROR] WP credentials missing")
        log_data["errors"].append("WP credentials missing")
        save_json()
        return 1
    
    total_translated = 0
    
    for cpt in CPT_TYPES:
        log(f"Processing CPT: {cpt}")
        log("-" * 60)
        
        # Obtener posts EN sin traducción ES
        # Para CPTs, el endpoint es singular (project, service, testimonial) pero post usa posts
        endpoint = "posts" if cpt == "post" else cpt
        url = f"{WP_BASE_URL}/wp-json/wp/v2/{endpoint}?per_page={BATCH_SIZE}&lang=en"
        try:
            resp = requests.get(url, auth=auth, timeout=30)
            if resp.status_code != 200:
                log(f"  [ERROR] Failed to fetch {cpt}s: {resp.status_code}")
                continue
            
            posts = resp.json()
            log(f"  Found {len(posts)} {cpt}s in English")
            
            for post in posts:
                post_id = post['id']
                title_en = post.get('title', {}).get('rendered', 'Untitled')
                content_en = post.get('content', {}).get('rendered', '')
                
                # Verificar si ya tiene traducción ES
                translations = post.get('translations', {})
                if translations and 'es' in translations:
                    log(f"  [SKIP] {post_id} '{title_en}' - already has ES translation")
                    continue
                
                log(f"  Translating {post_id}: {title_en}")
                
                # Traducir título
                title_es = translate_openai(title_en, context=f"{cpt} title")
                if not title_es:
                    log(f"    [ERROR] Failed to translate title")
                    log_data["errors"].append(f"{cpt} {post_id}: title translation failed")
                    continue
                
                # Traducir contenido (limitado a 8000 chars para rate limit)
                content_es = ''
                if content_en:
                    content_sample = content_en[:8000]
                    content_es = translate_openai(content_sample, context=f"{cpt} content")
                    if not content_es:
                        log(f"    [ERROR] Failed to translate content")
                        content_es = content_sample  # Fallback al original
                
                # Crear post ES
                if DRY_RUN:
                    log(f"    [DRY-RUN] Would create ES {cpt}: {title_es}")
                else:
                    new_post_data = {
                        "title": title_es,
                        "content": content_es,
                        "status": "draft",
                        "lang": "es"
                    }
                    
                    try:
                        create_endpoint = "posts" if cpt == "post" else cpt
                        create_url = f"{WP_BASE_URL}/wp-json/wp/v2/{create_endpoint}"
                        create_resp = requests.post(create_url, auth=auth, json=new_post_data, timeout=30)
                        
                        if create_resp.status_code in (200, 201):
                            new_post = create_resp.json()
                            new_id = new_post['id']
                            log(f"    ✓ Created ES {cpt} {new_id}: {title_es}")
                            
                            log_data["translated"].append({
                                "type": cpt,
                                "source_id": post_id,
                                "target_id": new_id,
                                "title_en": title_en,
                                "title_es": title_es
                            })
                            total_translated += 1
                        else:
                            log(f"    [ERROR] Create failed: {create_resp.status_code}")
                            log_data["errors"].append(f"{cpt} {post_id}: create failed {create_resp.status_code}")
                    except Exception as e:
                        log(f"    [ERROR] Exception: {e}")
                        log_data["errors"].append(f"{cpt} {post_id}: {str(e)}")
                
                # Rate limit entre posts
                time.sleep(1)
            
            log("")
        
        except Exception as e:
            log(f"  [ERROR] Exception processing {cpt}: {e}")
            log_data["errors"].append(f"{cpt}: {str(e)}")
    
    log("="*60)
    log(f"Translation completed: {total_translated} items translated")
    log(f"Logs: {LOG_PATH}")
    log(f"JSON: {LOG_JSON}")
    
    log_data["stats"]["total_translated"] = total_translated
    log_data["stats"]["total_errors"] = len(log_data["errors"])
    save_json()
    
    return 0

if __name__ == '__main__':
    sys.exit(main())
