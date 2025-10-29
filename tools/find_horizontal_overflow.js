#!/usr/bin/env node
const puppeteer = require('puppeteer');

(async () => {
  const url = process.argv[2] || 'https://staging.runartfoundry.com/es/inicio/';
  const width = parseInt(process.argv[3] || '360', 10);
  const height = parseInt(process.argv[4] || '640', 10);
  const browser = await puppeteer.launch({ headless: 'new', args: ['--no-sandbox'] });
  const page = await browser.newPage();
  await page.setViewport({ width, height });
  await page.goto(url, { waitUntil: 'networkidle2', timeout: 45000 });
  await page.waitForSelector('body');

  const result = await page.evaluate(() => {
    const vpw = document.documentElement.clientWidth;
    const offenders = [];
    const all = Array.from(document.querySelectorAll('body *'));
    for (const el of all) {
      const rect = el.getBoundingClientRect();
      const cs = getComputedStyle(el);
      const sw = el.scrollWidth;
      const ow = el.offsetWidth;
      // Detect overflow horizontally relative to viewport
      const over = Math.max(sw, rect.right - rect.left) > vpw + 1; // tolerance
      if (over) {
        offenders.push({
          selector: el.tagName.toLowerCase() + (el.id ? '#' + el.id : '') + (el.className ? '.' + String(el.className).trim().replace(/\s+/g,'.') : ''),
          sw, ow, rectWidth: rect.width, csOverflowX: cs.overflowX, display: cs.display
        });
      }
    }
    offenders.sort((a,b) => (b.sw||0) - (a.sw||0));
    return { viewport: vpw, count: offenders.length, top: offenders.slice(0,20) };
  });
  console.log(JSON.stringify(result, null, 2));
  await browser.close();
})();
