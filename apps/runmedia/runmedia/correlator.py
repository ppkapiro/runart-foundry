#!/usr/bin/env python3
"""
Correlator — Cálculo de Similitud Semántica Texto↔Imagen

Módulo para calcular similitud coseno entre embeddings textuales e imágenes,
y generar recomendaciones top-K de imágenes para cada página.

Autor: automation-runart
Fase: F7 — Arquitectura IA-Visual
Fecha: 2025-10-30
"""

import json
import logging
import numpy as np
from pathlib import Path
from datetime import datetime, timezone
from typing import Dict, List, Optional

try:
    from sklearn.metrics.pairwise import cosine_similarity
    SKLEARN_AVAILABLE = True
except ImportError:
    SKLEARN_AVAILABLE = False
    logging.warning("scikit-learn not installed. Using numpy fallback.")

# Configuración
VISUAL_EMBEDDINGS_DIR = Path("data/embeddings/visual/clip_512d/embeddings")
TEXT_EMBEDDINGS_DIR = Path("data/embeddings/text/multilingual_mpnet/embeddings")
SIMILARITY_MATRIX_PATH = Path("data/embeddings/correlations/similarity_matrix.json")
RECOMMENDATIONS_CACHE_PATH = Path("data/embeddings/correlations/recommendations_cache.json")
DEFAULT_THRESHOLD = 0.70
DEFAULT_TOP_K = 5

# Logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


