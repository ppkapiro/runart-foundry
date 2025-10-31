#!/usr/bin/env python3
"""
Módulo de Reescritura Asistida y Enriquecimiento (F9) - V2
Genera archivos en data/assistants/rewrite/ con la estructura solicitada.

Este módulo lee las correlaciones generadas en F8 y produce contenido
enriquecido con referencias visuales, metadatos y versiones bilingües ES/EN.

IMPORTANTE:
- Threshold de producción recomendado: >= 0.70
- Dataset actual: mixto (visual sintético 512D, texto real 768D mpnet)
- Este módulo NO recalcula embeddings, solo LEE correlaciones existentes
"""

import json
import logging
from pathlib import Path
from datetime import datetime, timezone
from typing import Dict, List, Optional

# Configuración de logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class ContentEnricherV2:
    """
    Generador de contenido enriquecido basado en correlaciones imagen-texto.
    Genera archivos en data/assistants/rewrite/ según especificación F9.
    """
    
    def __init__(self, base_path: Path = None):
        """
        Inicializa el enriquecedor de contenido.
        
        Args:
            base_path: Ruta base del proyecto (default: detecta automáticamente)
        """
        if base_path is None:
            # Detectar ruta base (3 niveles arriba de este archivo)
            base_path = Path(__file__).parent.parent.parent.parent
        
        self.base_path = Path(base_path)
        self.data_path = self.base_path / "data"
        
        # Rutas de entrada (F8)
        self.similarity_matrix_path = self.data_path / "embeddings" / "correlations" / "similarity_matrix.json"
        self.recommendations_cache_path = self.data_path / "embeddings" / "correlations" / "recommendations_cache.json"
        self.source_pages_path = self.base_path / "test_pages.json"
        self.text_embeddings_path = self.data_path / "embeddings" / "text" / "multilingual_mpnet" / "embeddings"
        
        # Ruta de salida (F9) - según especificación
        self.output_path = self.data_path / "assistants" / "rewrite"
        
        # Cargar datos
        self.similarity_matrix = self._load_json(self.similarity_matrix_path)
        self.recommendations_cache = self._load_json(self.recommendations_cache_path)
        self.source_pages = self._load_json(self.source_pages_path)
        
        logger.info(f"ContentEnricherV2 inicializado")
        logger.info(f"  - Matriz de similitud: {len(self.similarity_matrix.get('matrix', []))} comparaciones")
        logger.info(f"  - Páginas en caché: {self.recommendations_cache.get('total_pages', 0)}")
        logger.info(f"  - Páginas fuente: {len(self.source_pages) if isinstance(self.source_pages, list) else 0}")
        logger.info(f"  - Output: {self.output_path}")
    
    def _load_json(self, path: Path) -> Dict:
        """Carga un archivo JSON."""
        try:
            with open(path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            logger.error(f"Error cargando {path}: {e}")
            return {}
    
    def _save_json(self, data: Dict, path: Path):
        """Guarda un archivo JSON."""
        path.parent.mkdir(parents=True, exist_ok=True)
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        logger.info(f"Guardado: {path}")
    
    def _get_source_page(self, page_id: str) -> Optional[Dict]:
        """
        Recupera la información de página fuente desde test_pages.json.
        
        Args:
            page_id: ID de la página (ej: "42", "page_42")
        
        Returns:
            Dict con información de la página o None
        """
        # Normalizar ID (remover prefijo "page_" si existe)
        normalized_id = page_id.replace("page_", "")
        
        if isinstance(self.source_pages, list):
            for page in self.source_pages:
                if str(page.get("id")) == normalized_id:
                    return page
        
        return None
    
    def _generate_tags(self, content: str, title: str, lang: str) -> List[str]:
        """
        Genera tags automáticos basados en el contenido.
        
        Args:
            content: Texto del contenido
            title: Título de la página
            lang: Idioma (es/en)
        
        Returns:
            Lista de tags relevantes
        """
        tags = ["runart"]
        
        # Keywords comunes en ambos idiomas
        keywords_map = {
            "es": {
                "fundición": ["fundicion", "fundición"],
                "arte": ["arte", "artístico", "artística"],
                "bronce": ["bronce", "bronze"],
                "escultura": ["escultura", "esculturas"],
                "galería": ["galeria", "galería"],
                "contemporáneo": ["contemporaneo", "contemporáneo"],
                "digital": ["digital", "digitales"],
                "abstracto": ["abstracto", "abstracta"],
                "rojo": ["rojo", "roja", "red"],
                "azul": ["azul", "blue"],
                "verde": ["verde", "green"]
            },
            "en": {
                "foundry": ["foundry", "casting"],
                "art": ["art", "artwork", "artistic"],
                "bronze": ["bronze", "bronce"],
                "sculpture": ["sculpture", "sculptures"],
                "gallery": ["gallery", "galleries"],
                "contemporary": ["contemporary", "modern"],
                "digital": ["digital"],
                "abstract": ["abstract"],
                "red": ["red"],
                "blue": ["blue"],
                "green": ["green"]
            }
        }
        
        text_lower = (content + " " + title).lower()
        lang_keywords = keywords_map.get(lang, keywords_map["en"])
        
        for tag, variants in lang_keywords.items():
            if any(variant in text_lower for variant in variants):
                tags.append(tag)
        
        return list(set(tags))  # Eliminar duplicados
    
    def _enrich_content(self, page_data: Dict, recommendations: List[Dict], lang: str) -> Dict:
        """
        Genera el contenido enriquecido para una página según especificación F9.
        
        Args:
            page_data: Datos de la página fuente
            recommendations: Lista de recomendaciones de imágenes
            lang: Idioma principal (es/en)
        
        Returns:
            Dict con contenido enriquecido
        """
        title = page_data.get("title", "")
        content = page_data.get("content", "")
        
        # Generar headline, summary, body según idioma
        if lang == "es":
            headline = f"{title} - Versión Enriquecida"
            summary = f"Contenido mejorado con {len(recommendations)} referencias visuales basadas en correlación semántica IA."
            body_prefix = "## Contenido Enriquecido\n\nEsta versión incorpora referencias visuales sugeridas automáticamente mediante análisis de similitud semántica entre embeddings de texto e imagen.\n\n### Contenido Original\n\n"
        else:
            headline = f"{title} - Enhanced Version"
            summary = f"Enhanced content with {len(recommendations)} visual references based on AI semantic correlation."
            body_prefix = "## Enhanced Content\n\nThis version incorporates visual references automatically suggested through semantic similarity analysis between text and image embeddings.\n\n### Original Content\n\n"
        
        body = body_prefix + content
        
        # Generar referencias visuales con media_hint
        visual_references = []
        for rec in recommendations:
            image_id = rec.get("image_id", "")
            filename = rec.get("filename", "")
            score = rec.get("similarity_score", 0.0)
            
            # Generar textos según idioma
            if lang == "es":
                reason = f"Alta similitud visual ({score*100:.1f}%) con el tema de la página"
                suggested_alt = f"Escultura de bronce con acabado en {filename.replace('artwork_', '').replace('.jpg', '')}"
                suggested_caption = f"Proceso de fundición en RunArt Foundry - {title}"
            else:
                reason = f"High visual similarity ({score*100:.1f}%) with page topic"
                suggested_alt = f"Bronze sculpture with {filename.replace('artwork_', '').replace('.jpg', '')} finish"
                suggested_caption = f"Casting process at RunArt Foundry - {title}"
            
            visual_ref = {
                "image_id": image_id,
                "filename": filename,
                "similarity_score": score,
                "reason": reason,
                "suggested_alt": suggested_alt,
                "suggested_caption": suggested_caption,
                "media_hint": {
                    "original_name": filename,
                    "possible_wp_slug": filename.replace('.jpg', '').replace('.png', '').replace('_', '-'),
                    "confidence": score
                }
            }
            visual_references.append(visual_ref)
        
        # Generar tags
        tags = self._generate_tags(content, title, lang)
        
        enriched = {
            "headline": headline,
            "summary": summary,
            "body": body,
            "visual_references": visual_references,
            "tags": tags
        }
        
        return enriched
    
    def enrich_page(self, page_id: str, threshold: float = 0.0) -> Optional[Dict]:
        """
        Enriquece una página específica según estructura F9.
        
        Args:
            page_id: ID de la página (con o sin prefijo "page_")
            threshold: Umbral de similitud (default: 0.0 para dataset de prueba)
        
        Returns:
            Dict con el contenido enriquecido o None si no se encuentra
        """
        # Normalizar ID
        if not page_id.startswith("page_"):
            page_id = f"page_{page_id}"
        
        # Obtener datos fuente
        source_page = self._get_source_page(page_id)
        if not source_page:
            logger.warning(f"No se encontró página fuente para {page_id}")
            return None
        
        # Obtener recomendaciones
        recommendations = self.recommendations_cache.get("cache", {}).get(page_id, [])
        if not recommendations:
            logger.warning(f"No hay recomendaciones para {page_id}")
            recommendations = []  # Continuar con lista vacía
        
        # Filtrar por threshold
        filtered_recs = [r for r in recommendations if r.get("similarity_score", 0) >= threshold]
        
        lang = source_page.get("lang", "en")
        
        # Generar contenido enriquecido principal
        enriched_main = self._enrich_content(source_page, filtered_recs, lang)
        
        # Generar versión en otro idioma (bilingüe)
        other_lang = "en" if lang == "es" else "es"
        enriched_other = self._enrich_content(source_page, filtered_recs, other_lang)
        
        # Construir estructura final según especificación F9
        result = {
            "id": page_id,
            "source_text": source_page.get("content", ""),
            "lang": lang,
            f"enriched_{lang}": enriched_main,
            f"enriched_{other_lang}": enriched_other,
            "meta": {
                "generated_from": "F8-similarity",
                "similarity_threshold": threshold,
                "top_k": len(filtered_recs),
                "generated_at": datetime.now(timezone.utc).isoformat(),
                "needs_translation": True,
                "dataset_notes": "Dataset mixto: visual sintético (512D RGB), texto real (768D mpnet)",
                "production_threshold_recommended": 0.70
            }
        }
        
        return result
    
    def process_all_pages(self, threshold: float = 0.0):
        """
        Procesa todas las páginas del caché de recomendaciones.
        
        Args:
            threshold: Umbral de similitud
        """
        cache = self.recommendations_cache.get("cache", {})
        page_ids = list(cache.keys())
        
        logger.info(f"Procesando {len(page_ids)} páginas con threshold={threshold}")
        
        processed_pages = []
        
        for page_id in page_ids:
            logger.info(f"Enriqueciendo {page_id}...")
            enriched = self.enrich_page(page_id, threshold)
            
            if enriched:
                # Guardar archivo individual
                output_file = self.output_path / f"{page_id}.json"
                self._save_json(enriched, output_file)
                
                processed_pages.append({
                    "page_id": page_id,
                    "lang": enriched.get("lang"),
                    "title": self._get_source_page(page_id).get("title") if self._get_source_page(page_id) else "",
                    "visual_references_count": len(enriched.get(f"enriched_{enriched.get('lang')}", {}).get("visual_references", []))
                })
        
        # Crear índice
        index = {
            "version": "1.0",
            "generated_at": datetime.now(timezone.utc).isoformat(),
            "total_pages": len(processed_pages),
            "threshold_used": threshold,
            "pages": processed_pages,
            "output_directory": "data/assistants/rewrite/",
            "notes": "F9 - Reescritura Asistida y Enriquecimiento basado en correlaciones F8 (dataset mixto)"
        }
        
        index_file = self.output_path / "index.json"
        self._save_json(index, index_file)
        
        logger.info(f"✅ F9 completado: {len(processed_pages)} páginas enriquecidas")
        logger.info(f"   Archivos generados en: {self.output_path}")
        logger.info(f"   Índice: {index_file}")


def main():
    """Función principal para ejecutar desde CLI."""
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Reescritura Asistida y Enriquecimiento (F9) - V2"
    )
    parser.add_argument(
        "--page-id",
        help="ID de página específica a procesar (ej: 42, page_42)"
    )
    parser.add_argument(
        "--threshold",
        type=float,
        default=0.0,
        help="Umbral de similitud (default: 0.0 para dataset de prueba)"
    )
    parser.add_argument(
        "--all",
        action="store_true",
        help="Procesar todas las páginas"
    )
    
    args = parser.parse_args()
    
    enricher = ContentEnricherV2()
    
    if args.page_id:
        # Procesar página individual
        result = enricher.enrich_page(args.page_id, args.threshold)
        if result:
            output_file = enricher.output_path / f"{result['id']}.json"
            enricher._save_json(result, output_file)
            print(f"✅ Página {args.page_id} enriquecida -> {output_file}")
        else:
            print(f"❌ No se pudo enriquecer la página {args.page_id}")
    elif args.all:
        # Procesar todas
        enricher.process_all_pages(args.threshold)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
