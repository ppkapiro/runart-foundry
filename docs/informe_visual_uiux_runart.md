# Informe Visual UI/UX — RUN Art Foundry

**Fecha de análisis:** 28 de octubre de 2025  
**Entorno analizado:** staging.runartfoundry.com  
**Idiomas:** Español (ES) / English (EN)  
**Responsable:** Equipo RUN + GitHub Copilot  
**Estado:** Investigación base para planificación UI/UX

---

## Resumen Ejecutivo

Este informe documenta el estado visual actual del sitio web de RUN Art Foundry en staging, identificando fortalezas, deficiencias y oportunidades de mejora visual. El análisis se realizó sobre ambas versiones idiomáticas (ES/EN) con el objetivo de establecer una base sólida para una futura fase de rediseño UI/UX y curaduría de imágenes.

**Hallazgos principales:**
- ✅ Estructura de navegación bilingüe funcional y consistente
- ⚠️ Ausencia crítica de imágenes en la mayoría de las páginas clave
- ⚠️ Identidad visual minimalista presente pero infrautilizada
- ⚠️ Bajo aprovechamiento del inventario de 6,162 imágenes disponibles
- ⚠️ Página de Blog completamente vacía (oportunidad crítica)
- ⚠️ Páginas de servicios y proyectos sin imágenes de proceso ni técnicas

---

## A. Estado Visual de las Páginas Clave

### 1. Home / Inicio

**URLs:**
- EN: `https://staging.runartfoundry.com/`
- ES: `https://staging.runartfoundry.com/es/inicio/`

**Estado visual:**
- **Contenido textual:** ✅ Excelente copy con jerarquía clara
- **Hero section:** ⚠️ Sin imagen hero visible
- **Imágenes actuales:** Ninguna imagen de proyectos visible en la vista capturada
- **Shortcodes presentes:** 
  - `[shortcode: latest 6 projects]` → No renderizado visiblemente
  - `[shortcode: latest 3 testimonials with video]` → No renderizado
  - `[shortcode: latest 3 posts]` → No renderizado

**Jerarquía visual:**
- Estructura sectorial clara (Proyectos Destacados, Servicios, Testimonios, Blog)
- Separación conceptual correcta
- CTA buttons presentes ("Inicia tu consultoría", "Ver proyectos")
- Estadísticas numéricas (40+ años, 500+ proyectos, 50+ artistas, 15 países)

**Problemas identificados:**
1. **Sin hero visual impactante** - La página de inicio debería abrir con una imagen potente de fundición, escultura o taller
2. **Shortcodes no funcionan** - Los elementos dinámicos (proyectos, testimonios, posts) no se renderizan
3. **Falta imagen de marca** - No hay presencia visual del logo, instalaciones o identidad corporativa
4. **Secciones planas** - Sin contraste visual entre bloques de contenido

**Imágenes recomendadas:**
- Hero: Escultura monumental en proceso de fundición (bronce líquido cayendo) o pieza terminada con iluminación dramática
- Sección proyectos: 6 imágenes de proyectos destacados con artista/título
- Sección servicios: Íconos o imágenes representativas de cada servicio
- Sección testimonios: Fotos/videos de clientes o proceso de trabajo
- Galería de taller: 2-3 imágenes del espacio de trabajo

**Rutas sugeridas (desde inventario RunMedia):**
- `content/media/library/projects/run-art-foundry-branding/runartfoundry-home.jpg` (existe, 1813×1196)
- Proyectos: williams-carmona, roberto-fabelo, carole-feuerman, oliva, arquidiocesis

---

### 2. About / Sobre nosotros

**URLs:**
- EN: `https://staging.runartfoundry.com/about/`
- ES: `https://staging.runartfoundry.com/es/sobre-nosotros/`

**Estado visual:**
- **Contenido textual:** ✅ Copy sólido sobre misión, experiencia, técnicas y equipo
- **Imágenes actuales:** 0 imágenes visibles
- **Estructura:** Cuatro subsecciones claras (Misión, Experiencia, Técnicas, Equipo)

**Jerarquía visual:**
- Texto bien estructurado con H2/H3
- Separación conceptual correcta
- Sin elementos visuales que refuercen el mensaje

**Problemas identificados:**
1. **Página completamente textual** - No hay conexión visual con el taller, equipo o procesos
2. **Sin fotos del equipo** - Debería humanizar la empresa
3. **Sin imágenes del taller** - Oportunidad perdida de mostrar instalaciones
4. **Falta timeline visual** - Los "40+ años de experiencia" deberían tener peso visual

**Imágenes recomendadas:**
- Header: Foto panorámica del taller con hornos y área de trabajo
- Sección Misión: Imagen conceptual de escultor trabajando con el equipo de fundición
- Sección Experiencia: Timeline visual con proyectos icónicos (collage)
- Sección Técnicas: 4 imágenes de procesos clave (cera perdida, pátinas, restauración, ediciones)
- Sección Equipo: Foto del equipo completo o collage de maestros fundidores trabajando

