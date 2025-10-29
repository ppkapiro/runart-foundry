#!/usr/bin/env python3
"""
Translate main pages (Home, About) from EN to ES using OpenAI API
"""
import os
import sys
import requests
from openai import OpenAI

# WordPress credentials
WP_BASE_URL = "https://staging.runartfoundry.com"
WP_USER = "runart-admin"
WP_APP_PASSWORD = "WNoAVgiGzJiBCfUUrMI8GZnx"

# OpenAI setup
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

def translate_content(content_en: str, context: str) -> str:
    """Translate English content to Spanish using OpenAI"""
    prompt = f"""Traduce el siguiente contenido HTML de inglés a español. 
Contexto: {context}

IMPORTANTE:
- Mantén TODAS las etiquetas HTML exactamente igual
- Mantén TODOS los atributos de clase, id, href exactamente igual
- Solo traduce el TEXTO dentro de las etiquetas
- Mantén los shortcodes [shortcode: ...] exactamente igual
- URLs /en/ déjalas como están (no las traduzcas)
- Preserva la estructura y formato completamente

Contenido a traducir:

{content_en}"""

    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": "Eres un traductor profesional especializado en contenido web. Mantienes HTML intacto y solo traduces texto."},
            {"role": "user", "content": prompt}
        ],
        temperature=0.3
    )
    
    return response.choices[0].message.content.strip()

def update_page(page_id: int, title: str, content: str):
    """Update WordPress page via REST API"""
    url = f"{WP_BASE_URL}/wp-json/wp/v2/pages/{page_id}"
    
    data = {
        "title": title,
        "content": content,
        "status": "publish"
    }
    
    response = requests.post(
        url,
        json=data,
        auth=(WP_USER, WP_APP_PASSWORD),
        headers={"Content-Type": "application/json"}
    )
    
    if response.status_code in [200, 201]:
        print(f"✓ Página {page_id} actualizada: {title}")
        return True
    else:
        print(f"✗ Error actualizando {page_id}: {response.status_code}")
        print(response.text)
        return False

def main():
    print("🌐 Traduciendo páginas principales EN → ES\n")
    
    # Home EN content
    home_en_content = """<section id="hero" class="hero-section">
<div class="hero-content">
<h1>RunArt Foundry — Excellence in Art Casting</h1>
<p class="hero-subtitle">We transform artistic visions into the highest quality bronze through traditional techniques and contemporary technology</p>
<div class="hero-cta">
<a href="#contact" class="btn btn-primary">Start your consultation</a>
<a href="#projects" class="btn btn-secondary">View projects</a>
</div>
</div>
</section>

<section id="projects-preview" class="section">
<div class="container">
<h2>Featured Projects</h2>
<p>We collaborate with internationally recognized artists to materialize monumental sculptures and collector pieces.</p>
<div class="projects-grid">[shortcode: latest 6 projects]</div>
<a href="/en/projects/" class="btn btn-outline">View all projects →</a>
</div>
</section>

<section id="services-preview" class="section section-dark">
<div class="container">
<h2>Specialized Services</h2>
<div class="services-cards">
<div class="service-card">
<h3>Art Casting</h3>
<p>Traditional lost-wax techniques for unique pieces</p>
</div>
<div class="service-card">
<h3>Specialized Patinas</h3>
<p>Custom chemical finishes and polychromy</p>
</div>
<div class="service-card">
<h3>Heritage Restoration</h3>
<p>Conservation of historic sculptures with scientific methodology</p>
</div>
<div class="service-card">
<h3>Technical Consulting</h3>
<p>Advisory on feasibility, engineering, and optimization</p>
</div>
<div class="service-card">
<h3>Limited Editions</h3>
<p>Numbered series with exceptional quality control</p>
</div>
</div>
<a href="/en/services/" class="btn btn-light">Explore services →</a>
</div>
</section>

<section id="testimonials-preview" class="section">
<div class="container">
<h2>What Our Clients Say</h2>
<div class="testimonials-carousel">[shortcode: latest 3 testimonials with video]</div>
<a href="/en/testimonials/" class="btn btn-outline">More testimonials →</a>
</div>
</section>

<section id="blog-preview" class="section">
<div class="container">
<h2>Technical Resources</h2>
<p>Complete guides on casting, alloys, and bronze conservation</p>
<div class="blog-grid">[shortcode: latest 3 posts]</div>
<a href="/en/blog/" class="btn btn-outline">View technical blog →</a>
</div>
</section>

<section id="stats" class="section section-dark">
<div class="container">
<div class="stats-grid">
<div class="stat">
<span class="stat-number">40+</span>
<span class="stat-label">Years of experience</span>
</div>
<div class="stat">
<span class="stat-number">500+</span>
<span class="stat-label">Completed projects</span>
</div>
<div class="stat">
<span class="stat-number">50+</span>
<span class="stat-label">Collaborating artists</span>
</div>
<div class="stat">
<span class="stat-number">15</span>
<span class="stat-label">Countries served</span>
</div>
</div>
</div>
</section>

<section id="press-kit" class="section">
<div class="container">
<h2>Press and Media</h2>
<p>Resources for journalists, curators, and media</p>
<a href="/en/press-kit/" class="btn btn-outline">Download press kit →</a>
</div>
</section>

<section id="contact-cta" class="section section-dark">
<div class="container">
<h2>Do You Have a Project in Mind?</h2>
<p>Let's talk about how we can materialize your artistic vision</p>
<a href="#contact" class="btn btn-primary">Contact now</a>
</div>
</section>"""

    # About EN content
    about_en_content = """<section class="about-section">
<div class="container">
<h2>About R.U.N. Art Foundry</h2>
<p>With over 40 years of experience, R.U.N. Art Foundry is a specialized art foundry dedicated to creating bronze sculptures through traditional techniques and contemporary technology.</p>

<h3>Our Mission</h3>
<p>To materialize the artistic visions of sculptors, architects, and collectors into the highest quality bronze works, preserving the original artistic integrity and applying the highest technical standards.</p>

<h3>Experience and Expertise</h3>
<p>We have collaborated with internationally renowned artists and completed over 500 projects ranging from monumental sculptures for public spaces to collection pieces for museums and galleries.</p>

<h3>Techniques and Processes</h3>
<ul>
<li><strong>Lost wax casting:</strong> Traditional process that allows extremely fine details to be reproduced</li>
<li><strong>Specialized patinas:</strong> Custom chemical finishes that bring life and character to each piece</li>
<li><strong>Heritage restoration:</strong> Conservation of historical sculptures with scientific methodology</li>
<li><strong>Limited editions:</strong> Rigorous quality control for numbered series</li>
</ul>

<h3>Our Team</h3>
<p>We have a multidisciplinary team of master founders, specialized technicians, chemists, and artisans who work together to guarantee exceptional results in every project.</p>
</div>
</section>"""

    # Translate Home
    print("📝 Traduciendo Home...")
    home_es_content = translate_content(home_en_content, "Página de inicio del sitio web de fundición artística")
    
    # Translate About
    print("📝 Traduciendo About...")
    about_es_content = translate_content(about_en_content, "Página sobre nosotros de fundición artística")
    
    print("\n✅ Traducciones completadas\n")
    
    # Update pages
    print("📤 Actualizando páginas en WordPress...\n")
    
    # Update Inicio (3517)
    update_page(3517, "Inicio", home_es_content)
    
    # Update Sobre nosotros (3518)
    update_page(3518, "Sobre nosotros", about_es_content)
    
    print("\n✅ Páginas principales traducidas y actualizadas!")

if __name__ == "__main__":
    main()
