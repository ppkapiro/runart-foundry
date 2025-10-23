#!/usr/bin/env python3
"""
RunArt Foundry - Auto-Translate Content (EN → ES)
Soporta DeepL y OpenAI con selección automática, parametrizado por entorno, dry-run por defecto.
"""
import os
import json
import time
import requests
import sys
from datetime import datetime
from typing import Optional

# ===================================================================
# CONFIGURACIÓN POR ENTORNO
# ===================================================================
APP_ENV = os.getenv('APP_ENV', 'staging')  # staging | production
WP_BASE_URL = os.getenv('WP_BASE_URL', os.getenv('BASE_URL', ''))
WP_USER = os.getenv('WP_USER')
WP_APP_PASSWORD = os.getenv('WP_APP_PASSWORD')

# Proveedor de traducción: deepl | openai | auto
TRANSLATION_PROVIDER = os.getenv('TRANSLATION_PROVIDER', 'deepl').lower()
DEEPL_API_KEY = os.getenv('DEEPL_API_KEY', os.getenv('TRANSLATION_API_KEY', ''))
OPENAI_API_KEY = os.getenv('OPENAI_API_KEY', '')
OPENAI_MODEL = os.getenv('OPENAI_MODEL', 'gpt-4o-mini')
OPENAI_TEMPERATURE = float(os.getenv('OPENAI_TEMPERATURE', '0.3'))

# Flags de control
AUTO_TRANSLATE_ENABLED = os.getenv('AUTO_TRANSLATE_ENABLED', 'false').lower() == 'true'
DRY_RUN = os.getenv('DRY_RUN', 'true').lower() == 'true'
TRANSLATION_BATCH_SIZE = int(os.getenv('TRANSLATION_BATCH_SIZE', '3'))

# Logging
LOG_DIR = os.path.join(os.path.dirname(__file__), '..', 'docs', 'ops', 'logs')
os.makedirs(LOG_DIR, exist_ok=True)
TIMESTAMP = datetime.utcnow().strftime("%Y%m%dT%H%M%SZ")
LOG_PATH_TXT = os.path.join(LOG_DIR, f'auto_translate_{TIMESTAMP}.log')
LOG_PATH_JSON = os.path.join(LOG_DIR, f'auto_translate_{TIMESTAMP}.json')

# Estructuras de log
log_data = {
    "timestamp": TIMESTAMP,
    "environment": APP_ENV,
    "base_url": WP_BASE_URL,
    "provider": TRANSLATION_PROVIDER,
    "provider_selected": None,  # El proveedor realmente usado
    "model": OPENAI_MODEL if TRANSLATION_PROVIDER in ('openai', 'auto') else None,
    "enabled": AUTO_TRANSLATE_ENABLED,
    "dry_run": DRY_RUN,
    "batch_size": TRANSLATION_BATCH_SIZE,
    "candidates": [],
    "created": [],
    "errors": [],
    "stats": {}
}

def log(msg: str, level: str = "INFO"):
    """Log a texto plano y stdout."""
    line = f"[{level}] {msg}"
    with open(LOG_PATH_TXT, 'a') as f:
        f.write(line + '\n')
    print(line)

def save_json_log():
    """Guarda log estructurado en JSON."""
    with open(LOG_PATH_JSON, 'w') as f:
        json.dump(log_data, f, indent=2, ensure_ascii=False)
    log(f"JSON log saved: {LOG_PATH_JSON}")

# ===================================================================
# VALIDACIONES INICIALES
# ===================================================================
if not WP_BASE_URL:
    log("ERROR: WP_BASE_URL no definido", "ERROR")
    log_data["errors"].append("WP_BASE_URL missing")
    save_json_log()
    sys.exit(1)

if not WP_USER or not WP_APP_PASSWORD:
    log('WARN: WP credentials missing; dry-run forced', "WARN")
    DRY_RUN = True
    log_data["dry_run"] = True
    log_data["errors"].append("WP credentials missing")

auth = (WP_USER, WP_APP_PASSWORD) if WP_USER and WP_APP_PASSWORD else None

