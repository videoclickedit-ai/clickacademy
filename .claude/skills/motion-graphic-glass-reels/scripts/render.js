// Renderiza <proyecto>/index.html frame por frame con Chromium y lo codifica con ffmpeg.
//   node render.js <proyecto>                     -> <proyecto>/out/video.mp4 (sin audio)
//   node render.js <proyecto> --stills 0,120,256  -> <proyecto>/out/still_XXXX.png
// La página debe exponer window.renderFrame(f) y window.TOTAL_FRAMES (ver assets/plantilla/index.html).
const path = require('path');
const fs = require('fs');
const { spawn } = require('child_process');

function loadPlaywright() {
  for (const p of [process.env.PLAYWRIGHT_MODULE, 'playwright', '/opt/node22/lib/node_modules/playwright'].filter(Boolean)) {
    try { return require(p); } catch (_) { /* siguiente */ }
  }
  throw new Error('No encuentro playwright. Instalalo (npm i -g playwright) o definí PLAYWRIGHT_MODULE.');
}

const proj = path.resolve(process.argv[2] || '.');
const OUT = path.join(proj, 'out');
fs.mkdirSync(OUT, { recursive: true });
const si = process.argv.indexOf('--stills');
const stills = si > 0 ? process.argv[si + 1].split(',').map(Number) : null;

(async () => {
  const { chromium } = loadPlaywright();
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1080, height: 1920 }, deviceScaleFactor: 1 });
  await page.goto('file://' + path.join(proj, 'index.html'));
  await page.evaluate(() => document.fonts.ready);
  const total = await page.evaluate(() => window.TOTAL_FRAMES);

  if (stills) {
    for (const f of stills) {
      await page.evaluate(n => window.renderFrame(n), f);
      await page.screenshot({ path: path.join(OUT, `still_${String(f).padStart(4, '0')}.png`) });
    }
    await browser.close();
    console.log('ok stills', stills.join(','));
    return;
  }

  const ff = spawn('ffmpeg', ['-y', '-v', 'error', '-f', 'image2pipe', '-framerate', '30', '-c:v', 'mjpeg', '-i', '-',
    '-c:v', 'libx264', '-preset', 'slow', '-crf', '16', '-pix_fmt', 'yuv420p', path.join(OUT, 'video.mp4')],
    { stdio: ['pipe', 'inherit', 'inherit'] });
  const t0 = Date.now();
  for (let f = 0; f < total; f++) {
    await page.evaluate(n => window.renderFrame(n), f);
    const buf = await page.screenshot({ type: 'jpeg', quality: 95 });
    if (!ff.stdin.write(buf)) await new Promise(r => ff.stdin.once('drain', r));
    if (f % 90 === 0) console.log(`frame ${f}/${total}  ${((Date.now() - t0) / 1000).toFixed(0)}s`);
  }
  ff.stdin.end();
  await new Promise(r => ff.on('close', r));
  await browser.close();
  console.log('ok', path.join(OUT, 'video.mp4'));
})();
