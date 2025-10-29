<?php
/**
 * Template Name: About Page
 * About page template with hero, story, process, values, stats.
 *
 * @package RunArt_Base
 */

get_header();

// Detect current language
$current_lang = function_exists('pll_current_language') ? pll_current_language() : 'en';

// Content arrays by language
$content = array(
  'en' => array(
    'hero_title' => 'About RUN Art Foundry',
    'hero_subtitle' => 'Crafting bronze with precision, tradition, and technology',
    'story_title' => 'Our Story',
    'story' => array(
      array('title' => 'Origins', 'text' => 'Founded by artists and engineers, our foundry blends heritage and innovation in every piece we create.'),
      array('title' => 'Workshop', 'text' => 'A dedicated studio where traditional lost-wax bronze casting meets contemporary precision and quality control.'),
      array('title' => 'Philosophy', 'text' => 'Every sculpture is treated as a unique collaboration between artistic vision and technical mastery.')
    ),
    'process_title' => 'Our Process',
    'process_steps' => array('Model', 'Mold', 'Wax Pattern', 'Ceramic Shell', 'Burnout', 'Casting', 'Chasing', 'Patina', 'Final Finish'),
    'values_title' => 'Our Values',
    'values' => array(
      array('title' => 'Precision', 'text' => 'We adhere to rigorous standards at every stage of the casting process'),
      array('title' => 'Integrity', 'text' => 'Transparent communication and honest assessment of every project'),
      array('title' => 'Collaboration', 'text' => 'Working closely with artists to achieve their unique vision'),
      array('title' => 'Sustainability', 'text' => 'Responsible practices in material sourcing and waste management')
    ),
    'stats_title' => 'Excellence in Numbers',
    'stats' => array(
      array('number' => '40+', 'label' => 'Years of Expertise'),
      array('number' => '500+', 'label' => 'Projects Completed'),
      array('number' => '15', 'label' => 'Specialized Artisans'),
      array('number' => '100%', 'label' => 'Client Satisfaction')
    )
  ),
  'es' => array(
    'hero_title' => 'Sobre RUN Art Foundry',
    'hero_subtitle' => 'Creando bronce con precisión, tradición y tecnología',
    'story_title' => 'Nuestra Historia',
    'story' => array(
      array('title' => 'Orígenes', 'text' => 'Fundada por artistas e ingenieros, nuestra fundición combina herencia e innovación en cada pieza que creamos.'),
      array('title' => 'Taller', 'text' => 'Un estudio dedicado donde la fundición tradicional a la cera perdida se encuentra con la precisión y control de calidad contemporáneos.'),
      array('title' => 'Filosofía', 'text' => 'Cada escultura es tratada como una colaboración única entre la visión artística y la maestría técnica.')
    ),
    'process_title' => 'Nuestro Proceso',
    'process_steps' => array('Modelo', 'Molde', 'Patrón de Cera', 'Caparazón Cerámico', 'Quemado', 'Fundición', 'Cincelado', 'Pátina', 'Acabado Final'),
    'values_title' => 'Nuestros Valores',
    'values' => array(
      array('title' => 'Precisión', 'text' => 'Adherimos a estándares rigurosos en cada etapa del proceso de fundición'),
      array('title' => 'Integridad', 'text' => 'Comunicación transparente y evaluación honesta de cada proyecto'),
      array('title' => 'Colaboración', 'text' => 'Trabajamos estrechamente con artistas para lograr su visión única'),
      array('title' => 'Sostenibilidad', 'text' => 'Prácticas responsables en el abastecimiento de materiales y gestión de residuos')
    ),
    'stats_title' => 'Excelencia en Números',
    'stats' => array(
      array('number' => '40+', 'label' => 'Años de Experiencia'),
      array('number' => '500+', 'label' => 'Proyectos Completados'),
      array('number' => '15', 'label' => 'Artesanos Especializados'),
      array('number' => '100%', 'label' => 'Satisfacción del Cliente')
    )
  )
);

$texts = isset($content[$current_lang]) ? $content[$current_lang] : $content['en'];
?>

<div class="about-page">
  <!-- Hero -->
  <section class="hero-section about-hero">
    <?php
    $hero_image = runart_get_runmedia_image('workshop-hero', 'w2560');
    $hero_style = $hero_image ? 'background-image: url(' . esc_url($hero_image['url']) . ');' : '';
    ?>
    <div class="hero-background" style="<?php echo $hero_style; ?>"></div>
    <div class="hero-content">
      <h1 class="hero-title"><?php echo esc_html($texts['hero_title']); ?></h1>
      <p class="hero-subtitle"><?php echo esc_html($texts['hero_subtitle']); ?></p>
    </div>
  </section>

  <!-- Story -->
  <section class="section">
    <div class="container">
      <h2 class="section-title"><?php echo esc_html($texts['story_title']); ?></h2>
      <div class="story-grid">
        <?php foreach ($texts['story'] as $story): ?>
          <div class="story-card">
            <h3><?php echo esc_html($story['title']); ?></h3>
            <p><?php echo esc_html($story['text']); ?></p>
          </div>
        <?php endforeach; ?>
      </div>
    </div>
  </section>

  <!-- Process timeline -->
  <section class="section section-dark">
    <div class="container">
      <h2 class="section-title"><?php echo esc_html($texts['process_title']); ?></h2>
      <div class="process-timeline">
        <?php foreach ($texts['process_steps'] as $index => $step): ?>
          <div class="process-step">
            <span class="step-number"><?php echo $index + 1; ?></span>
            <strong class="step-label"><?php echo esc_html($step); ?></strong>
          </div>
        <?php endforeach; ?>
      </div>
    </div>
  </section>

  <!-- Values -->
  <section class="section">
    <div class="container">
      <h2 class="section-title"><?php echo esc_html($texts['values_title']); ?></h2>
      <div class="values-grid">
        <?php foreach ($texts['values'] as $value): ?>
          <div class="value-card">
            <h3><?php echo esc_html($value['title']); ?></h3>
            <p><?php echo esc_html($value['text']); ?></p>
          </div>
        <?php endforeach; ?>
      </div>
    </div>
  </section>

  <!-- Stats -->
  <section class="section section-dark">
    <div class="container">
      <h2 class="section-title"><?php echo esc_html($texts['stats_title']); ?></h2>
      <div class="stats-grid">
        <?php foreach ($texts['stats'] as $stat): ?>
          <div class="stat">
            <span class="stat-number"><?php echo esc_html($stat['number']); ?></span>
            <span class="stat-label"><?php echo esc_html($stat['label']); ?></span>
          </div>
        <?php endforeach; ?>
      </div>
    </div>
  </section>
</div>

<?php get_footer(); ?>