**Tipos de imagen necesarios:**
- Retrato de equipo (grupo)
- Instalaciones (taller/hornos/áreas de trabajo)
- Proceso técnico (fundición activa)
- Detalle artesanal (manos trabajando)

---

### 3. Services / Servicios

**URLs:**
- EN: `https://staging.runartfoundry.com/services/` (⚠️ 404 - "Nothing Found")
- ES: `https://staging.runartfoundry.com/es/services/` (✅ Funcional)

**Estado visual (ES):**
- **Contenido:** 5 servicios listados con descripción breve
- **Imágenes actuales:** 0 imágenes visibles
- **Estructura:** Grid de servicios con título, descripción corta y enlace "Ver detalles"

**Servicios listados:**
1. Fundición Artística en Bronce
2. Pátinas y Acabados Especializados
3. Restauración de Esculturas Históricas
4. Consultoría Técnica en Fundición
5. Ediciones Limitadas en Bronce

**Jerarquía visual:**
- Estructura de lista clara
- Separación por servicio
- CTA presente ("Contactar ahora", "Ver proyectos")

**Problemas identificados:**
1. **Versión EN rota** - La página en inglés devuelve 404 (problema crítico de contenido)
2. **Sin imágenes de procesos** - Cada servicio debería tener imagen representativa
3. **Cards sin diferenciación visual** - Todos los servicios lucen idénticos (solo texto)
4. **Falta iconografía** - Los servicios podrían beneficiarse de íconos o símbolos

**Imágenes recomendadas por servicio:**
1. **Fundición Artística:** Bronce líquido siendo vertido en molde / Pieza en cera
2. **Pátinas:** Close-up de superficie con pátina verde o policromía / Aplicación con soplete
3. **Restauración:** Before/After de pieza histórica / Detalle de intervención
4. **Consultoría:** Planos técnicos sobre mesa / Reunión con artista
5. **Ediciones Limitadas:** Serie numerada de piezas idénticas / Sello de certificación

**Tipos de imagen necesarios:**
- Proceso técnico (fundición, aplicación de pátina, soldadura)
- Detalle de materiales (bronce líquido, cera, cerámica)
- Resultado final (piezas terminadas con distintos acabados)
- Trabajo artesanal (manos del equipo)

---

### 4. Projects / Proyectos

**URLs:**
- EN: `https://staging.runartfoundry.com/projects/`
- ES: `https://staging.runartfoundry.com/es/projects/`

**Estado visual:**
- **Contenido:** 5 proyectos listados con descripción breve
- **Imágenes actuales:** 0 imágenes visibles en el listado
- **Estructura:** Lista vertical de proyectos con título, extracto y enlace "Ver proyecto"

**Proyectos listados:**
1. Monumento Williams Carmona — Fundición Monumental
2. Roberto Fabelo — Escultura en Bronce Patinado
3. Carole Feuerman — Fundición Hiperrealista
4. Escultura Monumental Oliva — Fundición Urbana
5. Arquidiócesis de La Habana — Restauración Patrimonio Religioso

**Jerarquía visual:**
- Títulos descriptivos claros
- Extractos informativos con técnicas mencionadas
- Sin diferenciación visual entre proyectos

**Problemas identificados:**
1. **Lista sin imágenes** - Cada proyecto debería tener imagen thumbnail
2. **No hay grid visual** - Debería ser una galería con imágenes prominentes
3. **Falta categorización visual** - No se distinguen proyectos monumentales de restauración
4. **Sin información del artista** - No hay fotos ni contexto visual de los artistas colaboradores

**Imágenes recomendadas:**
- **Thumbnail por proyecto** (mínimo 1 imagen destacada por proyecto)
- **Formato sugerido:** 4:3 o 16:9 para grid responsive
- **Vista ideal:** Pieza terminada en su contexto (espacio público, galería, taller)
- **Alternativas:** Proceso de fundición, detalle de textura, escala humana

**Observación crítica:**
RunMedia tiene 26 proyectos identificados en las reglas de asociación:
- alexander-arrechea
- american-dream
- armonia
- ballerina
- carlos-manuel-cespedes
- clementina
- contra-corriente
- durga-ma
- el-beso
- el-equilibrio
- el-gran-viaje
- el-rapto-de-micaela
- el-saltamonte
- eva
- guajiro-reide-molina
- la-gran-carroza
- la-lira
- la-reflexion
- maquina-de-coser
- maximo-gomez
- mujer-con-pajaros
- poco-de-nosotros
- roberto-estupinan
- run-art-foundry-branding
- serena
- suenos-de-lucas
- viaje-fantastico-fabelo

