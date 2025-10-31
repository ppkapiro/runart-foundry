#!/usr/bin/env python3
"""
Script de sincronización del dataset enriched desde staging/prod
Fase 4.A - Export seguro de datos IA-Visual

Uso:
    python tools/sync_enriched_dataset.py --staging-url https://staging.runartfoundry.com/ --auth-token TOKEN

Funciones:
- Llamar a /wp-json/runart/v1/export-enriched con autenticación
- Validar JSON recibido
- Crear backup timestamped del dataset actual
- Guardar nuevo dataset en data/assistants/rewrite/
- Generar reporte de sincronización
"""

import argparse
import json
import sys
import shutil
from datetime import datetime
from pathlib import Path
from typing import Dict, Any, Optional
import urllib.request
import urllib.error

# Constantes
REPO_ROOT = Path(__file__).parent.parent.absolute()
DATA_DIR = REPO_ROOT / "data" / "assistants" / "rewrite"
BACKUP_DIR = REPO_ROOT / "_backups" / "enriched_datasets"
REPORTS_DIR = REPO_ROOT / "_reports"

def http_get(url: str, auth_token: Optional[str] = None) -> Dict[str, Any]:
    """Realizar petición GET con autenticación opcional"""
    headers = {
        'User-Agent': 'RunArt-Sync-Script/1.0',
        'Accept': 'application/json',
    }
    
    if auth_token:
        headers['Authorization'] = f'Bearer {auth_token}'
    
    req = urllib.request.Request(url, headers=headers)
    
    try:
        with urllib.request.urlopen(req, timeout=60) as response:
            if response.status != 200:
                raise Exception(f"HTTP {response.status}: {response.reason}")
            
            content = response.read().decode('utf-8')
            return json.loads(content)
    except urllib.error.HTTPError as e:
        error_body = e.read().decode('utf-8') if e.fp else ''
        raise Exception(f"HTTP Error {e.code}: {e.reason}\n{error_body}")
    except urllib.error.URLError as e:
        raise Exception(f"URL Error: {e.reason}")

def create_backup() -> Optional[Path]:
    """Crear backup timestamped del dataset actual"""
    if not DATA_DIR.exists():
        print("⚠️  No existe dataset actual para respaldar")
        return None
    
    # Timestamp para el backup
    timestamp = datetime.utcnow().strftime('%Y%m%dT%H%M%SZ')
    backup_path = BACKUP_DIR / f"enriched_dataset_{timestamp}"
    
    # Crear directorio de backup
    backup_path.mkdir(parents=True, exist_ok=True)
    
    # Copiar todos los archivos JSON
    copied_files = 0
    for json_file in DATA_DIR.glob("*.json"):
        shutil.copy2(json_file, backup_path / json_file.name)
        copied_files += 1
    
    if copied_files > 0:
        print(f"✅ Backup creado: {backup_path} ({copied_files} archivos)")
        return backup_path
    else:
        print("⚠️  No se encontraron archivos para respaldar")
        return None

def validate_export_data(data: Dict[str, Any]) -> bool:
    """Validar estructura del export recibido"""
    if not isinstance(data, dict):
        print("❌ El export no es un objeto JSON válido")
        return False
    
    if not data.get('ok'):
        print("❌ El export indica error: ok=false")
        return False
    
    export = data.get('export', {})
    if not isinstance(export, dict):
        print("❌ Campo 'export' ausente o inválido")
        return False
    
    meta = export.get('meta', {})
    if not meta.get('source'):
        print("⚠️  Metadatos 'source' ausentes")
    
    index = export.get('index')
    if not index:
        print("❌ Campo 'index' ausente")
        return False
    
    pages = export.get('pages', {})
    if not isinstance(pages, dict):
        print("⚠️  Campo 'pages' ausente o no es un objeto")
        # No es error fatal si solo queremos index
    
    print(f"✅ Validación OK: source={meta.get('source')}, páginas={len(pages)}")
    return True

def save_dataset(export_data: Dict[str, Any]) -> int:
    """Guardar dataset en data/assistants/rewrite/"""
    export = export_data.get('export', {})
    index = export.get('index')
    pages = export.get('pages', {})
    
    # Crear directorio si no existe
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    
    # Guardar index.json
    index_path = DATA_DIR / "index.json"
    with open(index_path, 'w', encoding='utf-8') as f:
        json.dump(index, f, indent=2, ensure_ascii=False)
    print(f"✅ Guardado: {index_path}")
    
    saved_count = 1  # index.json
    
    # Guardar páginas individuales
    for page_id, page_data in pages.items():
        page_path = DATA_DIR / f"{page_id}.json"
        with open(page_path, 'w', encoding='utf-8') as f:
            json.dump(page_data, f, indent=2, ensure_ascii=False)
        saved_count += 1
    
    if len(pages) > 0:
        print(f"✅ Guardadas {len(pages)} páginas individuales")
    
    return saved_count

