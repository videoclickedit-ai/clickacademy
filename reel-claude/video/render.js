// Renderiza index.html frame por frame con Chromium y lo codifica con ffmpeg.
//   node render.js                 -> out/video.mp4 (sin audio)
//   node render.js --stills 0,170  -> out/still_0000.png, out/still_0170.png
const path = require('path');
const fs = require('fs');
const { spawn } = require('child_process');
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || '/opt/node22/lib/node_modules/playwright');

const OUT = path.join(__dirname, 'out');
fs.mkdirSync(OUT, { recursive: true });
const args = process.argv.slice(2);
const stills = args[0] === '--stills' ? args[1].split(',').map(Number) : null;

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1080, height: 1920 }, deviceScaleFactor: 1 });
  await page.goto('file://' + path.join(__dirname, 'index.html'));
  await page.evaluate(() => document.fonts.ready);
  const total = await page.evaluate(() => window.TOTAL_FRAMES);

  if (stills) {
    for (const f of stills) {
      await page.evaluate(n => window.renderFrame(n), f);
      await page.screenshot({ path: path.join(OUT, `still_${String(f).padStart(4, '0')}.png`) });
    }
    await browser.close();
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
    if (f % 60 === 0) console.log(`frame ${f}/${total}  ${((Date.now() - t0) / 1000).toFixed(0)}s`);
  }
  ff.stdin.end();
  await new Promise(r => ff.on('close', r));
  await browser.close();
  console.log('ok', path.join(OUT, 'video.mp4'));
})();