**Solo 5 proyectos están publicados en el sitio.** Hay 21 proyectos adicionales en el inventario de imágenes que no están en el sitio web.

---

### 5. Project Single / Proyecto Individual

**URL analizada:**
- `https://staging.runartfoundry.com/es/projects/monumento-williams-carmona-fundicion-monumental-en-bronce-2/`

**Estado visual:**
- **Contenido:** Descripción técnica detallada del proyecto
- **Imágenes actuales:** 0 imágenes visibles
- **Estructura:** Texto corrido con sección "Ficha Técnica"

**Contenido textual:**
- Descripción del proceso (molde perdido, aleación Cu-Sn 85-15)
- Análisis técnico (estructural, fundición, pátina)
- CTA final ("Inicia tu consulta", "Ver servicios")

**Problemas identificados:**
1. **Sin galería de imágenes** - Es la página más crítica y no tiene ninguna imagen
2. **Sin imagen principal del proyecto** - Debería ser lo primero visible
3. **Sin documentación del proceso** - Oportunidad perdida de mostrar paso a paso
4. **Sin escala humana** - No se aprecia dimensión monumental
5. **Sin contexto de instalación** - ¿Dónde está ubicada la escultura?

**Imágenes recomendadas para página de proyecto:**
1. **Hero image:** Pieza terminada instalada en su ubicación final
2. **Galería de proceso:**
   - Modelo en cera
   - Aplicación de cáscara cerámica
   - Fundición activa (bronce líquido)
   - Pieza recién fundida
   - Proceso de acabado/pátina
   - Instalación final
3. **Detalles técnicos:** Close-ups de textura, soldaduras, pátina
4. **Escala:** Foto con personas para apreciar dimensiones
5. **Contexto:** Vista del espacio donde está instalada

**Tipo de galería sugerida:**
- Hero full-width + galería de 6-12 imágenes en grid 3×4
- Lightbox para ver imágenes en tamaño completo
- Captions con descripción técnica de cada fase

---

### 6. Blog

**URLs:**
- EN: `https://staging.runartfoundry.com/blog/`
- ES: `https://staging.runartfoundry.com/es/blog-es/`

**Estado visual:**
- **Contenido:** ⚠️ **COMPLETAMENTE VACÍO**
- **Estructura:** Solo título "Blog" y footer
- **Imágenes actuales:** 0 imágenes

**Problemas identificados:**
1. **Página vacía** - No hay artículos publicados
2. **Oportunidad crítica perdida** - El blog debería ser el centro de contenido educativo/técnico
3. **Sin recursos visuales** - Debería tener artículos con imágenes técnicas

**Observación importante:**
El Home menciona "Recursos Técnicos - Guías completas sobre fundición, aleaciones y conservación del bronce" con un shortcode `[latest 3 posts]`, pero el blog está vacío.

**Contenido potencial (observable en el Home ES):**
Hay 3 artículos técnicos escritos (pero no publicados como posts del blog):
1. **"Guía Completa de Aleaciones de Bronce"**
   - Composiciones y propiedades
   - Bronce Artístico (Cu-Sn 85-15)
   - Bronce Monumental (Cu-Sn 88-12)
   - Factores de selección
   
2. **"Fundición a la Cera Perdida"**
   - Historia del método
   - 6 pasos del proceso (con descripciones detalladas)
   - Ventajas de la técnica
   
3. **"Pátinas en Bronce"**
   - Química de las pátinas
   - Tipos (verde, café-rojiza, negra)
   - Técnicas de aplicación
   - Mantenimiento

**Recomendación urgente:**
Estos artículos deberían convertirse en posts del blog con imágenes de:
- Muestras de aleaciones
- Proceso paso a paso fotografiado
- Muestras de pátinas (antes/después)
- Diagramas técnicos
- Infografías

---

### 7. Contact / Contacto

**URLs:**
- EN: `https://staging.runartfoundry.com/contact/`
- ES: `https://staging.runartfoundry.com/es/contacto/`

**Estado visual:**
- **Contenido:** Formulario de contacto funcional
- **Imágenes actuales:** 0 imágenes
- **Estructura:** Formulario simple con campos estándar

**Campos del formulario:**
- Nombre completo *
- Correo electrónico *
- Teléfono
- Empresa u organización
- ¿Cómo podemos ayudarte? *
- Aceptación de política de privacidad *

**Problemas identificados:**
1. **Sin información visual de ubicación** - No hay mapa ni foto del taller
2. **Sin datos de contacto visibles** - No se muestra dirección, teléfono o email directo
3. **Página muy austera** - Debería inspirar confianza con elementos visuales

**Imágenes recomendadas:**
- Foto del taller desde exterior
- Mapa de ubicación (Google Maps embed o imagen)
- Foto del área de recepción/consultoría
- Imagen de confianza (certificaciones, equipo trabajando)

---

