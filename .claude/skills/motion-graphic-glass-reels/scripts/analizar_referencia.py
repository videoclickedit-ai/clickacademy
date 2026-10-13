"""Desarma un reel de referencia y deja medido todo lo que el informe necesita.

Uso: python3 analizar_referencia.py referencia.mp4 <carpeta_salida>

Genera en <carpeta_salida>:
  hoja_XX.png              cuadros cada 0,5 s (6x2 por hoja): narrativa y texto en pantalla
  escena_XX.png            un frame por plano (mitad del plano) a 540 px de ancho
  escena_XX_grilla.png     el mismo frame con grilla del 10 % rotulada: para leer coordenadas X/Y en %
  analisis.json            ficha técnica, cortes, paleta por plano, tramos de voz y golpes de sonido
e imprime un resumen. Lo medido acá va tal cual al informe; lo demás se observa en las imágenes.
"""
import json
import os
import subprocess
import sys

import numpy as np
from PIL import Image, ImageDraw

src, out = sys.argv[1], sys.argv[2]
os.makedirs(out, exist_ok=True)


def run(args):
    return subprocess.run(args, capture_output=True, text=True, check=True)


# ---------- ficha técnica ----------
probe = json.loads(run(["ffprobe", "-v", "error", "-show_entries", "format=duration:stream=codec_type,width,height,r_frame_rate",
                        "-of", "json", src]).stdout)
vs = next(s for s in probe["streams"] if s["codec_type"] == "video")
has_audio = any(s["codec_type"] == "audio" for s in probe["streams"])
num, den = map(int, vs["r_frame_rate"].split("/"))
fps = num / den
dur = float(probe["format"]["duration"])
W, H = vs["width"], vs["height"]

# ---------- hojas de contacto ----------
run(["ffmpeg", "-v", "error", "-y", "-i", src, "-vf", "fps=2,scale=240:-1,tile=6x2", os.path.join(out, "hoja_%02d.png")])

# ---------- cambios de plano: cortes secos y transiciones graduales ----------
# ffmpeg "scene" solo ve cortes secos; en motion graphics casi todo entra con zoom/blur.
# Comparo cada cuadro (10 fps, 54x96) con el anterior (d1) y con el de 0,5 s antes (d5).
sw, sh = 54, 96
raw = subprocess.run(["ffmpeg", "-v", "error", "-i", src, "-vf", f"fps=10,scale={sw}:{sh}", "-pix_fmt", "rgb24",
                      "-f", "rawvideo", "-"], capture_output=True, check=True).stdout
fr = np.frombuffer(raw, dtype=np.uint8).reshape(-1, sh, sw, 3).astype(np.float32)
d1 = np.abs(fr[1:] - fr[:-1]).mean(axis=(1, 2, 3))
d5 = np.array([np.abs(fr[i + 5] - fr[i]).mean() for i in range(len(fr) - 5)])
thr = max(10.0, float(np.percentile(d5, 50)) * 2.5)
cambios, i = [], 0
while i < len(d5):
    if d5[i] > thr:
        j = i
        while j < len(d5) and d5[j] > thr:
            j += 1
        if j - i >= 2:
            t = round(((i + j - 1) / 2 + 2.5) / 10, 2)
            seco = d1[i:j + 5].max() > 0.6 * d5[i:j].max()
            if not cambios or t - cambios[-1]["t"] > 0.6:
                cambios.append({"t": t, "tipo": "corte" if seco else "transición/movimiento"})
        i = j
    i += 1
cortes = [c["t"] for c in cambios]
bordes = [0.0] + cortes + [dur]
planos = [(bordes[i], bordes[i + 1]) for i in range(len(bordes) - 1) if bordes[i + 1] - bordes[i] > 0.15]


def paleta(im, k=6):
    q = im.convert("RGB").resize((108, 192)).quantize(colors=k, method=Image.Quantize.MEDIANCUT)
    pal = q.getpalette()[: k * 3]
    cnt = sorted(q.getcolors(), reverse=True)
    tot = sum(c for c, _ in cnt)
    return [{"hex": "#%02X%02X%02X" % tuple(pal[i * 3:i * 3 + 3]), "pct": round(100 * c / tot)} for c, i in cnt]