def generate_report(
    staging_url: str,
    success: bool,
    export_data: Optional[Dict[str, Any]] = None,
    backup_path: Optional[Path] = None,
    error: Optional[str] = None
) -> Path:
    """Generar reporte de sincronización"""
    timestamp = datetime.utcnow().strftime('%Y%m%dT%H%M%SZ')
    report_path = REPORTS_DIR / f"sync_enriched_{timestamp}.md"
    
    report_lines = [
        f"# Sincronización Dataset Enriched — {timestamp}",
        "",
        f"Fecha: {datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')} UTC",
        f"Origen: {staging_url}",
        "",
        "## Estado",
        ""
    ]
    
    if success:
        report_lines.append("✅ **ÉXITO** — Dataset sincronizado correctamente")
        report_lines.append("")
        
        if export_data:
            export = export_data.get('export', {})
            meta = export.get('meta', {})
            pages = export.get('pages', {})
            
            report_lines.extend([
                "## Detalles del Export",
                "",
                f"- Fuente: `{meta.get('source', 'N/A')}`",
                f"- Ruta origen: `{meta.get('source_path', 'N/A')}`",
                f"- Formato: {meta.get('format', 'N/A')}",
                f"- Total páginas: {len(pages)}",
                f"- Timestamp export: {meta.get('export_timestamp', 'N/A')}",
                ""
            ])
        
        if backup_path:
            report_lines.extend([
                "## Backup",
                "",
                f"Backup anterior guardado en: `{backup_path}`",
                ""
            ])
    else:
        report_lines.append(f"❌ **ERROR** — {error or 'Error desconocido'}")
        report_lines.append("")
    
    report_lines.extend([
        "## Próximos pasos",
        "",
        "1. Verificar integridad del dataset en `data/assistants/rewrite/`",
        "2. Ejecutar validación REST local si el plugin está activo",
        "3. Actualizar informe global si procede",
        ""
    ])
    
    # Guardar reporte
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)
    with open(report_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(report_lines))
    
    print(f"📄 Reporte generado: {report_path}")
    return report_path

def main():
    parser = argparse.ArgumentParser(
        description="Sincronizar dataset enriched desde staging/prod via REST"
    )
    parser.add_argument(
        '--staging-url',
        required=True,
        help='URL base del staging (ej: https://staging.runartfoundry.com/)'
    )
    parser.add_argument(
        '--auth-token',
        required=False,
        help='Token de autenticación Bearer (admin-only endpoint)'
    )
    parser.add_argument(
        '--format',
        choices=['full', 'index-only'],
        default='full',
        help='Formato del export: full (con páginas) o index-only'
    )
    parser.add_argument(
        '--no-backup',
        action='store_true',
        help='No crear backup del dataset actual'
    )
    
    args = parser.parse_args()
    
    # Normalizar URL
    staging_url = args.staging_url.rstrip('/')
    export_endpoint = f"{staging_url}/wp-json/runart/v1/export-enriched?format={args.format}"
    
    print("=" * 60)
    print("🔄 Sincronización Dataset Enriched")
    print("=" * 60)
    print(f"Origen: {staging_url}")
    print(f"Endpoint: {export_endpoint}")
    print(f"Formato: {args.format}")
    print()
    
    backup_path = None
    export_data = None
    error_msg = None
    success = False
    
    try:
        # 1. Crear backup del dataset actual
        if not args.no_backup:
            backup_path = create_backup()
        
        # 2. Llamar al endpoint de export
        print(f"🌐 Llamando a {export_endpoint}...")
        export_data = http_get(export_endpoint, args.auth_token)
        
        # 3. Validar datos recibidos
        if not validate_export_data(export_data):
            raise Exception("Validación del export falló")
        
        # 4. Guardar dataset
        saved_count = save_dataset(export_data)
        print(f"✅ Dataset sincronizado: {saved_count} archivos guardados")
        
        success = True
        
    except Exception as e:
        error_msg = str(e)
        print(f"\n❌ Error: {error_msg}")
        success = False
    
    # 5. Generar reporte
    report_path = generate_report(
        staging_url,
        success,
        export_data,
        backup_path,
        error_msg
    )
    
    # 6. Exit code
    exit_code = 0 if success else 1
    
    print()
    print("=" * 60)
    if success:
        print("✅ Sincronización completada con éxito")
    else:
        print("❌ Sincronización falló")
    print(f"📄 Reporte: {report_path}")
    print("=" * 60)
    
    sys.exit(exit_code)

if __name__ == '__main__':
    main()