### 8. Service Single / Servicio Individual

**No se pudo analizar página individual de servicio** - Los enlaces conducen a URLs con `-2` al final (ej: `fundicion-artistica-en-bronce-2/`), pero no se cargó contenido específico.

**Expectativa:**
Similar a Project Single, cada servicio debería tener:
- Descripción ampliada del proceso
- Galería de imágenes del proceso específico
- Casos de uso / ejemplos
- Beneficios técnicos
- CTA para consulta

---

### 9. Testimonials / Testimonios

**No existe página dedicada** - Solo se menciona en el Home con shortcode `[latest 3 testimonials with video]` que no se renderiza.

**Recomendación:**
Si existe contenido de testimonios, debería tener:
- Página de archivo de testimonios
- Fotos de clientes (si autorizan)
- Videos testimoniales
- Logos de instituciones/galerías colaboradoras

---

## B. Uso Actual de Imágenes en el Sitio

### Inventario de Imágenes Visibles

**Total de imágenes visibles en las páginas analizadas: 0**

Ninguna de las páginas principales analizadas muestra imágenes de forma visible:
- Home: shortcodes no renderizados
- About: texto puro
- Services: lista textual
- Projects: lista textual sin thumbnails
- Project Single: descripción sin imágenes
- Blog: vacío
- Contact: formulario sin contexto visual

### Asociación de Imágenes con Contenido

**Estado actual (según RunMedia):**
- **Total de imágenes inventariadas:** 6,162
- **Imágenes huérfanas:** 672 (10.9%)
- **Imágenes asociadas a proyectos:** 5,490 (~89%)
- **Imágenes asociadas a servicios:** Desconocido (no cuantificado separadamente)
- **Imágenes con ALT text:** 0 (100% requieren curación)

**Proyectos con imágenes clasificadas (26):**
Todos los proyectos identificados en `association_rules.yaml` tienen imágenes asociadas en el índice de RunMedia, pero solo 5 están publicados en el sitio web.

**Problema crítico identificado:**
Existe un desacople total entre:
1. **Inventario de imágenes** (6,162 imágenes clasificadas en RunMedia)
2. **Uso en el sitio web** (0 imágenes visibles en las páginas analizadas)

### Imágenes Generadas por RunMedia

**Variantes optimizadas:**
- **Test realizado:** 20 imágenes × 10 variantes = 200 archivos
- **Formatos:** WebP + AVIF
- **Tamaños:** 2560px, 1600px, 1200px, 800px, 400px
- **Ubicación:** `content/media/variants/<id>/{webp,avif}/w{width}.{ext}`

**Estado:**
Las variantes optimizadas existen pero no están siendo servidas por el sitio web. No hay integración activa entre el repositorio de imágenes y el sitio WordPress en staging.

### Espacios que Deberían Tener Imágenes

**Críticos (ausencia total):**
1. ✅ **Home hero** - Debe tener imagen principal impactante
2. ✅ **Home sections** - Proyectos, servicios, testimonios sin imágenes
3. ✅ **About page** - Sin fotos de equipo, taller o procesos
4. ✅ **Services listing** - Sin imágenes representativas por servicio
5. ✅ **Projects listing** - Sin thumbnails de proyectos
6. ✅ **Project single** - Sin galería de proceso ni resultado
7. ✅ **Blog** - Vacío (sin artículos con imágenes)
8. ✅ **Contact** - Sin mapa ni foto de ubicación

**Secundarios (mejorarían UX):**
- Footer: Logo, certificaciones, partners
- Navegación: Iconos de servicios
- CTAs: Imágenes de fondo sutiles
- Testimonios: Fotos de clientes/artistas

---

## C. Evaluación de Identidad Visual (UI/UX General)

### Esquema de Color: Rojo/Negro

**Observado:**
- ⚠️ **No se observa implementación clara del esquema rojo/negro** en el HTML capturado
- El contenido es primariamente textual sin elementos visuales que evidencien la paleta de colores
- Footer muestra copyright estándar sin branding visual aparente

**Recomendación:**
Sin acceso a CSS o screenshots, no se puede validar si la paleta rojo/negro está implementada. Se requiere:
1. Análisis de CSS activo
2. Screenshots de navegación, headers, CTAs, hover states
3. Revisión de consistencia en todos los breakpoints

**Identidad esperada:**
- **Rojo:** Acentos, CTAs, hover states, detalles (reminiscente del bronce fundido/calor)
- **Negro:** Fondo principal, texto, navegación (elegancia/minimalismo técnico)
- **Blanco:** Texto sobre fondos oscuros, espacios de respiro
- **Grises:** Tonos neutros para estructura secundaria

### Tipografía y Jerarquía

**Observado:**
✅ **Jerarquía textual correcta:**
- Uso apropiado de H1, H2, H3 en la estructura del contenido
- Títulos descriptivos y claros
- Extractos concisos con información relevante
- Separación conceptual entre secciones

