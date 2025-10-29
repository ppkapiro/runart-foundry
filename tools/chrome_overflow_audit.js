#!/usr/bin/env node
/**
 * Chrome Overflow Audit — v1.0
 * Mide offsetWidth de elementos clave en múltiples viewports
 * para detectar overflow horizontal específico de Chrome.
 */

const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

const URLS = [
  'https://staging.runartfoundry.com/en/home/',
  'https://staging.runartfoundry.com/es/inicio/',
  'https://staging.runartfoundry.com/en/services/',
  'https://staging.runartfoundry.com/es/servicios/'
];

const VIEWPORTS = [
  { width: 360, height: 640, name: '360px' },
  { width: 390, height: 844, name: '390px' },
  { width: 414, height: 896, name: '414px' },
  { width: 1280, height: 720, name: '1280px' }
];

const SELECTORS = [
  'html',
  'body',
  '.site-header',
  '.site-header .container',
  '.site-nav',
  '.site-lang-switcher'
];

async function measureElements(page, viewport, url) {
  const measurements = {};
  
  for (const selector of SELECTORS) {
    try {
      const element = await page.$(selector);
      if (element) {
        const box = await element.boundingBox();
        const metrics = await page.evaluate((sel) => {
          const el = document.querySelector(sel);
          if (!el) return null;
          const rect = el.getBoundingClientRect();
          const computed = window.getComputedStyle(el);
          return {
            offsetWidth: el.offsetWidth,
            scrollWidth: el.scrollWidth,
            clientWidth: el.clientWidth,
            rectWidth: rect.width,
            overflow: computed.overflow,
            overflowX: computed.overflowX,
            maxWidth: computed.maxWidth,
            width: computed.width,
            display: computed.display,
            position: computed.position
          };
        }, selector);
        
        measurements[selector] = {
          box,
          ...metrics,
          hasOverflow: metrics && metrics.scrollWidth > viewport.width
        };
      }
    } catch (err) {
      measurements[selector] = { error: err.message };
    }
  }
  
  return measurements;
}

async function captureScreenshot(page, viewport, url, index) {
  const dir = path.join(__dirname, '../_artifacts/screenshots_uiux_20251029/chrome-audit-pre-fix');
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  
  const filename = `${viewport.name}_${index}_${url.split('/').filter(Boolean).pop() || 'home'}.png`;
  await page.screenshot({
    path: path.join(dir, filename),
    fullPage: false,
    clip: { x: 0, y: 0, width: viewport.width, height: Math.min(viewport.height, 400) }
  });
  
  return filename;
}

async function runAudit() {
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  
  const results = [];
  
  for (const viewport of VIEWPORTS) {
    console.log(`\n📐 Testing viewport: ${viewport.name}`);
    
    for (let i = 0; i < URLS.length; i++) {
      const url = URLS[i];
      console.log(`  🔍 ${url}`);
      
      const page = await browser.newPage();
      await page.setViewport(viewport);
      
      try {
        await page.goto(url, { waitUntil: 'networkidle2', timeout: 30000 });
        await page.waitForSelector('.site-header', { timeout: 5000 });
        
        const measurements = await measureElements(page, viewport, url);
        const screenshot = await captureScreenshot(page, viewport, url, i);
        
        results.push({
          url,
          viewport: viewport.name,
          measurements,
          screenshot,
          timestamp: new Date().toISOString()
        });
        
        // Detectar overflow
        const overflowElements = Object.entries(measurements)
          .filter(([sel, data]) => data.hasOverflow)
          .map(([sel]) => sel);
        
        if (overflowElements.length > 0) {
          console.log(`    ⚠️  OVERFLOW detectado en: ${overflowElements.join(', ')}`);
        } else {
          console.log(`    ✅ Sin overflow horizontal`);
        }
        
      } catch (err) {
        console.error(`    ❌ Error: ${err.message}`);
        results.push({
          url,
          viewport: viewport.name,
          error: err.message,
          timestamp: new Date().toISOString()
        });
      }
      
      await page.close();
    }
  }
  
  await browser.close();
  
  // Guardar resultados JSON
  const outputPath = path.join(__dirname, '../_artifacts/chrome_overflow_audit_results.json');
  fs.writeFileSync(outputPath, JSON.stringify(results, null, 2));
  console.log(`\n✅ Auditoría completada. Resultados guardados en: ${outputPath}`);
  
  return results;
}

// Ejecutar
runAudit().catch(err => {
  console.error('❌ Error en auditoría:', err);
  process.exit(1);
});
