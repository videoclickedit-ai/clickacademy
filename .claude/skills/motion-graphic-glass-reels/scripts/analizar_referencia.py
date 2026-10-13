"""Desarma un video de referencia: hojas de contacto (2 fps) y colores reales muestreados.

Uso: python3 analizar_referencia.py referencia.mp4 <carpeta_salida>
Genera hoja_01.png, hoja_02.png... (12 cuadros por hoja) e imprime colores HEX
arriba / centro / abajo / izquierda de un frame cada 1.5 s.
"""
import os
import subprocess
import sys

from PIL import Image

src, out = sys.argv[1], sys.argv[2]
os.makedirs(out, exist_ok=True)
subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", src, "-vf", "fps=2,scale=240:-1,tile=6x2",
                os.path.join(out, "hoja_%02d.png")], check=True)
dur = float(subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", src],
                           capture_output=True, text=True, check=True).stdout)
t = 0.5
while t < dur:
    fp = os.path.join(out, f"frame_{t:05.1f}.png")
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-ss", str(t), "-i", src, "-frames:v", "1", fp], check=True)
    im = Image.open(fp).convert("RGB")
    w, h = im.size
    pts = {"arriba": (w // 2, h // 20), "centro": (w // 2, h // 2), "abajo": (w // 2, h - h // 20), "izq": (w // 18, h * 7 // 10)}
    print(f"{t:5.1f}s  " + "  ".join(f"{k} #{'%02X%02X%02X' % im.getpixel(p)}" for k, p in pts.items()))
    t += 1.5
print("hojas en", out)