**Fortalezas:**
- Copy profesional con terminología técnica apropiada
- Estructura de información lógica y escaneable
- CTAs claros y orientados a acción

**Áreas de mejora:**
- Sin contraste visual en headings (probable falta de color/peso)
- No se aprecia uso de tipografía display vs body (requiere análisis CSS)
- Falta énfasis visual en números/estadísticas (40+ años, 500+ proyectos)

### Personalidad Técnica/Artística

**¿Se refleja la identidad del taller?**

**Fortalezas conceptuales:**
- ✅ Lenguaje técnico preciso (aleaciones Cu-Sn, molde perdido, pátinas químicas)
- ✅ Énfasis en calidad y tradición (40+ años, técnicas ancestrales)
- ✅ Positioning claro (excelencia, alta calidad, metodología científica)

**Deficiencias visuales:**
- ⚠️ **Sin evidencia visual del taller** - No se muestra el espacio de trabajo ni maquinaria
- ⚠️ **Sin presencia artística** - No hay imágenes de artistas colaboradores ni obras
- ⚠️ **Sin documentación de proceso** - El proceso técnico no está visualmente respaldado
- ⚠️ **Sin calidez humana** - No hay rostros, equipo ni personalidad detrás de la fundición

**¿Transmite confianza?**
- **Texto:** ✅ Copy profesional y detallado
- **Visual:** ❌ Falta de evidencia fotográfica que respalde las afirmaciones

**¿Transmite detalle técnico?**
- **Texto:** ✅ Especificaciones técnicas precisas (aleaciones, temperaturas, procesos)
- **Visual:** ❌ Sin diagramas, infografías o fotografías técnicas

**¿Transmite creatividad?**
- **Texto:** ✅ Menciona colaboraciones con artistas reconocidos
- **Visual:** ❌ Sin galería de obras, sin muestras de versatilidad artística

### Diseño Minimalista

**Evaluación:**
- ✅ **Minimalismo textual logrado:** Contenido claro, sin saturación
- ⚠️ **Minimalismo visual excesivo:** Ausencia total de elementos visuales
- ⚠️ **Riesgo de austeridad:** El sitio puede percibirse como incompleto o en construcción

**Equilibrio recomendado:**
Un diseño minimalista NO significa ausencia de imágenes. Debería significar:
- Imágenes de alta calidad, seleccionadas estratégicamente
- Espacios blancos generosos alrededor de elementos visuales
- Composiciones limpias sin saturación
- Jerarquía visual clara con pocos elementos competiendo por atención

---

## D. Recomendaciones Inmediatas

### Prioridad 1: CRÍTICAS (implementar antes de producción)

1. **Home Hero Image**
   - **Urgencia:** ALTA
   - **Imagen sugerida:** Fundición activa (bronce líquido, iluminación dramática) o escultura monumental terminada
   - **Fuente:** `runartfoundry-home.jpg` existe en inventario (1813×1196)
   - **Impacto:** Primera impresión del sitio, elemento más crítico para engagement

2. **Projects Gallery (Listado)**
   - **Urgencia:** ALTA
   - **Acción:** Agregar thumbnail a cada proyecto (mínimo 300×225px)
   - **Fuente:** RunMedia tiene imágenes clasificadas para 26 proyectos, usar 1 imagen destacada por proyecto publicado
   - **Impacto:** Los proyectos son el corazón del portfolio, deben ser visualmente impactantes

3. **Project Single Gallery**
   - **Urgencia:** ALTA
   - **Acción:** Implementar galería de 6-12 imágenes por proyecto mostrando proceso completo
   - **Fuente:** Seleccionar de imágenes asociadas al proyecto en RunMedia
   - **Impacto:** Demuestra capacidad técnica y calidad del trabajo

4. **About Page - Taller/Equipo**
   - **Urgencia:** ALTA
   - **Acción:** Agregar 3-5 imágenes clave (taller panorámico, equipo, proceso)
   - **Tipo:** Instalaciones, retrato de equipo, detalle artesanal
   - **Impacto:** Humaniza la empresa y genera confianza

5. **Services Icons/Images**
   - **Urgencia:** ALTA
   - **Acción:** Agregar imagen representativa por servicio (5 imágenes)
   - **Tipo:** Proceso técnico, resultado final, detalle de material
   - **Impacto:** Diferenciación visual y comprensión rápida de servicios

6. **Blog Content**
   - **Urgencia:** CRÍTICA
   - **Acción:** Publicar los 3 artículos técnicos existentes como posts del blog con imágenes
   - **Imágenes necesarias:** ~15-20 imágenes técnicas (aleaciones, procesos, pátinas)
   - **Impacto:** SEO, autoridad técnica, recursos para clientes potenciales

