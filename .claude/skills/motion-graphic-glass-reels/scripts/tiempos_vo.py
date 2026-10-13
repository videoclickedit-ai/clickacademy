"""Mapa de tiempos de una voz en off, sin transcriptor: tramos de habla y cortes internos, en segundos y frames.

Uso: python3 tiempos_vo.py audio/vo.mp3 [--fps 30]

Cómo leerlo:
- TRAMOS: habla entre pausas >= 0.15 s. Las pausas largas (>= 0.3 s) suelen separar frases o comas.
- Cortes dentro de cada tramo: caídas de energía. Las profundas (< -60 dB) son micro-pausas o
  consonantes oclusivas (p, t, k, d): marcan bordes de palabra o sílaba.
- Para ubicar cada palabra: asigná el texto del guion a los tramos en orden y repartí las sílabas
  de cada tramo en forma proporcional, ajustando al corte más cercano.
"""
import subprocess
import sys

import numpy as np

path = sys.argv[1]
fps = int(sys.argv[sys.argv.index("--fps") + 1]) if "--fps" in sys.argv else 30
raw = subprocess.run(["ffmpeg", "-v", "error", "-i", path, "-ac", "1", "-ar", "16000", "-f", "s16le", "-"],
                     capture_output=True, check=True).stdout
x = np.frombuffer(raw, dtype=np.int16).astype(np.float32) / 32768
hop = 160  # 10 ms
n = len(x) // hop
db = 20 * np.log10(np.sqrt(np.mean(x[: n * hop].reshape(n, hop) ** 2, axis=1)) + 1e-9)
sm = np.convolve(db, np.ones(3) / 3, mode="same")
dur = len(x) / 16000
silent = sm < -45

# tramos de habla
tramos, i = [], 0
while i < n:
    if not silent[i]:
        j = i
        while j < n and not (silent[j:j + 15].all() and len(silent[j:j + 15]) == 15):
            j += 1
        tramos.append((i / 100, j / 100))
        i = j
    i += 1

print(f"Duración VO: {dur:.2f} s  ({dur * fps:.0f} frames a {fps} fps)")
print(f"Duración sugerida del video: {np.ceil(dur + 0.6):.0f} s = {np.ceil(dur + 0.6) * fps:.0f} frames\n")
print("TRAMOS DE HABLA")
for k, (a, b) in enumerate(tramos):
    pausa = (tramos[k + 1][0] - b) if k + 1 < len(tramos) else 0
    cortes = []
    for m in range(int(a * 100) + 5, int(b * 100) - 5):
        w = sm[m - 5:m + 6]
        if sm[m] == w.min():
            pico = max(sm[max(0, m - 15):m].max(), sm[m + 1:m + 16].max())
            if pico - sm[m] > 9:
                cortes.append(f"{m / 100:.2f}s/f{m / 100 * fps:.0f}{'*' if sm[m] < -60 else ''}")
    print(f"{k + 1:2d}. {a:6.2f}-{b:6.2f}s  f{a * fps:4.0f}-f{b * fps:4.0f}  ({b - a:.2f}s)  pausa después {pausa:.2f}s")
    if cortes:
        print("      cortes: " + "  ".join(cortes))
print("\n* = caída profunda (micro-pausa u oclusiva)")
