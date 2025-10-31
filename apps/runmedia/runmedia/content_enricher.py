#!/usr/bin/env python3
"""
Content Enricher — Reescritura Asistida y Enriquecimiento con IA

Módulo para generar contenido enriquecido a partir de correlaciones texto↔imagen
calculadas en F8. Propone variantes mejoradas con imágenes sugeridas, metadatos
SEO, captions, alt texts y CTAs personalizados.

Autor: automation-runart
Fase: F9 — Reescritura Asistida y Enriquecimiento
Fecha: 2025-10-30
Dependencias: F8 (embeddings y correlaciones)
"""

import json
import logging
from pathlib import Path
from datetime import datetime, timezone
from typing import Dict, List, Optional

# Configuración
CORRELATIONS_DIR = Path("data/embeddings/correlations")
TEXT_EMBEDDINGS_DIR = Path("data/embeddings/text/multilingual_mpnet/embeddings")
OUTPUT_DIR = Path("data/enriched/f9_rewrites")
SOURCE_PAGES_FILE = Path("test_pages.json")

# Thresholds
HIGH_CONFIDENCE_THRESHOLD = 0.35  # Solo estas reciben captions completos
LOW_CONFIDENCE_THRESHOLD = 0.0    # Threshold mínimo para incluir

# Logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