### Prioridad 2: IMPORTANTES (mejoran significativamente UX)

7. **Home - Shortcodes Funcionales**
   - **Urgencia:** MEDIA-ALTA
   - **Acción:** Reparar shortcodes de proyectos, testimonios y posts para que se rendericen
   - **Impacto:** Dinamismo, actualización automática de contenido destacado

8. **Contact Page - Ubicación**
   - **Urgencia:** MEDIA
   - **Acción:** Agregar mapa y foto del taller, información de contacto visible
   - **Impacto:** Facilita contacto, genera confianza en ubicación física

9. **Services EN - Fix 404**
   - **Urgencia:** MEDIA
   - **Acción:** Reparar página de servicios en inglés (devuelve 404)
   - **Impacto:** Accesibilidad para audiencia internacional

10. **Testimonials Page**
    - **Urgencia:** MEDIA
    - **Acción:** Crear página dedicada con testimonios (si existen) o eliminar mención
    - **Impacto:** Social proof, credibilidad

### Prioridad 3: MEJORAS (pulir experiencia visual)

11. **Footer Branding**
    - Agregar logo, certificaciones, partners/colaboradores

12. **Estadísticas Visuales**
    - Iconos o gráficos para "40+ años", "500+ proyectos", etc.

13. **Service Single Pages**
    - Implementar galerías por servicio con casos de uso

14. **Favicon/Touch Icons**
    - Asegurar presencia en todos los dispositivos

15. **Infografías Técnicas**
    - Diagrama de proceso de fundición
    - Timeline de proyecto típico
    - Comparativa de aleaciones

---

## E. Relación con RunMedia

### ¿El Índice Generado por RunMedia Puede Abastecer lo que Falta?

**Respuesta: SÍ, pero con curación y selección estratégica.**

**Inventario disponible:**
- **Total:** 6,162 imágenes indexadas
- **Asociadas a proyectos:** ~5,490 imágenes (26 proyectos identificados)
- **Asociadas a servicios:** Imágenes clasificadas para 16 servicios
- **Huérfanas:** 672 imágenes (candidatas para uso genérico: taller, procesos, detalles)

**Cobertura por tipo de contenido:**

| Necesidad del Sitio | Cobertura RunMedia | Cantidad Estimada | Estado |
|----------------------|---------------------|-------------------|--------|
| Home hero | ✅ Existe | 1 imagen (runartfoundry-home.jpg) | Listo para usar |
| Proyectos (thumbnails) | ✅ Cubre 26 proyectos | ~200-300 imágenes seleccionables | Requiere curación (elegir 1 destacada por proyecto) |
| Proyectos (galerías) | ✅ Múltiples imágenes por proyecto | ~5,000 imágenes | Requiere curación (6-12 por proyecto) |
| Servicios (representativas) | ✅ Clasificadas por servicio | ~1,000 imágenes | Requiere selección (1-3 por servicio) |
| About (equipo/taller) | ⚠️ Posible en huérfanas | ~50-100 candidatas | Requiere búsqueda manual |
| Blog (técnico) | ✅ Procesos documentados | ~500 imágenes | Requiere curación por artículo |
| Contact (ubicación) | ⚠️ Posible en branding | ~5-10 candidatas | Requiere verificación |

**Conclusión:**
RunMedia tiene **suficientes imágenes para abastecer todas las necesidades visuales del sitio**, pero se requiere:

1. **Curación manual:** Seleccionar las mejores imágenes de cada categoría
2. **Priorización:** Definir qué proyectos/servicios tienen prioridad visual
3. **Edición de ALT texts:** Las 6,162 imágenes necesitan ALT text bilingüe (actualmente 0%)
4. **Optimización:** Generar variantes WebP/AVIF para las imágenes seleccionadas (test validado en 20 imágenes)
5. **Integración:** Configurar pipeline de sincronización entre RunMedia y WordPress

### Páginas Sin Imágenes Asignadas

**Todas las páginas principales están sin imágenes asignadas:**

1. ✅ Home (0/1 hero + 0/6 proyectos + 0/5 servicios = **0/12 esperadas**)
2. ✅ About (0/5 esperadas: taller, equipo, procesos, timeline, detalle)
3. ✅ Services (0/5 representativas por servicio)
4. ✅ Projects listing (0/5 thumbnails mínimos para proyectos publicados)
5. ✅ Project single (0/30 esperadas: ~6 imágenes × 5 proyectos publicados)
6. ✅ Blog (0/~15 para 3 artículos técnicos)
7. ✅ Contact (0/2 esperadas: ubicación + taller)

**Total de imágenes necesarias para MVP visual:** ~70-80 imágenes curadas
**Total de imágenes disponibles en RunMedia:** 6,162 (ratio 77:1)

### Imágenes Clasificadas pero No Utilizadas

**Proyectos clasificados en RunMedia pero NO publicados en sitio (21):**

