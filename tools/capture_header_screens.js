#!/usr/bin/env node
const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

(async () => {
  const urls = [
    'https://staging.runartfoundry.com/es/inicio/',
    'https://staging.runartfoundry.com/en/home/'
  ];
  const viewports = [
    { width: 360, height: 200, name: '360' },
    { width: 390, height: 200, name: '390' },
    { width: 414, height: 200, name: '414' },
    { width: 1280, height: 220, name: '1280' }
  ];
  const outDir = path.join(__dirname, '../_artifacts/screenshots_uiux_20251029/chrome-mobile-nav-fix');
  fs.mkdirSync(outDir, { recursive: true });

  const browser = await puppeteer.launch({ headless: 'new', args: ['--no-sandbox'] });
  for (const vp of viewports) {
    const page = await browser.newPage();
    await page.setViewport({ width: vp.width, height: vp.height });
    for (const url of urls) {
      await page.goto(url, { waitUntil: 'networkidle2', timeout: 45000 });
      await page.waitForSelector('.site-header');
      const clip = { x: 0, y: 0, width: vp.width, height: Math.min(vp.height, 200) };
      const name = `${vp.name}_${url.includes('/es/') ? 'es' : 'en'}.png`;
      await page.screenshot({ path: path.join(outDir, name), clip });
      console.log('Saved', name);
    }
    await page.close();
  }
  await browser.close();
})();
