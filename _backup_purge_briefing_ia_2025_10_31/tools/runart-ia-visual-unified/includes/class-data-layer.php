<?php
/**
 * @file class-data-layer.php
 * @description Define métodos para gestionar rutas y lectura/escritura de datos IA-Visual.
 * @source Informe de Consolidación, sección 3.1
 * 
 * Responsabilidad:
 * - Resolución de rutas con cascada de prioridad (wp-content → uploads → plugin)
 * - Preparación de directorios de storage
 * - Lectura/escritura de archivos JSON (index.json, enriched-requests.json)
 * 
 * Métodos a implementar:
 * - get_data_bases(): Retorna array de rutas base posibles
 * - locate_file(string $relative_path): Busca archivo en cascada
 * - prepare_storage(): Crea directorios si no existen
 * - read_json(string $path): Lee y decodifica JSON
 * - write_json(string $path, array $data): Escribe JSON con lock
 */

if (!defined('ABSPATH')) {
    exit; // Exit if accessed directly
}

class RunArt_IA_Visual_Data_Layer {
    
    /**
     * Cache estático de rutas base.
     */
    private static $bases_cache = null;
    
    /**
     * Obtiene rutas base posibles para los artefactos IA (data/...).
     * Prioridad: repo (../data), wp-content/runart-data, uploads/runart-data, plugin/data.
     *
     * @return array<string,string>
     */
    public static function get_data_bases() {
        if (self::$bases_cache !== null) {
            return self::$bases_cache;
        }

        $bases = [];

        if (defined('WP_CONTENT_DIR')) {
            $bases['repo'] = trailingslashit(dirname(WP_CONTENT_DIR)) . 'data';
            $bases['wp_content'] = trailingslashit(WP_CONTENT_DIR) . 'runart-data';
            $bases['uploads'] = trailingslashit(WP_CONTENT_DIR) . 'uploads/runart-data';
        }

        $bases['plugin'] = trailingslashit(RUNART_IA_VISUAL_PLUGIN_DIR) . 'data';

        // Remover duplicados manteniendo prioridad
        $bases = array_unique($bases);

        self::$bases_cache = $bases;
        return $bases;
    }
    
    /**
     * Localiza un archivo o directorio en cascada de rutas base.
     *
     * @param string $relative_path Ruta relativa desde base (ej: 'assistants/rewrite/rewriter-01.txt')
     * @param string $type 'file' | 'dir'
     * @return array{found:bool,path:?string,source:string,paths_tried:array<int,string>}
     */
    public static function locate_file($relative_path, $type = 'file') {
        $relative_path = ltrim($relative_path, '/');
        $attempts = [];

        foreach (self::get_data_bases() as $label => $base) {
            $full = trailingslashit($base) . $relative_path;
            $attempts[] = $full;

            if ($type === 'dir') {
                if (is_dir($full)) {
                    return [
                        'found' => true,
                        'path' => trailingslashit($full),
                        'source' => $label,
                        'paths_tried' => $attempts,
                    ];
                }
            } else {
                if (file_exists($full)) {
                    return [
                        'found' => true,
                        'path' => $full,
                        'source' => $label,
                        'paths_tried' => $attempts,
                    ];
                }
            }
        }

        return [
            'found' => false,
            'path' => null,
            'source' => 'not-found',
            'paths_tried' => $attempts,
        ];
    }
    
    /**
     * Prepara directorios de storage (writable) si no existen.
     * Prefiere wp-content/runart-data, luego repo/../data.
     *
     * @param string $relative_path Ruta relativa dentro de data/
     * @return array{path:?string,source:string,paths_tried:array<int,string>}
     */
    public static function prepare_storage($relative_path) {
        $relative_path = ltrim($relative_path, '/');
        $preferred = ['wp_content', 'repo'];
        $bases = self::get_data_bases();
        $attempts = [];

        foreach ($preferred as $label) {
            if (!isset($bases[$label])) {
                continue;
            }

            $base = trailingslashit($bases[$label]);
            $full = $base . $relative_path;
            $dir = is_dir($full) ? $full : dirname($full);
            $attempts[] = $full;

            if (!is_dir($dir)) {
                if (function_exists('wp_mkdir_p')) {
                    wp_mkdir_p($dir);
                } else {
                    @mkdir($dir, 0755, true);
                }
            }

            if (is_dir($dir) && is_writable($dir)) {
                return [
                    'path' => $full,
                    'source' => $label,
                    'paths_tried' => $attempts,
                ];
            }
        }

        return [
            'path' => null,
            'source' => 'not-writable',
            'paths_tried' => $attempts,
        ];
    }
    
    /**
     * Lee archivo JSON y retorna array decodificado.
     *
     * @param string $path Path absoluto al archivo JSON
     * @return array|false Array decodificado o false en caso de error
     */
    public static function read_json($path) {
        // TODO: Implementar lectura con manejo de errores
        if (!file_exists($path)) {
            return false;
        }
        $content = file_get_contents($path);
        if ($content === false) {
            return false;
        }
        $decoded = json_decode($content, true);
        return is_array($decoded) ? $decoded : false;
    }
    
    /**
     * Escribe array a archivo JSON con atomic write.
     *
     * @param string $path Path absoluto al archivo JSON
     * @param array $data Datos a escribir
     * @return bool True si éxito, false si falla
     */
    public static function write_json($path, $data) {
        // TODO: Implementar escritura atómica con lock
        $json = json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        if ($json === false) {
            return false;
        }
        // Atomic write: escribir a temporal, luego rename
        $temp = $path . '.tmp';
        if (file_put_contents($temp, $json, LOCK_EX) === false) {
            return false;
        }
        return rename($temp, $path);
    }
}