1. alexander-arrechea
2. american-dream
3. armonia
4. ballerina
5. carlos-manuel-cespedes
6. clementina
7. contra-corriente
8. durga-ma
9. el-beso
10. el-equilibrio
11. el-gran-viaje
12. el-rapto-de-micaela
13. el-saltamonte
14. eva
15. guajiro-reide-molina
16. la-gran-carroza
17. la-lira
18. la-reflexion
19. maquina-de-coser
20. maximo-gomez
21. mujer-con-pajaros
22. poco-de-nosotros
23. roberto-estupinan
24. serena
25. suenos-de-lucas
26. viaje-fantastico-fabelo

**Oportunidad:** Estos 21 proyectos representan un portfolio extenso que podría publicarse, ampliando significativamente la presencia visual del sitio.

**Servicios clasificados (16):**
Todos tienen imágenes asociadas en RunMedia, ninguno tiene imágenes visibles en el sitio:
- bronze-casting
- sculpture-modeling
- ceramic-shell
- wax-casting
- welding-polish
- patina
- silicon-rubber-molding
- sculpture-enlargement
- granite-bases
- wood-crates
- marble-sculpture
- water-jet
- resine-casting
- restoration
- oil-in-bronze
- engineering

---

## F. Conclusiones y Próximos Pasos

### Conclusiones Principales

1. **Desacople crítico entre contenido e imágenes:**
   - El sitio tiene copy excelente y estructura sólida
   - Inventario de 6,162 imágenes disponible pero no integrado
   - Resultado: Sitio funcional pero visualmente vacío

2. **Identidad visual minimalista presente pero extrema:**
   - Estructura limpia y profesional ✅
   - Ausencia total de elementos visuales ⚠️
   - Riesgo de percepción de sitio incompleto

3. **Oportunidad de mejora masiva con recursos existentes:**
   - RunMedia tiene el contenido visual necesario
   - No se requiere sesión fotográfica nueva (para MVP)
   - Se requiere curación, selección y integración técnica

4. **Blog vacío = oportunidad SEO perdida:**
   - Artículos técnicos escritos pero no publicados
   - Sin estrategia de contenido visible
   - Potencial de autoridad técnica no explotado

5. **Problemas técnicos menores pero críticos:**
   - Services EN devuelve 404
   - Shortcodes no renderizados
   - Integración WordPress-RunMedia inexistente

### Roadmap Sugerido para Fase UI/UX

**Fase 1: Integración Técnica (1-2 semanas)**
1. Configurar pipeline RunMedia → WordPress
2. Reparar página Services EN
3. Validar shortcodes (proyectos, testimonios, posts)
4. Implementar servido de variantes WebP/AVIF

**Fase 2: Curación de Imágenes (2-3 semanas)**
1. Seleccionar hero image para Home
2. Elegir 1 thumbnail por proyecto publicado (5 imágenes)
3. Curar galería por proyecto (6-12 × 5 = 30-60 imágenes)
4. Seleccionar representativas por servicio (5 × 1-3 = 5-15 imágenes)
5. About page (5 imágenes: taller, equipo, procesos)
6. Contact (2 imágenes: ubicación, taller)
7. **Total curación Fase 2:** ~50-80 imágenes

**Fase 3: ALT Texts y SEO (1-2 semanas)**
1. Redactar ALT text bilingüe para imágenes curadas (50-80 items)
2. Usar `alt_suggestions.csv` como base
3. Validar con equipo para precisión técnica
4. Integrar vía método elegido (CSV manual, REST API o MU Plugin)

**Fase 4: Blog Launch (1 semana)**
1. Publicar 3 artículos técnicos existentes
2. Seleccionar 5 imágenes por artículo (15 total)
3. Redactar ALT texts técnicos
4. Validar estructura y navegación

**Fase 5: Expansión de Portfolio (3-4 semanas)**
1. Seleccionar 5-10 proyectos adicionales para publicar
2. Crear páginas de proyecto con galerías
3. Expandir cobertura visual del portfolio
4. Mejorar SEO y presencia de marca

**Fase 6: Refinamiento UI (2-3 semanas)**
1. Implementar esquema rojo/negro consistente
2. Mejorar tipografía y jerarquía visual
3. Iconografía de servicios
4. Infografías técnicas
5. Testimonios con fotos/videos

### Métricas de Éxito

**KPIs visuales:**
- Imágenes visibles en Home: 0 → 12+ (hero + proyectos + servicios)
- Proyectos con galería: 0 → 5 (luego expandir a 10-15)
- Páginas con imágenes: 1/7 → 7/7 (100%)
- ALT texts completados: 0% → 100% (para imágenes curadas)
- Posts de blog: 0 → 3 (MVP), objetivo 10-15

