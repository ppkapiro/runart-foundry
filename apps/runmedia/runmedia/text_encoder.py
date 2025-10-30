#!/usr/bin/env python3
"""
Text Encoder — Generación de Embeddings Textuales Multilingües

Módulo para generar embeddings textuales de 768 dimensiones usando el modelo
Sentence-Transformers paraphrase-multilingual-mpnet-base-v2 (soporta ES/EN).

Autor: automation-runart
Fase: F7 — Arquitectura IA-Visual
Fecha: 2025-10-30
"""

import json
import logging
import requests
from pathlib import Path
from datetime import datetime, timezone
from typing import Dict, List, Optional

try:
    from sentence_transformers import SentenceTransformer
    DEPENDENCIES_AVAILABLE = True
except ImportError:
    DEPENDENCIES_AVAILABLE = False
    logging.warning("sentence-transformers not installed. Running in stub mode.")

# Configuración
MODEL_NAME = "paraphrase-multilingual-mpnet-base-v2"
EMBEDDING_DIM = 768
OUTPUT_DIR = Path("data/embeddings/text/multilingual_mpnet/embeddings")
INDEX_PATH = Path("data/embeddings/text/multilingual_mpnet/index.json")

# Logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


class TextEncoder:
    """
    Codificador de texto que genera embeddings multilingües.
    
    Attributes:
        model: Modelo Sentence-Transformers multilingual
        output_dir: Directorio de salida para embeddings
        index_path: Ruta al archivo index.json
    """
    
    def __init__(self, output_dir: Optional[Path] = None, index_path: Optional[Path] = None):
        """
        Inicializa el codificador de texto.
        
        Args:
            output_dir: Directorio donde guardar embeddings (default: OUTPUT_DIR)
            index_path: Ruta al index.json (default: INDEX_PATH)
        """
        self.output_dir = output_dir or OUTPUT_DIR
        self.index_path = index_path or INDEX_PATH
        self.model = None
        
        # Crear directorios si no existen
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.index_path.parent.mkdir(parents=True, exist_ok=True)
        
        # Cargar modelo si las dependencias están disponibles
        if DEPENDENCIES_AVAILABLE:
            try:
                logger.info(f"Cargando modelo multilingual: {MODEL_NAME}")
                self.model = SentenceTransformer(MODEL_NAME)
                logger.info("✅ Modelo multilingual cargado correctamente")
            except Exception as e:
                logger.error(f"❌ Error cargando modelo: {e}")
                self.model = None
        else:
            logger.warning("⚠️ Dependencias no disponibles. Modo stub activado.")
    
    def generate_text_embedding(self, title: str, content: str, lang: str, 
                               page_id: Optional[int] = None, url: Optional[str] = None) -> Dict:
        """
        Genera un embedding textual para contenido de una página.
        
        Args:
            title: Título de la página
            content: Contenido de la página (puede ser extracto o completo)
            lang: Código de idioma (es, en, etc.)
            page_id: ID de la página (opcional)
            url: URL de la página (opcional)
            
        Returns:
            Diccionario con embedding y metadatos
        """
        logger.info(f"Procesando página: {title} ({lang})")
        
        # Crear ID
        if page_id:
            text_id = f"page_{page_id}"
        else:
            # Usar hash del título como ID alternativo
            import hashlib
            text_id = f"text_{hashlib.md5(title.encode()).hexdigest()[:12]}"
        
        # Combinar título y contenido para el embedding
        combined_text = f"{title}. {content}"
        word_count = len(combined_text.split())
        
        # Generar embedding
        if self.model is not None and DEPENDENCIES_AVAILABLE:
            try:
                embedding_vector = self.model.encode(combined_text)
                embedding_list = embedding_vector.tolist()
                logger.info(f"✅ Embedding generado: {len(embedding_list)} dimensiones")
            except Exception as e:
                logger.error(f"❌ Error generando embedding: {e}")
                # Stub: embedding de ceros
                embedding_list = [0.0] * EMBEDDING_DIM
        else:
            # Modo stub: embedding de ceros
            logger.warning("⚠️ Modo stub: generando embedding de ceros")
            embedding_list = [0.0] * EMBEDDING_DIM
        
        # Crear estructura de datos
        embedding_data = {
            "id": text_id,
            "source": {
                "page_id": page_id,
                "title": title,
                "language": lang,
                "word_count": word_count,
                "url": url
            },
            "model": {
                "name": MODEL_NAME,
                "version": "2.7.0",
                "dimensions": EMBEDDING_DIM
            },
            "embedding": embedding_list,
            "metadata": {
                "generated_at": datetime.now(timezone.utc).isoformat(),
                "content_preview": content[:200] if len(content) > 200 else content
            }
        }
        
        # Guardar embedding individual
        embedding_file = self.output_dir / f"{text_id}.json"
        with open(embedding_file, 'w', encoding='utf-8') as f:
            json.dump(embedding_data, f, indent=2, ensure_ascii=False)
        
        logger.info(f"💾 Embedding guardado: {embedding_file}")
        
        # Actualizar índice
        self._update_index(embedding_data)
        
        return embedding_data
    
    def _update_index(self, embedding_data: Dict):
        """
        Actualiza el archivo index.json con el nuevo embedding.
        
        Args:
            embedding_data: Datos del embedding generado
        """
        # Cargar índice existente
        if self.index_path.exists():
            with open(self.index_path, 'r', encoding='utf-8') as f:
                index = json.load(f)
        else:
            index = {
                "version": "1.0",
                "model": MODEL_NAME,
                "dimensions": EMBEDDING_DIM,
                "generated_at": datetime.now(timezone.utc).isoformat(),
                "total_embeddings": 0,
                "items": []
            }
        
        # Agregar/actualizar item
        item_summary = {
            "id": embedding_data["id"],
            "title": embedding_data["source"]["title"],
            "language": embedding_data["source"]["language"],
            "page_id": embedding_data["source"]["page_id"],
            "generated_at": embedding_data["metadata"]["generated_at"]
        }
        
        # Buscar si ya existe
        existing_idx = next((i for i, item in enumerate(index["items"]) 
                           if item["id"] == item_summary["id"]), None)
        
        if existing_idx is not None:
            index["items"][existing_idx] = item_summary
            logger.info("🔄 Item actualizado en índice")
        else:
            index["items"].append(item_summary)
            logger.info("➕ Item agregado al índice")
        
        # Actualizar contador
        index["total_embeddings"] = len(index["items"])
        index["last_updated"] = datetime.now(timezone.utc).isoformat()
        
        # Guardar índice
        with open(self.index_path, 'w', encoding='utf-8') as f:
            json.dump(index, f, indent=2, ensure_ascii=False)
        
        logger.info(f"📋 Índice actualizado: {index['total_embeddings']} embeddings")
    
    def fetch_pages_from_wp_json(self, wp_json_url: str) -> List[Dict]:
        """
        Obtiene páginas desde el endpoint REST de WordPress.
        
        Args:
            wp_json_url: URL del endpoint (ej: https://site.com/wp-json/runart/audit/pages)
            
        Returns:
            Lista de páginas con sus datos
        """
        logger.info(f"📡 Obteniendo páginas desde: {wp_json_url}")
        
        try:
            response = requests.get(wp_json_url, timeout=30)
            response.raise_for_status()
            data = response.json()
            
            if 'pages' in data:
                pages = data['pages']
            elif isinstance(data, list):
                pages = data
            else:
                logger.warning("⚠️ Formato de respuesta inesperado")
                return []
            
            logger.info(f"✅ {len(pages)} páginas obtenidas")
            return pages
        except Exception as e:
            logger.error(f"❌ Error obteniendo páginas: {e}")
            return []
    
    def process_wp_json_pages(self, wp_json_url: str) -> int:
        """
        Procesa todas las páginas desde WordPress REST API.
        
        Args:
            wp_json_url: URL del endpoint de páginas
            
        Returns:
            Número de páginas procesadas
        """
        pages = self.fetch_pages_from_wp_json(wp_json_url)
        
        if not pages:
            logger.warning("⚠️ No hay páginas para procesar")
            return 0
        
        processed = 0
        for page in pages:
            try:
                # Extraer datos de la página
                page_id = page.get('id')
                title = page.get('title', 'Untitled')
                content = page.get('content', page.get('excerpt', ''))
                lang = page.get('lang', page.get('language', 'es'))
                url = page.get('url', page.get('link', ''))
                
                # Generar embedding
                self.generate_text_embedding(
                    title=title,
                    content=content,
                    lang=lang,
                    page_id=page_id,
                    url=url
                )
                processed += 1
            except Exception as e:
                logger.error(f"❌ Error procesando página {page.get('id', 'unknown')}: {e}")
        
        logger.info(f"✅ Procesamiento completado: {processed}/{len(pages)} páginas")
        return processed


def main():
    """Función principal para ejecutar desde CLI."""
    import argparse
    
    parser = argparse.ArgumentParser(description="Generar embeddings textuales multilingües")
    parser.add_argument('--wp-json-url', type=str, help='URL del endpoint de páginas')
    parser.add_argument('--title', type=str, help='Título de la página (modo individual)')
    parser.add_argument('--content', type=str, help='Contenido de la página (modo individual)')
    parser.add_argument('--lang', type=str, default='es', help='Idioma (es/en)')
    parser.add_argument('--output-dir', type=str, help='Directorio de salida')
    
    args = parser.parse_args()
    
    # Crear encoder
    encoder = TextEncoder(
        output_dir=Path(args.output_dir) if args.output_dir else None
    )
    
    # Procesar
    if args.wp_json_url:
        count = encoder.process_wp_json_pages(args.wp_json_url)
        print(f"✅ {count} embeddings generados desde WordPress")
    elif args.title and args.content:
        result = encoder.generate_text_embedding(
            title=args.title,
            content=args.content,
            lang=args.lang
        )
        print(f"✅ Embedding generado: {result['id']}")
    else:
        print("❌ Especificar --wp-json-url o --title y --content")
        parser.print_help()


if __name__ == "__main__":
    main()
