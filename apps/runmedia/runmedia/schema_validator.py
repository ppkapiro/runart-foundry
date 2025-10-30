#!/usr/bin/env python3
"""
Schema Validator — F10 Endurecimiento

Valida la estructura de los archivos JSON generados por el pipeline IA-Visual
(F8 embeddings/correlaciones, F9 contenido enriquecido) para prevenir datos
malformados y asegurar consistencia estructural.

Autor: automation-runart
Fase: F10 — Orquestación y Endurecimiento
Fecha: 2025-10-30
"""

import json
import logging
import sys
from pathlib import Path
from typing import Dict, List, Tuple, Any

# Configuración
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


class SchemaValidator:
    """
    Validador de esquemas para artefactos del pipeline IA-Visual.
    
    Valida:
    - data/embeddings/correlations/similarity_matrix.json
    - data/embeddings/correlations/recommendations_cache.json
    - data/assistants/rewrite/*.json
    """
    
    def __init__(self, base_path: Path = None):
        """
        Inicializa el validador.
        
        Args:
            base_path: Ruta base del proyecto (default: auto-detección)
        """
        if base_path is None:
            # Detectar ruta base (4 niveles arriba de este archivo)
            base_path = Path(__file__).parent.parent.parent.parent
        
        self.base_path = Path(base_path)
        self.errors = []
        self.warnings = []
        self.validated_files = []
    
    def validate_similarity_matrix(self, file_path: Path) -> bool:
        """
        Valida similarity_matrix.json.
        
        Esquema esperado:
        {
            "version": str,
            "generated_at": str (ISO),
            "total_comparisons": int,
            "above_threshold": int,
            "threshold": float,
            "matrix": [
                {
                    "page_id": str,
                    "page_title": str,
                    "image_id": str,
                    "image_filename": str,
                    "similarity_score": float
                }
            ]
        }
        """
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            # Validar campos requeridos de nivel superior
            required_fields = ['version', 'generated_at', 'total_comparisons', 'above_threshold', 'threshold', 'matrix']
            for field in required_fields:
                if field not in data:
                    self.errors.append(f"{file_path}: Missing required field '{field}'")
                    return False
            
            # Validar tipos
            if not isinstance(data['total_comparisons'], int):
                self.errors.append(f"{file_path}: 'total_comparisons' must be int")
                return False
            
            if not isinstance(data['above_threshold'], int):
                self.errors.append(f"{file_path}: 'above_threshold' must be int")
                return False
            
            if not isinstance(data['threshold'], (int, float)):
                self.errors.append(f"{file_path}: 'threshold' must be number")
                return False
            
            if not isinstance(data['matrix'], list):
                self.errors.append(f"{file_path}: 'matrix' must be array")
                return False
            
            # Validar elementos de la matriz
            for idx, item in enumerate(data['matrix']):
                required_item_fields = ['page_id', 'page_title', 'image_id', 'image_filename', 'similarity_score']
                for field in required_item_fields:
                    if field not in item:
                        self.errors.append(f"{file_path}: matrix[{idx}] missing field '{field}'")
                        return False
                
                if not isinstance(item['similarity_score'], (int, float)):
                    self.errors.append(f"{file_path}: matrix[{idx}] 'similarity_score' must be number")
                    return False
            
            # Validar coherencia
            if data['total_comparisons'] != len(data['matrix']):
                self.warnings.append(
                    f"{file_path}: total_comparisons ({data['total_comparisons']}) != actual matrix length ({len(data['matrix'])})"
                )
            
            self.validated_files.append(str(file_path))
            logger.info(f"✅ {file_path.name}: VALID (schema: similarity_matrix)")
            return True
            
        except json.JSONDecodeError as e:
            self.errors.append(f"{file_path}: Invalid JSON - {e}")
            return False
        except Exception as e:
            self.errors.append(f"{file_path}: Validation error - {e}")
            return False
    
    def validate_recommendations_cache(self, file_path: Path) -> bool:
        """
        Valida recommendations_cache.json.
        
        Esquema esperado:
        {
            "version": str,
            "generated_at": str (ISO),
            "top_k": int,
            "threshold": float,
            "total_pages": int,
            "cache": {
                "page_42": [
                    {
                        "image_id": str,
                        "filename": str,
                        "similarity_score": float,
                        "alt_text_suggestion": str,
                        "reason": str
                    }
                ]
            }
        }
        """
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            # Validar campos requeridos
            required_fields = ['version', 'generated_at', 'top_k', 'threshold', 'total_pages', 'cache']
            for field in required_fields:
                if field not in data:
                    self.errors.append(f"{file_path}: Missing required field '{field}'")
                    return False
            
            # Validar tipos
            if not isinstance(data['top_k'], int):
                self.errors.append(f"{file_path}: 'top_k' must be int")
                return False
            
            if not isinstance(data['threshold'], (int, float)):
                self.errors.append(f"{file_path}: 'threshold' must be number")
                return False
            
            if not isinstance(data['total_pages'], int):
                self.errors.append(f"{file_path}: 'total_pages' must be int")
                return False
            
            if not isinstance(data['cache'], dict):
                self.errors.append(f"{file_path}: 'cache' must be object")
                return False
            
            # Validar entradas del caché
            for page_id, recommendations in data['cache'].items():
                if not isinstance(recommendations, list):
                    self.errors.append(f"{file_path}: cache['{page_id}'] must be array")
                    return False
                
                for idx, rec in enumerate(recommendations):
                    required_rec_fields = ['image_id', 'filename', 'similarity_score']
                    for field in required_rec_fields:
                        if field not in rec:
                            self.errors.append(f"{file_path}: cache['{page_id}'][{idx}] missing field '{field}'")
                            return False
                    
                    if not isinstance(rec['similarity_score'], (int, float)):
                        self.errors.append(f"{file_path}: cache['{page_id}'][{idx}] 'similarity_score' must be number")
                        return False
            
            # Validar coherencia
            if data['total_pages'] != len(data['cache']):
                self.warnings.append(
                    f"{file_path}: total_pages ({data['total_pages']}) != actual cache entries ({len(data['cache'])})"
                )
            
            self.validated_files.append(str(file_path))
            logger.info(f"✅ {file_path.name}: VALID (schema: recommendations_cache)")
            return True
            
        except json.JSONDecodeError as e:
            self.errors.append(f"{file_path}: Invalid JSON - {e}")
            return False
        except Exception as e:
            self.errors.append(f"{file_path}: Validation error - {e}")
            return False
    
    def validate_rewrite_page(self, file_path: Path) -> bool:
        """
        Valida archivos de contenido enriquecido (page_*.json).
        
        Esquema esperado:
        {
            "id": str,
            "source_text": str,
            "lang": str,
            "enriched_es": {
                "headline": str,
                "summary": str,
                "body": str,
                "visual_references": [...],
                "tags": [...]
            },
            "enriched_en": { ... },
            "meta": {
                "generated_from": str,
                "similarity_threshold": float,
                "top_k": int,
                "generated_at": str (ISO)
            }
        }
        """
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            # Validar campos requeridos
            required_fields = ['id', 'lang', 'meta']
            for field in required_fields:
                if field not in data:
                    self.errors.append(f"{file_path}: Missing required field '{field}'")
                    return False
            
            # Validar que exista al menos un enriched_{lang}
            has_enriched = False
            for key in data.keys():
                if key.startswith('enriched_'):
                    has_enriched = True
                    # Validar estructura del enriched
                    enriched = data[key]
                    if not isinstance(enriched, dict):
                        self.errors.append(f"{file_path}: '{key}' must be object")
                        return False
                    
                    required_enriched_fields = ['headline', 'summary', 'body', 'visual_references', 'tags']
                    for field in required_enriched_fields:
                        if field not in enriched:
                            self.errors.append(f"{file_path}: '{key}' missing field '{field}'")
                            return False
                    
                    # Validar tipos
                    if not isinstance(enriched['visual_references'], list):
                        self.errors.append(f"{file_path}: '{key}.visual_references' must be array")
                        return False
                    
                    if not isinstance(enriched['tags'], list):
                        self.errors.append(f"{file_path}: '{key}.tags' must be array")
                        return False
                    
                    # Validar referencias visuales
                    for idx, vref in enumerate(enriched['visual_references']):
                        required_vref_fields = ['image_id', 'filename', 'similarity_score']
                        for field in required_vref_fields:
                            if field not in vref:
                                self.errors.append(f"{file_path}: '{key}.visual_references[{idx}]' missing field '{field}'")
                                return False
            
            if not has_enriched:
                self.errors.append(f"{file_path}: No 'enriched_*' fields found")
                return False
            
            # Validar meta
            if not isinstance(data['meta'], dict):
                self.errors.append(f"{file_path}: 'meta' must be object")
                return False
            
            required_meta_fields = ['generated_from', 'similarity_threshold', 'top_k', 'generated_at']
            for field in required_meta_fields:
                if field not in data['meta']:
                    self.errors.append(f"{file_path}: meta missing field '{field}'")
                    return False
            
            self.validated_files.append(str(file_path))
            logger.info(f"✅ {file_path.name}: VALID (schema: rewrite_page)")
            return True
            
        except json.JSONDecodeError as e:
            self.errors.append(f"{file_path}: Invalid JSON - {e}")
            return False
        except Exception as e:
            self.errors.append(f"{file_path}: Validation error - {e}")
            return False
    
    def validate_all(self) -> bool:
        """
        Valida todos los archivos del pipeline IA-Visual.
        
        Returns:
            True si todos los archivos son válidos, False si hay errores
        """
        logger.info("🔍 Starting AI-Visual schema validation...")
        logger.info(f"   Base path: {self.base_path}")
        
        all_valid = True
        
        # 1. Validar similarity_matrix.json
        similarity_matrix_path = self.base_path / "data/embeddings/correlations/similarity_matrix.json"
        if similarity_matrix_path.exists():
            if not self.validate_similarity_matrix(similarity_matrix_path):
                all_valid = False
        else:
            self.warnings.append(f"{similarity_matrix_path}: File not found (skipping)")
            logger.warning(f"⚠️  {similarity_matrix_path.name}: NOT FOUND (skipping)")
        
        # 2. Validar recommendations_cache.json
        recommendations_cache_path = self.base_path / "data/embeddings/correlations/recommendations_cache.json"
        if recommendations_cache_path.exists():
            if not self.validate_recommendations_cache(recommendations_cache_path):
                all_valid = False
        else:
            self.warnings.append(f"{recommendations_cache_path}: File not found (skipping)")
            logger.warning(f"⚠️  {recommendations_cache_path.name}: NOT FOUND (skipping)")
        
        # 3. Validar archivos de rewrite
        rewrite_dir = self.base_path / "data/assistants/rewrite"
        if rewrite_dir.exists() and rewrite_dir.is_dir():
            rewrite_files = list(rewrite_dir.glob("page_*.json"))
            if rewrite_files:
                for file_path in rewrite_files:
                    if not self.validate_rewrite_page(file_path):
                        all_valid = False
            else:
                self.warnings.append(f"{rewrite_dir}: No page_*.json files found")
                logger.warning(f"⚠️  {rewrite_dir}/page_*.json: NO FILES FOUND")
        else:
            self.warnings.append(f"{rewrite_dir}: Directory not found (skipping)")
            logger.warning(f"⚠️  {rewrite_dir}: DIRECTORY NOT FOUND (skipping)")
        
        # Resumen
        logger.info("")
        logger.info("=" * 60)
        logger.info("VALIDATION SUMMARY")
        logger.info("=" * 60)
        logger.info(f"✅ Validated files: {len(self.validated_files)}")
        logger.info(f"⚠️  Warnings: {len(self.warnings)}")
        logger.info(f"❌ Errors: {len(self.errors)}")
        
        if self.warnings:
            logger.info("")
            logger.info("Warnings:")
            for warning in self.warnings:
                logger.warning(f"  - {warning}")
        
        if self.errors:
            logger.info("")
            logger.info("Errors:")
            for error in self.errors:
                logger.error(f"  - {error}")
        
        logger.info("=" * 60)
        
        if all_valid:
            logger.info("✅ ALL SCHEMAS VALID")
            return True
        else:
            logger.error("❌ SCHEMA VALIDATION FAILED")
            return False


def main():
    """Función principal para CLI."""
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Schema Validator - F10 AI-Visual Pipeline"
    )
    parser.add_argument(
        '--validate-all',
        action='store_true',
        help='Validar todos los archivos del pipeline IA-Visual'
    )
    parser.add_argument(
        '--base-path',
        type=str,
        help='Ruta base del proyecto (default: auto-detección)'
    )
    
    args = parser.parse_args()
    
    if not args.validate_all:
        parser.print_help()
        sys.exit(1)
    
    base_path = Path(args.base_path) if args.base_path else None
    validator = SchemaValidator(base_path)
    
    success = validator.validate_all()
    
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