def grilla(im):
    g = im.copy().convert("RGB")
    d = ImageDraw.Draw(g)
    w, h = g.size
    for p in range(10, 100, 10):
        x, y = w * p / 100, h * p / 100
        d.line([(x, 0), (x, h)], fill=(255, 0, 170), width=1)
        d.line([(0, y), (w, y)], fill=(255, 0, 170), width=1)
        d.text((x + 2, 2), f"{p}", fill=(255, 0, 170))
        d.text((2, y + 2), f"{p}", fill=(255, 0, 170))
    return g


escenas = []
for k, (a, b) in enumerate(planos):
    t = (a + b) / 2
    fp = os.path.join(out, f"escena_{k + 1:02d}.png")
    run(["ffmpeg", "-v", "error", "-y", "-ss", f"{t:.3f}", "-i", src, "-frames:v", "1", "-vf", "scale=540:-1", fp])
    im = Image.open(fp)
    grilla(im).save(os.path.join(out, f"escena_{k + 1:02d}_grilla.png"))
    escenas.append({"id": f"E{k + 1}", "desde": round(a, 2), "hasta": round(b, 2), "dur": round(b - a, 2),
                    "frames": round((b - a) * fps), "paleta": paleta(im)})

# paleta global (todas las escenas juntas)
mosaico = Image.new("RGB", (108 * len(escenas), 192))
for k in range(len(escenas)):
    mosaico.paste(Image.open(os.path.join(out, f"escena_{k + 1:02d}.png")).convert("RGB").resize((108, 192)), (108 * k, 0))
paleta_global = paleta(mosaico, 8)

# ---------- audio: tramos de voz y golpes ----------
audio = {"tiene_audio": has_audio}
if has_audio:
    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", src, "-ac", "1", "-ar", "16000", "-f", "s16le", "-"],
                         capture_output=True, check=True).stdout
    x = np.frombuffer(raw, dtype=np.int16).astype(np.float32) / 32768
    hop = 160
    n = len(x) // hop
    db = 20 * np.log10(np.sqrt(np.mean(x[: n * hop].reshape(n, hop) ** 2, axis=1)) + 1e-9)
    piso = float(np.percentile(db, 10))
    audio["piso_db"] = round(piso, 1)
    audio["musica_de_fondo_probable"] = piso > -40
    silent = db < max(-45, piso + 6)
    tramos, i = [], 0
    while i < n:
        if not silent[i]:
            j = i
            while j < n and not silent[j:j + 15].all():
                j += 1
            if j - i > 10:
                tramos.append([round(i / 100, 2), round(j / 100, 2)])
            i = j
        i += 1
    audio["tramos"] = tramos
    sube = db[3:] - db[:-3]
    golpes = []
    for m in np.argsort(-sube)[:200]:
        t = (m + 3) / 100
        if sube[m] > 10 and all(abs(t - g["t"]) > 0.25 for g in golpes):
            golpes.append({"t": round(t, 2), "frame": round(t * fps), "salto_db": round(float(sube[m]), 1)})
        if len(golpes) >= 25:
            break
    audio["golpes"] = sorted(golpes, key=lambda g: g["t"])

res = {"archivo": os.path.basename(src), "duracion_seg": round(dur, 3), "resolucion": f"{W}x{H}", "fps": round(fps, 3),
       "cambios": cambios, "escenas": escenas, "paleta_global": paleta_global, "audio": audio}
json.dump(res, open(os.path.join(out, "analisis.json"), "w"), ensure_ascii=False, indent=2)

# ---------- resumen ----------
print(f"FICHA: {dur:.2f}s · {W}x{H} · {fps:.2f} fps · {len(escenas)} planos · cambio cada {dur / max(1, len(escenas)):.1f}s en promedio")
print("CAMBIOS: " + "  ".join(f"{c['t']:.2f}s ({c['tipo']})" for c in cambios))
print("PALETA GLOBAL: " + "  ".join(f"{c['hex']} {c['pct']}%" for c in paleta_global))
for e in escenas:
    print(f"{e['id']:>4} {e['desde']:6.2f}-{e['hasta']:6.2f}s ({e['frames']} f)  " + " ".join(c["hex"] for c in e["paleta"][:4]))
if has_audio:
    print(f"AUDIO: piso {audio['piso_db']} dB · música de fondo probable: {'sí' if audio['musica_de_fondo_probable'] else 'no'}")
    print("  voz/tramos: " + "  ".join(f"{a:.2f}-{b:.2f}" for a, b in audio["tramos"]))
    print("  golpes (posibles SFX/cortes de música): " + "  ".join(f"{g['t']:.2f}s" for g in audio["golpes"]))
print("salida en", out)