class ContentEnricher:
    """
    Enriquecedor de contenido que combina correlaciones IA-Visual con textos originales.
    
    Attributes:
        similarity_matrix: Datos de la matriz de similitud
        recommendations_cache: Cache de recomendaciones pre-computadas
        source_pages: Contenido original de las páginas
    """
    
    def __init__(self):
        """Inicializa el enriquecedor cargando artefactos de F8."""
        self.similarity_matrix = self._load_json(CORRELATIONS_DIR / "similarity_matrix.json")
        self.recommendations_cache = self._load_json(CORRELATIONS_DIR / "recommendations_cache.json")
        self.source_pages = self._load_source_pages()
        
        # Crear directorio de salida
        OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
        
        logger.info("✅ ContentEnricher inicializado")
        logger.info(f"   Páginas origen: {len(self.source_pages)}")
        logger.info(f"   Páginas en cache: {len(self.recommendations_cache.get('cache', {}))}")
    
    def _load_json(self, file_path: Path) -> Dict:
        """Carga un archivo JSON."""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            logger.error(f"❌ Error cargando {file_path}: {e}")
            return {}
    
    def _load_source_pages(self) -> Dict[str, Dict]:
        """
        Carga las páginas originales desde test_pages.json.
        
        Returns:
            Diccionario indexado por page_id
        """
        if not SOURCE_PAGES_FILE.exists():
            logger.warning(f"⚠️ Archivo {SOURCE_PAGES_FILE} no encontrado")
            return {}
        
        try:
            with open(SOURCE_PAGES_FILE, 'r', encoding='utf-8') as f:
                pages_list = json.load(f)
            
            # Indexar por page_id
            pages_dict = {}
            for page in pages_list:
                page_id = f"page_{page['id']}"
                pages_dict[page_id] = page
            
            logger.info(f"✅ {len(pages_dict)} páginas cargadas desde {SOURCE_PAGES_FILE}")
            return pages_dict
            
        except Exception as e:
            logger.error(f"❌ Error cargando páginas origen: {e}")
            return {}
    
    def _generate_slug(self, title: str, lang: str) -> str:
        """
        Genera un slug SEO-friendly desde un título.
        
        Args:
            title: Título original
            lang: Idioma (es/en)
            
        Returns:
            Slug en formato URL-safe
        """
        import re
        
        # Convertir a minúsculas y reemplazar espacios
        slug = title.lower()
        
        # Reemplazar caracteres especiales comunes en ES
        replacements = {
            'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u',
            'ñ': 'n', 'ü': 'u',
            ' ': '-', '_': '-'
        }
        
        for old, new in replacements.items():
            slug = slug.replace(old, new)
        
        # Eliminar caracteres no alfanuméricos excepto guiones
        slug = re.sub(r'[^a-z0-9-]', '', slug)
        
        # Eliminar guiones múltiples
        slug = re.sub(r'-+', '-', slug)
        
        # Eliminar guiones al inicio/final
        slug = slug.strip('-')
        
        return slug
    
    def _generate_cta(self, lang: str) -> Dict:
        """
        Genera un CTA estándar según idioma.
        
        Args:
            lang: Idioma (es/en)
            
        Returns:
            Diccionario con texto y URL del CTA
        """
        if lang == 'es':
            return {
                "text": "Solicita una pieza o fundición personalizada",
                "url": "/contacto/"
            }
        else:  # en
            return {
                "text": "Request a custom casting",
                "url": "/en/contact/"
            }
    
    def _generate_seo_metadata(self, title: str, content: str, lang: str) -> Dict:
        """
        Genera metadatos SEO básicos.
        
        Args:
            title: Título de la página
            content: Contenido de la página
            lang: Idioma
            
        Returns:
            Diccionario con title, description, keywords
        """
        # Generar descripción corta (primeras 160 chars aprox)
        description = content[:160].strip()
        if len(content) > 160:
            # Cortar en última palabra completa
            last_space = description.rfind(' ')
            if last_space > 0:
                description = description[:last_space] + '...'
        
        # Keywords comunes para RunArt Foundry
        keywords_base = ["foundry", "bronze", "art", "sculpture", "custom casting"]
        
        # Keywords adicionales según idioma
        if lang == 'es':
            keywords_lang = ["fundición", "escultura", "arte", "bronce", "taller"]
        else:
            keywords_lang = ["gallery", "contemporary art", "digital art", "exhibition"]
        
        return {
            "title": title,
            "description": description,
            "keywords": keywords_base + keywords_lang
        }
    
    def _process_image_suggestion(self, image_data: Dict, page_title: str, lang: str) -> Dict:
        """
        Procesa una sugerencia de imagen y genera metadatos completos.
        
        Args:
            image_data: Datos de la imagen desde recommendations_cache
            page_title: Título de la página para contexto
            lang: Idioma para captions
            
        Returns:
            Diccionario con metadatos enriquecidos de la imagen
        """
        score = image_data.get('similarity_score', 0.0)
        filename = image_data.get('filename', 'unknown.jpg')
        
        # Determinar nivel de confianza
        low_confidence = score < HIGH_CONFIDENCE_THRESHOLD
        
        # Generar alt text y caption según idioma y confianza
        if low_confidence:
            if lang == 'es':
                alt = f"Imagen decorativa relacionada con {page_title}"
                caption = "Imagen sugerida automáticamente (baja confianza)"
            else:
                alt = f"Decorative image related to {page_title}"
                caption = "Automatically suggested image (low confidence)"
        else:
            # Alta confianza: caption más específico
            image_type = filename.replace('.jpg', '').replace('artwork_', '').replace('_', ' ')
            if lang == 'es':
                alt = f"Obra de arte: {image_type} - {page_title}"
                caption = f"Obra seleccionada por similitud semántica ({score*100:.1f}%)"
            else:
                alt = f"Artwork: {image_type} - {page_title}"
                caption = f"Selected by semantic similarity ({score*100:.1f}%)"
        
        # Determinar placement sugerido basado en score
        if score >= 0.05:
            placement = "hero"
        elif score >= 0.03:
            placement = "inline"
        else:
            placement = "gallery"
        
        return {
            "image_id": image_data.get('image_id'),
            "filename": filename,
            "score": round(score, 4),
            "alt": alt,
            "caption": caption,
            "placement": placement,
            "low_confidence": low_confidence
        }
    
    def enrich_page(self, page_id: str) -> Dict:
        """
        Enriquece una página específica con recomendaciones de imágenes y metadatos.
        
        Args:
            page_id: ID de la página (ej: "page_42")
            
        Returns:
            Diccionario con contenido enriquecido
        """
        logger.info(f"📝 Enriqueciendo {page_id}...")
        
        # Obtener datos originales
        source_page = self.source_pages.get(page_id)
        if not source_page:
            logger.warning(f"⚠️ Página {page_id} no encontrada en origen")
            original_text = "Contenido original no recuperado en F9; usar endpoint WP en F10."
            title = "Untitled"
            lang = "en"
        else:
            original_text = source_page.get('content', '')
            title = source_page.get('title', 'Untitled')
            lang = source_page.get('lang', 'en')
        
        # Obtener recomendaciones de imágenes
        cache = self.recommendations_cache.get('cache', {})
        recommendations = cache.get(page_id, [])
        
        logger.info(f"   📷 {len(recommendations)} imágenes recomendadas")
        
        # Procesar imágenes sugeridas
        images_suggested = []
        for img_data in recommendations:
            processed = self._process_image_suggestion(img_data, title, lang)
            images_suggested.append(processed)
        
        # Asegurar mínimo 2 imágenes (rellenar con disponibles si es necesario)
        if len(images_suggested) < 2:
            logger.info(f"   ⚠️ Solo {len(images_suggested)} imagen(es), necesitamos mínimo 2")
            # TODO: implementar fallback con imágenes de mayor score global
        
        # Generar summary corto
        if lang == 'es':
            summary = f"Contenido sobre {title.lower()} con {len(images_suggested)} imágenes sugeridas"
        else:
            summary = f"Content about {title.lower()} with {len(images_suggested)} suggested images"
        
        # Generar slug
        slug = self._generate_slug(title, lang)
        
        # Generar CTA
        cta = self._generate_cta(lang)
        
        # Generar keywords básicas
        keywords = ["art", "gallery", "sculpture", "contemporary"]
        if 'red' in original_text.lower() or 'rojo' in original_text.lower():
            keywords.append("red artwork")
        if 'blue' in original_text.lower() or 'azul' in original_text.lower():
            keywords.append("blue artwork")
        if 'digital' in original_text.lower():
            keywords.append("digital art")
        
        # Generar SEO metadata
        seo = self._generate_seo_metadata(title, original_text, lang)
        
        # Construir variante enriquecida
        variant = {
            "variant_id": f"{page_id}_v1",
            "summary": summary,
            "proposed_title": title,  # Por ahora mantener original
            "proposed_slug": slug,
            "images_suggested": images_suggested,
            "cta_suggested": [cta],
            "keywords": keywords,
            "seo": seo,
            "notes": "Generado automáticamente en F9 a partir de correlaciones F8"
        }
        
        # Construir estructura completa
        enriched_data = {
            "page_id": page_id,
            "source_embedding": f"data/embeddings/text/multilingual_mpnet/embeddings/{page_id}.json",
            "original_text": original_text,
            "language": lang,
            "enriched_variants": [variant],
            "generated_at": datetime.now(timezone.utc).isoformat(),
            "phase": "F9"
        }
        
        logger.info(f"   ✅ Enriquecimiento completado")
        return enriched_data
    
    def save_enriched_page(self, page_id: str, enriched_data: Dict):
        """
        Guarda los datos enriquecidos en un archivo JSON.
        
        Args:
            page_id: ID de la página
            enriched_data: Datos enriquecidos
        """
        output_file = OUTPUT_DIR / f"{page_id}.json"
        
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump(enriched_data, f, indent=2, ensure_ascii=False)
            
            logger.info(f"💾 Guardado: {output_file}")
        except Exception as e:
            logger.error(f"❌ Error guardando {output_file}: {e}")
    
    def process_all_pages(self) -> int:
        """
        Procesa todas las páginas disponibles en el cache.
        
        Returns:
            Número de páginas procesadas
        """
        logger.info("🚀 Iniciando procesamiento de todas las páginas...")
        
        cache = self.recommendations_cache.get('cache', {})
        page_ids = list(cache.keys())
        
        logger.info(f"📋 {len(page_ids)} páginas encontradas en cache")
        
        processed = 0
        for page_id in page_ids:
            try:
                enriched_data = self.enrich_page(page_id)
                self.save_enriched_page(page_id, enriched_data)
                processed += 1
            except Exception as e:
                logger.error(f"❌ Error procesando {page_id}: {e}")
        
        logger.info(f"✅ Procesamiento completado: {processed}/{len(page_ids)} páginas")
        return processed


def main():
    """Función principal para ejecutar desde CLI."""
    import argparse
    
    parser = argparse.ArgumentParser(description="Generar contenido enriquecido desde correlaciones F8")
    parser.add_argument('--page-id', type=str, help='Procesar una página específica')
    parser.add_argument('--all', action='store_true', help='Procesar todas las páginas')
    
    args = parser.parse_args()
    
    # Crear enriquecedor
    enricher = ContentEnricher()
    
    # Procesar
    if args.page_id:
        enriched = enricher.enrich_page(args.page_id)
        enricher.save_enriched_page(args.page_id, enriched)
        print(f"✅ Página {args.page_id} enriquecida")
    elif args.all:
        count = enricher.process_all_pages()
        print(f"✅ {count} páginas enriquecidas")
    else:
        # Por defecto: procesar todas
        count = enricher.process_all_pages()
        print(f"✅ {count} páginas enriquecidas")


if __name__ == "__main__":
    main()
