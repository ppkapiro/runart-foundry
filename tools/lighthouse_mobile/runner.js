import fs from 'fs';
import { writeFile, mkdir, copyFile } from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';
import lighthouse from 'lighthouse';
import puppeteer from 'puppeteer';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Configuración
const BASE = process.env.BASE || 'https://staging.runartfoundry.com';
const DATE_STAMP = process.env.OUT_DATE || new Date().toISOString().slice(0,10).replace(/-/g, '');
const RUNS = Number(process.env.RUNS || 2);
const OUT_ARTIFACTS = path.resolve(__dirname, '../../_artifacts/lighthouse', DATE_STAMP);
const OUT_RAW = path.join(OUT_ARTIFACTS, 'raw');
const OUT_REPORTS_RAW = path.resolve(__dirname, '../../_reports/RESPONSIVE_LH_RAW');
const OUT_REPORTS_SUMMARY = path.resolve(__dirname, '../../_reports/RESPONSIVE_LH_SUMMARY.json');

const PAGES = (process.env.PAGES_JSON ? JSON.parse(process.env.PAGES_JSON) : [
  '/', '/en/', '/es/',
  '/en/about/', '/es/about/',
  '/en/services/', '/es/services/',
  '/en/projects/', '/es/projects/',
  '/en/blog/', '/es/blog-2/',
  '/en/contact/', '/es/contacto/'
]);

const THRESHOLDS = {
  performance: 80,
  accessibility: 90,
  bestPractices: 90,
  cls: 0.10,
  inpMs: 200,
  lcpMs: 3000
};

function mean(arr){ return arr.reduce((a,b)=>a+b,0) / (arr.length || 1); }
function stddev(arr){
  if(arr.length <= 1) return 0;
  const m = mean(arr);
  const v = mean(arr.map(x => (x - m) ** 2));
  return Math.sqrt(v);
}