# ===================================================================
# ADAPTADOR DE TRADUCCIÓN
# ===================================================================
class TranslationAdapter:
    """Adapter para DeepL y OpenAI con rate-limit, retries, fallback automático y dry-run."""
    
    def __init__(self, provider: str, deepl_key: str, openai_key: str, openai_model: str, openai_temp: float):
        self.provider = provider  # deepl | openai | auto
        self.deepl_key = deepl_key
        self.openai_key = openai_key
        self.openai_model = openai_model
        self.openai_temp = openai_temp
        self.deepl_available = bool(deepl_key)
        self.openai_available = bool(openai_key)
        self.selected_provider = None
        
    def select_provider(self) -> Optional[str]:
        """Selecciona proveedor según lógica: deepl | openai | auto."""
        if self.provider == 'deepl':
            if self.deepl_available:
                self.selected_provider = 'deepl'
                return 'deepl'
            log("WARN: DeepL requested but no API key; cannot translate", "WARN")
            return None
            
        elif self.provider == 'openai':
            if self.openai_available:
                self.selected_provider = 'openai'
                return 'openai'
            log("WARN: OpenAI requested but no API key; cannot translate", "WARN")
            return None
            
        elif self.provider == 'auto':
            if self.deepl_available:
                log("Auto-mode: selecting DeepL as primary provider", "INFO")
                self.selected_provider = 'deepl'
                return 'deepl'
            elif self.openai_available:
                log("Auto-mode: DeepL not available, selecting OpenAI as fallback", "INFO")
                self.selected_provider = 'openai'
                return 'openai'
            else:
                log("WARN: Auto-mode but no API keys available; cannot translate", "WARN")
                return None
        else:
            log(f"ERROR: Unknown provider '{self.provider}'", "ERROR")
            return None
        
    def translate(self, text: str, source_lang: str = 'EN', target_lang: str = 'ES', retry_fallback: bool = True) -> Optional[str]:
        """Traduce texto con el proveedor seleccionado y fallback automático si falla."""
        if DRY_RUN:
            log(f"DRY-RUN: Would translate '{text[:50]}...' ({self.provider})", "DEBUG")
            return f"[DRY-RUN TRANSLATION] {text}"
        
        provider = self.select_provider()
        if not provider:
            log("No provider available; cannot translate", "ERROR")
            log_data["errors"].append("No API keys available")
            return None
        
        # Intentar traducción con proveedor seleccionado
        result = None
        if provider == 'deepl':
            result = self._translate_deepl(text, source_lang, target_lang)
        elif provider == 'openai':
            result = self._translate_openai(text, source_lang, target_lang)
        
        # Fallback automático si falla y estamos en modo auto
        if not result and retry_fallback and self.provider == 'auto':
            if provider == 'deepl' and self.openai_available:
                log("DeepL failed; attempting OpenAI fallback", "WARN")
                self.selected_provider = 'openai'
                result = self._translate_openai(text, source_lang, target_lang)
            elif provider == 'openai' and self.deepl_available:
                log("OpenAI failed; attempting DeepL fallback", "WARN")
                self.selected_provider = 'deepl'
                result = self._translate_deepl(text, source_lang, target_lang)
        
        if result:
            log_data["provider_selected"] = self.selected_provider
        
        return result
    
    def _translate_deepl(self, text: str, source: str, target: str) -> Optional[str]:
        """DeepL API v2 con retries."""
        # Detectar si es API Free (contiene ':fx' en la key) o Pro
        is_free = ':fx' in self.deepl_key
        endpoint = "https://api-free.deepl.com/v2/translate" if is_free else "https://api.deepl.com/v2/translate"
        headers = {"Authorization": f"DeepL-Auth-Key {self.deepl_key}"}
        data = {
            "text": [text],
            "source_lang": source.upper(),
            "target_lang": target.upper()
        }
        
        for attempt in range(3):
            try:
                resp = requests.post(endpoint, headers=headers, data=data, timeout=30)
                if resp.status_code == 200:
                    result = resp.json()
                    translated = result['translations'][0]['text']
                    log(f"DeepL translation success ({len(text)} → {len(translated)} chars)", "DEBUG")
                    return translated
                elif resp.status_code == 429:
                    wait = 2 ** attempt
                    log(f"DeepL rate limit (429); waiting {wait}s", "WARN")
                    time.sleep(wait)
                elif resp.status_code >= 500:
                    log(f"DeepL server error {resp.status_code}; retrying", "WARN")
                    time.sleep(2 ** attempt)
                else:
                    log(f"DeepL error {resp.status_code}: {resp.text[:200]}", "ERROR")
                    return None
            except requests.Timeout:
                log(f"DeepL timeout attempt {attempt+1}", "WARN")
                time.sleep(2 ** attempt)
            except Exception as e:
                log(f"DeepL exception attempt {attempt+1}: {e}", "ERROR")
                time.sleep(2 ** attempt)
        
        log("DeepL translation failed after 3 attempts", "ERROR")
        return None
    
    def _translate_openai(self, text: str, source: str, target: str) -> Optional[str]:
        """OpenAI Chat API con retries y prompt optimizado."""
        endpoint = "https://api.openai.com/v1/chat/completions"
        headers = {
            "Authorization": f"Bearer {self.openai_key}",
            "Content-Type": "application/json"
        }
        
        # Prompt optimizado para traducción literal y profesional
        system_prompt = (
            f"You are a professional translator specializing in {source.upper()}→{target.upper()} translation. "
            f"Translate the provided text accurately, preserving HTML tags, formatting, and tone. "
            f"Return ONLY the translated text without explanations, comments, or additional content."
        )
        user_prompt = f"Translate this text from {source.upper()} to {target.upper()}:\n\n{text}"
        
        data = {
            "model": self.openai_model,
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt}
            ],
            "temperature": self.openai_temp,
            "max_tokens": max(len(text) * 2, 500)
        }
        
        for attempt in range(3):
            try:
                resp = requests.post(endpoint, headers=headers, json=data, timeout=60)
                if resp.status_code == 200:
                    result = resp.json()
                    translated = result['choices'][0]['message']['content'].strip()
                    usage = result.get('usage', {})
                    log(f"OpenAI translation success (model: {self.openai_model}, tokens: {usage.get('total_tokens', 0)})", "DEBUG")
                    return translated
                elif resp.status_code == 429:
                    wait = 2 ** attempt
                    log(f"OpenAI rate limit (429); waiting {wait}s", "WARN")
                    time.sleep(wait)
                elif resp.status_code >= 500:
                    log(f"OpenAI server error {resp.status_code}; retrying", "WARN")
                    time.sleep(2 ** attempt)
                else:
                    log(f"OpenAI error {resp.status_code}: {resp.text[:200]}", "ERROR")
                    return None
            except requests.Timeout:
                log(f"OpenAI timeout attempt {attempt+1}", "WARN")
                time.sleep(2 ** attempt)
            except Exception as e:
                log(f"OpenAI exception attempt {attempt+1}: {e}", "ERROR")
                time.sleep(2 ** attempt)
        
        log("OpenAI translation failed after 3 attempts", "ERROR")
        return None