class Correlator:
    """
    Correlacionador que calcula similitud semántica texto↔imagen.
    
    Attributes:
        visual_dir: Directorio con embeddings visuales
        text_dir: Directorio con embeddings textuales
        threshold: Umbral mínimo de similitud (0.0-1.0)
        top_k: Número máximo de recomendaciones por página
    """
    
    def __init__(self, 
                 visual_dir: Optional[Path] = None,
                 text_dir: Optional[Path] = None,
                 threshold: float = DEFAULT_THRESHOLD,
                 top_k: int = DEFAULT_TOP_K):
        """
        Inicializa el correlacionador.
        
        Args:
            visual_dir: Directorio con embeddings visuales
            text_dir: Directorio con embeddings textuales
            threshold: Umbral de similitud mínimo
            top_k: Número de recomendaciones top
        """
        self.visual_dir = visual_dir or VISUAL_EMBEDDINGS_DIR
        self.text_dir = text_dir or TEXT_EMBEDDINGS_DIR
        self.threshold = threshold
        self.top_k = top_k
        
        self.visual_embeddings = {}
        self.text_embeddings = {}
        
        logger.info(f"Correlator inicializado (threshold={threshold}, top_k={top_k})")
    
    def load_embeddings(self):
        """
        Carga todos los embeddings visuales y textuales desde disco.
        """
        logger.info("📂 Cargando embeddings...")
        
        # Cargar embeddings visuales
        if self.visual_dir.exists():
            visual_files = list(self.visual_dir.glob("*.json"))
            for vf in visual_files:
                try:
                    with open(vf, 'r', encoding='utf-8') as f:
                        data = json.load(f)
                        self.visual_embeddings[data['id']] = {
                            'embedding': np.array(data['embedding']),
                            'filename': data['source']['filename'],
                            'metadata': data['metadata']
                        }
                except Exception as e:
                    logger.warning(f"⚠️ Error cargando {vf}: {e}")
            
            logger.info(f"✅ {len(self.visual_embeddings)} embeddings visuales cargados")
        else:
            logger.warning(f"⚠️ Directorio visual no existe: {self.visual_dir}")
        
        # Cargar embeddings textuales
        if self.text_dir.exists():
            text_files = list(self.text_dir.glob("*.json"))
            for tf in text_files:
                try:
                    with open(tf, 'r', encoding='utf-8') as f:
                        data = json.load(f)
                        self.text_embeddings[data['id']] = {
                            'embedding': np.array(data['embedding']),
                            'title': data['source']['title'],
                            'language': data['source']['language'],
                            'page_id': data['source'].get('page_id')
                        }
                except Exception as e:
                    logger.warning(f"⚠️ Error cargando {tf}: {e}")
            
            logger.info(f"✅ {len(self.text_embeddings)} embeddings textuales cargados")
        else:
            logger.warning(f"⚠️ Directorio textual no existe: {self.text_dir}")
    
    def compute_cosine_similarity(self, vec1: np.ndarray, vec2: np.ndarray) -> float:
        """
        Calcula similitud coseno entre dos vectores.
        
        Args:
            vec1: Primer vector
            vec2: Segundo vector
            
        Returns:
            Similitud coseno (0.0-1.0)
        """
        if SKLEARN_AVAILABLE:
            # Usar sklearn (más rápido)
            similarity = cosine_similarity(vec1.reshape(1, -1), vec2.reshape(1, -1))[0][0]
        else:
            # Fallback con numpy
            dot_product = np.dot(vec1, vec2)
            norm1 = np.linalg.norm(vec1)
            norm2 = np.linalg.norm(vec2)
            similarity = dot_product / (norm1 * norm2) if norm1 > 0 and norm2 > 0 else 0.0
        
        return float(similarity)
    
    def recommend_images_for_page(self, page_id: str, top_k: Optional[int] = None,
                                  threshold: Optional[float] = None) -> List[Dict]:
        """
        Recomienda imágenes relevantes para una página basándose en similitud semántica.
        
        Args:
            page_id: ID de la página (ej: "page_42")
            top_k: Número de recomendaciones (default: self.top_k)
            threshold: Umbral de similitud (default: self.threshold)
            
        Returns:
            Lista de recomendaciones ordenadas por similitud descendente
        """
        top_k = top_k or self.top_k
        threshold = threshold or self.threshold
        
        if page_id not in self.text_embeddings:
            logger.warning(f"⚠️ Página no encontrada: {page_id}")
            return []
        
        if not self.visual_embeddings:
            logger.warning("⚠️ No hay embeddings visuales disponibles")
            return []
        
        logger.info(f"🔍 Generando recomendaciones para {page_id}")
        
        page_embedding = self.text_embeddings[page_id]['embedding']
        recommendations = []
        
        # Calcular similitud con cada imagen
        for img_id, img_data in self.visual_embeddings.items():
            img_embedding = img_data['embedding']
            
            similarity = self.compute_cosine_similarity(page_embedding, img_embedding)
            
            if similarity >= threshold:
                recommendations.append({
                    'image_id': img_id,
                    'filename': img_data['filename'],
                    'similarity_score': round(similarity, 4),
                    'alt_text_suggestion': f"{self.text_embeddings[page_id]['title']} - {img_data['filename']}",
                    'reason': f"Semantic similarity: {round(similarity * 100, 1)}%"
                })
        
        # Ordenar por similitud descendente y tomar top-K
        recommendations.sort(key=lambda x: x['similarity_score'], reverse=True)
        recommendations = recommendations[:top_k]
        
        logger.info(f"✅ {len(recommendations)} recomendaciones generadas (threshold={threshold})")
        
        return recommendations
    
    def generate_similarity_matrix(self) -> Dict:
        """
        Genera la matriz completa de similitudes texto↔imagen.
        
        Returns:
            Diccionario con la matriz de similitudes
        """
        logger.info("🧮 Generando matriz de similitud completa...")
        
        if not self.text_embeddings or not self.visual_embeddings:
            logger.warning("⚠️ No hay embeddings suficientes para generar matriz")
            return {
                "version": "1.0",
                "generated_at": datetime.now(timezone.utc).isoformat(),
                "total_comparisons": 0,
                "threshold": self.threshold,
                "matrix": []
            }
        
        matrix_data = []
        total_comparisons = 0
        
        for page_id, page_data in self.text_embeddings.items():
            page_embedding = page_data['embedding']
            
            for img_id, img_data in self.visual_embeddings.items():
                img_embedding = img_data['embedding']
                
                similarity = self.compute_cosine_similarity(page_embedding, img_embedding)
                total_comparisons += 1
                
                if similarity >= self.threshold:
                    matrix_data.append({
                        'page_id': page_id,
                        'page_title': page_data['title'],
                        'image_id': img_id,
                        'image_filename': img_data['filename'],
                        'similarity_score': round(similarity, 4)
                    })
        
        matrix = {
            "version": "1.0",
            "generated_at": datetime.now(timezone.utc).isoformat(),
            "total_comparisons": total_comparisons,
            "above_threshold": len(matrix_data),
            "threshold": self.threshold,
            "matrix": matrix_data
        }
        
        logger.info(f"✅ Matriz generada: {total_comparisons} comparaciones, "
                   f"{len(matrix_data)} por encima del umbral")
        
        return matrix
    
    def generate_recommendations_cache(self) -> Dict:
        """
        Genera el cache de recomendaciones top-K para todas las páginas.
        
        Returns:
            Diccionario con el cache de recomendaciones
        """
        logger.info("💾 Generando cache de recomendaciones...")
        
        cache = {
            "version": "1.0",
            "generated_at": datetime.now(timezone.utc).isoformat(),
            "top_k": self.top_k,
            "threshold": self.threshold,
            "total_pages": len(self.text_embeddings),
            "cache": {}
        }
        
        for page_id in self.text_embeddings.keys():
            recommendations = self.recommend_images_for_page(page_id)
            cache["cache"][page_id] = recommendations
        
        pages_with_recommendations = sum(1 for recs in cache["cache"].values() if recs)
        logger.info(f"✅ Cache generado: {pages_with_recommendations}/{len(self.text_embeddings)} "
                   "páginas con recomendaciones")
        
        return cache
    
    def save_similarity_matrix(self, matrix: Dict, output_path: Optional[Path] = None):
        """
        Guarda la matriz de similitud en disco.
        
        Args:
            matrix: Diccionario con la matriz
            output_path: Ruta de salida (default: SIMILARITY_MATRIX_PATH)
        """
        output_path = output_path or SIMILARITY_MATRIX_PATH
        output_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(matrix, f, indent=2, ensure_ascii=False)
        
        logger.info(f"💾 Matriz de similitud guardada: {output_path}")
    
    def save_recommendations_cache(self, cache: Dict, output_path: Optional[Path] = None):
        """
        Guarda el cache de recomendaciones en disco.
        
        Args:
            cache: Diccionario con el cache
            output_path: Ruta de salida (default: RECOMMENDATIONS_CACHE_PATH)
        """
        output_path = output_path or RECOMMENDATIONS_CACHE_PATH
        output_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(cache, f, indent=2, ensure_ascii=False)
        
        logger.info(f"💾 Cache de recomendaciones guardado: {output_path}")
    
    def run_full_correlation(self):
        """
        Ejecuta el proceso completo de correlación: carga, cálculo y guardado.
        """
        logger.info("🚀 Iniciando proceso completo de correlación")
        
        # 1. Cargar embeddings
        self.load_embeddings()
        
        # 2. Generar matriz de similitud
        matrix = self.generate_similarity_matrix()
        self.save_similarity_matrix(matrix)
        
        # 3. Generar cache de recomendaciones
        cache = self.generate_recommendations_cache()
        self.save_recommendations_cache(cache)
        
        logger.info("✅ Proceso de correlación completado exitosamente")


def main():
    """Función principal para ejecutar desde CLI."""
    import argparse
    
    parser = argparse.ArgumentParser(description="Calcular correlaciones texto↔imagen")
    parser.add_argument('--threshold', type=float, default=DEFAULT_THRESHOLD,
                       help='Umbral de similitud mínimo (0.0-1.0)')
    parser.add_argument('--top-k', type=int, default=DEFAULT_TOP_K,
                       help='Número de recomendaciones top')
    parser.add_argument('--page-id', type=str, help='Generar recomendaciones para una página específica')
    
    args = parser.parse_args()
    
    # Crear correlator
    correlator = Correlator(threshold=args.threshold, top_k=args.top_k)
    
    # Procesar
    if args.page_id:
        # Modo individual
        correlator.load_embeddings()
        recommendations = correlator.recommend_images_for_page(args.page_id)
        
        print(f"\n📊 Recomendaciones para {args.page_id}:")
        for i, rec in enumerate(recommendations, 1):
            print(f"  {i}. {rec['filename']} (similitud: {rec['similarity_score']})")
    else:
        # Modo completo
        correlator.run_full_correlation()
        print("✅ Correlación completa generada")


if __name__ == "__main__":
    main()