function sanitizePath(p){
  return (p||'').replace(/^\//,'').replace(/\W+/g,'_') || 'root';
}

function getINP(lhr){
  const a = lhr.audits;
  const keys = ['interaction-to-next-paint', 'experimental-interaction-to-next-paint', 'inp'];
  for(const k of keys){
    if(a[k] && typeof a[k].numericValue === 'number') return a[k].numericValue;
  }
  return null;
}

async function ensureDirs(){
  await mkdir(OUT_ARTIFACTS, { recursive: true });
  await mkdir(OUT_RAW, { recursive: true });
  await mkdir(OUT_REPORTS_RAW, { recursive: true });
}

function evalGates(summary){
  const fails = [];
  if(summary.performance.avg < THRESHOLDS.performance) fails.push(`Performance < ${THRESHOLDS.performance}`);
  if(summary.accessibility.avg < THRESHOLDS.accessibility) fails.push(`Accessibility < ${THRESHOLDS.accessibility}`);
  if(summary.bestPractices.avg < THRESHOLDS.bestPractices) fails.push(`Best Practices < ${THRESHOLDS.bestPractices}`);
  if(summary.cls.avg > THRESHOLDS.cls) fails.push(`CLS > ${THRESHOLDS.cls}`);
  if(summary.inpMs.avg > THRESHOLDS.inpMs) fails.push(`INP > ${THRESHOLDS.inpMs}ms`);
  if(summary.lcpMs.avg > THRESHOLDS.lcpMs) fails.push(`LCP > ${THRESHOLDS.lcpMs}ms`);
  return { pass: fails.length === 0, fails };
}

function recommendations(gates){
  const recs = [];
  if(gates.fails.some(f => f.startsWith('LCP'))) {
    recs.push('hero.improve: reservar altura (aspect-ratio/min-height), considerar preload del asset principal, font-display: swap');
  }
  if(gates.fails.some(f => f.startsWith('CLS'))) {
    recs.push('hero.improve: reservar espacio de hero e imágenes, evitar cambios de layout tardíos');
  }
  if(gates.fails.some(f => f.startsWith('INP'))) {
    recs.push('revisar handlers pesados, diferir JS no crítico, evitar tareas >50ms en interacción');
  }
  if(gates.fails.some(f => f.startsWith('Performance'))) {
    recs.push('auditar recursos grandes (imágenes, fuentes), preload selectivo, optimizar LCP/CLS');
  }
  if(gates.fails.some(f => f.startsWith('Best Practices'))) {
    recs.push('verificar problemas de best-practices (HTTPS, assets inseguros, APIs obsoletas)');
  }
  if(gates.fails.some(f => f.startsWith('Accessibility'))) {
    recs.push('mejorar a11y: contraste, labels, roles; mantener ≥90');
  }
  return recs;
}

async function main(){
  await ensureDirs();
  const vParam = (s) => s + (s.includes('?') ? '&' : '?') + 'v=now';
  const fullUrls = PAGES.map(p => (p.startsWith('http') ? p : BASE + p)).map(vParam);

  const browser = await puppeteer.launch({ 
    headless: 'new', 
    args: ['--no-sandbox','--disable-gpu','--disable-dev-shm-usage','--disable-setuid-sandbox']
  });
  const browserWSEndpoint = browser.wsEndpoint();
  const portMatch = browserWSEndpoint.match(/:(\d+)\//);
  const chromePort = portMatch ? Number(portMatch[1]) : null;

  if(!chromePort) {
    console.error('[LH] No se pudo obtener puerto de Chrome');
    await browser.close();
    process.exit(1);
  }

  const allSummaries = [];

  try {
    for(const [idx, url] of fullUrls.entries()){
      const route = PAGES[idx];
      const slug = sanitizePath(route);
      console.log(`[LH] ${route} → ${RUNS} corridas`);

      const perfs = [], accs = [], bps = [], seos = [], lcps = [], clss = [], inps = [];

      for(let i=1; i<=RUNS; i++){
        try {
          const runnerResult = await lighthouse(url, {
            port: chromePort,
            output: 'json',
            logLevel: 'error',
            maxWaitForLoad: 45000
          }, {
            extends: 'lighthouse:default',
            settings: {
              onlyCategories: ['performance','accessibility','best-practices','seo'],
              formFactor: 'mobile',
              screenEmulation: { mobile: true, width: 360, height: 640, deviceScaleFactor: 2, disabled: false },
              throttlingMethod: 'simulate',
              maxWaitForLoad: 45000
            }
          });
          const lhr = runnerResult.lhr;

          const outName = `${slug}__run${i}.json`;
          const outPath = path.join(OUT_RAW, outName);
          await writeFile(outPath, JSON.stringify(lhr, null, 2), 'utf8');
          const reportsCopy = path.join(OUT_REPORTS_RAW, `${DATE_STAMP}_${outName}`);
          await copyFile(outPath, reportsCopy).catch(async () => {
            await writeFile(reportsCopy, JSON.stringify(lhr, null, 2), 'utf8');
          });

          const cats = lhr.categories;
          const perf = (cats.performance?.score ?? 0) * 100;
          const acc = (cats.accessibility?.score ?? 0) * 100;
          const bp = (cats['best-practices']?.score ?? 0) * 100;
          const seo = (cats.seo?.score ?? 0) * 100;
          const lcp = lhr.audits['largest-contentful-paint']?.numericValue ?? null;
          const cls = lhr.audits['cumulative-layout-shift']?.numericValue ?? null;
          const inp = getINP(lhr);

          perfs.push(perf);
          accs.push(acc);
          bps.push(bp);
          seos.push(seo);
          if(lcp!=null) lcps.push(lcp);
          if(cls!=null) clss.push(cls);
          if(inp!=null) inps.push(inp);
          console.log(`  • run ${i}: Perf ${perf.toFixed(0)} Acc ${acc.toFixed(0)} BP ${bp.toFixed(0)} SEO ${seo.toFixed(0)} | LCP ${(lcp/1000).toFixed(2)}s CLS ${cls?.toFixed(3)} INP ${inp?.toFixed(0)}ms`);
        } catch(e) {
          console.error(`  ✗ run ${i} falló:`, e.message);
        }
      }

      const summary = {
        route,
        url,
        runs: RUNS,
        performance: { avg: mean(perfs), sd: stddev(perfs) },
        accessibility: { avg: mean(accs), sd: stddev(accs) },
        bestPractices: { avg: mean(bps), sd: stddev(bps) },
        seo: { avg: mean(seos), sd: stddev(seos) },
        lcpMs: { avg: mean(lcps), sd: stddev(lcps) },
        cls: { avg: mean(clss), sd: stddev(clss) },
        inpMs: { avg: mean(inps), sd: stddev(inps) }
      };
      const gates = evalGates(summary);
      const recs = recommendations(gates);
      const enriched = { ...summary, gates, recommendations: recs };
      allSummaries.push(enriched);
    }

    const final = {
      date: DATE_STAMP,
      base: BASE,
      runsPerPage: RUNS,
      thresholds: THRESHOLDS,
      pages: allSummaries
    };

    const outSummaryArtifacts = path.join(OUT_ARTIFACTS, 'summary.json');
    await writeFile(outSummaryArtifacts, JSON.stringify(final, null, 2), 'utf8');
    await writeFile(OUT_REPORTS_SUMMARY, JSON.stringify(final, null, 2), 'utf8');

    console.log(`\n[LH] ✓ Completado. Summary:\n - ${outSummaryArtifacts}\n - ${OUT_REPORTS_SUMMARY}`);
  } finally {
    try { await browser.close(); } catch {}
  }
}

main().catch(e => {
  console.error(e);
  process.exit(1);
});