# ===================================================================
# INICIALIZAR ADAPTER
# ===================================================================
translator = TranslationAdapter(
    provider=TRANSLATION_PROVIDER,
    deepl_key=DEEPL_API_KEY,
    openai_key=OPENAI_API_KEY,
    openai_model=OPENAI_MODEL,
    openai_temp=OPENAI_TEMPERATURE
)

# Validar disponibilidad de proveedores
has_any_key = translator.deepl_available or translator.openai_available

if not has_any_key and not DRY_RUN:
    log("WARN: No API keys available for any provider; forcing dry-run", "WARN")
    DRY_RUN = True
    log_data["dry_run"] = True
    log_data["errors"].append("No API keys found for DeepL or OpenAI")

log(f"Environment: {APP_ENV}")
log(f"Base URL: {WP_BASE_URL}")
log(f"Provider mode: {TRANSLATION_PROVIDER} (DeepL: {translator.deepl_available}, OpenAI: {translator.openai_available})")
if translator.openai_available:
    log(f"OpenAI model: {OPENAI_MODEL} (temp: {OPENAI_TEMPERATURE})")
log(f"Dry-run: {DRY_RUN} | Enabled: {AUTO_TRANSLATE_ENABLED}")
log(f"Batch size: {TRANSLATION_BATCH_SIZE}")