**KPIs técnicos:**
- Variantes WebP/AVIF servidas: 0 → 100% (imágenes curadas)
- Páginas 404: 1 → 0 (Services EN)
- Shortcodes funcionales: 0% → 100%
- Lighthouse Performance: TBD → 90+
- Lighthouse Accessibility: TBD → 95+ (ALT texts)

**KPIs UX:**
- Bounce rate: TBD → -20% (objetivo)
- Time on site: TBD → +40% (objetivo)
- Pages per session: TBD → +50% (objetivo)
- Contact form conversions: TBD → +30% (objetivo)

---

## G. Anexos

### Anexo A: Estructura de URLs Analizada

```
staging.runartfoundry.com/
├── / (EN Home)
├── /es/inicio/ (ES Home)
├── /about/ (EN About)
├── /es/sobre-nosotros/ (ES About)
├── /services/ (EN Services) ⚠️ 404
├── /es/services/ (ES Services) ✅
├── /projects/ (EN Projects)
├── /es/projects/ (ES Projects)
├── /projects/<slug>/ (EN Project Single)
├── /es/projects/<slug>/ (ES Project Single)
├── /blog/ (EN Blog) ⚠️ Vacío
├── /es/blog-es/ (ES Blog) ⚠️ Vacío
├── /contact/ (EN Contact)
└── /es/contacto/ (ES Contact)
```

### Anexo B: Inventario de Imágenes RunMedia (Resumen)

```yaml
Total: 6,162 imágenes
Huérfanas: 672 (10.9%)
Asociadas: 5,490 (89.1%)

Proyectos identificados: 26
  - Publicados en sitio: 5
  - No publicados: 21

Servicios identificados: 16
  - Con imágenes en sitio: 0
  - Con imágenes en RunMedia: 16

Formatos disponibles:
  - Originales: JPG, PNG, WebP
  - Variantes generadas (test): WebP + AVIF
  - Tamaños: 400px, 800px, 1200px, 1600px, 2560px

ALT texts:
  - Completados: 0 (0%)
  - Pendientes: 6,162 (100%)
```

### Anexo C: Tipos de Imagen Requeridos (Clasificación)

**1. Imágenes de Producto/Resultado:**
- Esculturas terminadas
- Detalles de acabado
- Piezas instaladas en contexto
- Vista de escala (con personas)

**2. Imágenes de Proceso:**
- Modelado en cera
- Aplicación de cáscara cerámica
- Fundición activa (bronce líquido)
- Soldadura y acabado
- Aplicación de pátinas
- Pulido final

**3. Imágenes de Instalaciones:**
- Taller panorámico
- Hornos de fundición
- Área de modelado
- Zona de acabados
- Almacenamiento

**4. Imágenes de Equipo/Personas:**
- Retrato de equipo completo
- Maestros fundidores trabajando
- Artistas colaboradores
- Detalle de manos/artesanía

**5. Imágenes Técnicas/Educativas:**
- Muestras de aleaciones
- Comparativas de pátinas
- Diagramas de proceso
- Close-ups de texturas
- Secciones cortadas (moldes)

**6. Imágenes Corporativas:**
- Logo
- Branding
- Certificaciones
- Partners/colaboradores
- Ubicación externa

---

## H. Recomendaciones para Documento de Planificación UI/UX

Este informe debe servir como base para crear `plan_uiux_web_runart.md` que incluya:

1. **Estrategia visual completa:**
   - Moodboard con referencias de diseño
   - Paleta de colores expandida (rojo/negro/grises/acentos)
   - Tipografía definida (display/body/técnico)
   - Grid system y breakpoints

2. **Plan de implementación técnica:**
   - Integración RunMedia-WordPress
   - Pipeline de variantes WebP/AVIF
   - Lazy loading y optimización de imágenes
   - CDN y caching strategy

3. **Guía de curación de contenido:**
   - Criterios de selección de imágenes
   - Workflows de revisión/aprobación
   - Templates de ALT text por tipo de imagen
   - Naming conventions y metadata

4. **Wireframes y mockups:**
   - Home con hero visual
   - Projects gallery y single
   - Services con imágenes
   - About con team/facilities
   - Blog post template

5. **Testing y validación:**
   - Lighthouse audits pre/post
   - A/B testing de hero images
   - Heatmaps y analytics de engagement
   - Accessibility compliance (WCAG 2.1 AA)

6. **Roadmap de contenido:**
   - Priorización de proyectos a publicar
   - Calendar de posts de blog
   - Estrategia de testimonios
   - Plan de expansión de portfolio

---

**Fin del Informe**

**Próxima acción recomendada:**
Crear documento `plan_uiux_web_runart.md` con estrategia de implementación detallada basada en este análisis.

**Responsable de próxima fase:**
Equipo de diseño UI/UX + Curador de contenido visual

**Fecha objetivo para inicio de implementación:**
Noviembre 2025 (tras revisión de este informe)