# ===================================================================
# LÓGICA PRINCIPAL
# ===================================================================
try:
    # 1. Listar páginas EN sin traducción ES
    log("Fetching EN pages without ES translation...")
    pages_url = f"{WP_BASE_URL}/wp-json/wp/v2/pages?per_page=100&lang=en"
    resp = requests.get(pages_url, auth=auth, timeout=30)
    if resp.status_code != 200:
        raise Exception(f"Failed to fetch pages: {resp.status_code} {resp.text}")
    
    pages = resp.json()
    candidates = []
    
    for page in pages[:TRANSLATION_BATCH_SIZE]:
        page_id = page['id']
        title = page.get('title', {}).get('rendered', 'Untitled')
        content = page.get('content', {}).get('rendered', '')
        translations = page.get('translations', {})
        
        # Si no tiene traducción ES
        if not translations or 'es' not in translations:
            candidates.append({
                "id": page_id,
                "title": title,
                "slug": page.get('slug', ''),
                "content_length": len(content)
            })
            log_data["candidates"].append({
                "id": page_id,
                "title": title,
                "slug": page.get('slug', '')
            })
            log(f"Candidate: {page_id} - {title}")
    
    log(f"Found {len(candidates)} EN pages without ES translation")
    log_data["stats"]["candidates_found"] = len(candidates)
    
    if not candidates:
        log("No pages to translate; exiting")
        log_data["stats"]["created"] = 0
        save_json_log()
        sys.exit(0)
    
    # 2. Traducir y crear borradores ES
    if not AUTO_TRANSLATE_ENABLED:
        log("AUTO_TRANSLATE_ENABLED=false; skipping translation", "WARN")
        log_data["stats"]["created"] = 0
        save_json_log()
        sys.exit(0)
    
    created_count = 0
    for candidate in candidates:
        page_id = candidate['id']
        title_en = candidate['title']
        
        log(f"Processing page {page_id}: {title_en}")
        
        # Obtener contenido completo
        page_detail = requests.get(f"{WP_BASE_URL}/wp-json/wp/v2/pages/{page_id}", auth=auth, timeout=30).json()
        content_en = page_detail.get('content', {}).get('rendered', '')
        
        # Traducir título
        title_es = translator.translate(title_en, 'EN', 'ES')
        if not title_es:
            log(f"Failed to translate title for {page_id}", "ERROR")
            log_data["errors"].append(f"Translation failed for page {page_id}")
            continue
        
        # Traducir contenido (primeros 5000 chars para rate-limit)
        content_es = translator.translate(content_en[:5000], 'EN', 'ES') if content_en else ''
        
        # Preparar datos de log con información del proveedor
        translation_record = {
            "source_id": page_id,
            "title_en": title_en,
            "title_es": title_es,
            "content_length": len(content_en),
            "provider": translator.selected_provider,
            "model": OPENAI_MODEL if translator.selected_provider == 'openai' else None,
            "status": "pending"
        }
        
        if DRY_RUN:
            log(f"DRY-RUN: Would create ES draft: {title_es}", "DEBUG")
            translation_record["status"] = "dry-run"
            translation_record["dry_run"] = True
            log_data["created"].append(translation_record)
        else:
            # Crear borrador ES
            new_page_data = {
                "title": title_es,
                "content": content_es,
                "status": "draft",  # BORRADOR, no publicar automáticamente
                "lang": "es"
            }
            
            try:
                create_resp = requests.post(
                    f"{WP_BASE_URL}/wp-json/wp/v2/pages",
                    auth=auth,
                    json=new_page_data,
                    timeout=30
                )
                if create_resp.status_code in (200, 201):
                    new_page = create_resp.json()
                    new_id = new_page['id']
                    log(f"Created ES draft {new_id}: {title_es}")
                    translation_record["target_id"] = new_id
                    translation_record["slug"] = new_page.get('slug', '')
                    translation_record["status"] = "created"
                    log_data["created"].append(translation_record)
                    created_count += 1
                    
                    # TODO: Vincular traducción vía Polylang si REST lo soporta
                    # o llamar a MU-plugin endpoint tokenizado cuando esté disponible
                    
                else:
                    log(f"Failed to create ES page: {create_resp.status_code} {create_resp.text}", "ERROR")
                    log_data["errors"].append(f"Create failed for {page_id}: {create_resp.status_code}")
            except Exception as e:
                log(f"Exception creating ES page for {page_id}: {e}", "ERROR")
                log_data["errors"].append(f"Exception for {page_id}: {str(e)}")
        
        # Rate limit entre páginas
        time.sleep(1)
    
    # Registrar proveedor final usado
    if translator.selected_provider:
        log_data["provider_selected"] = translator.selected_provider
        log(f"Provider used: {translator.selected_provider}")
    
    log_data["stats"]["created"] = created_count
    log(f"Completed: {created_count} ES drafts created")
    save_json_log()
    
except Exception as e:
    log(f"FATAL ERROR: {e}", "ERROR")
    log_data["errors"].append(f"Fatal: {str(e)}")
    save_json_log()
    sys.exit(1)
