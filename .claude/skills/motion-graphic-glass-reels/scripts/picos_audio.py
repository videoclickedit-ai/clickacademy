"""Mide los SFX que manda el usuario para alinearlos: duración, arranque, pico y cola.

Uso: python3 picos_audio.py audio/whoosh.wav audio/boom.mp3 ...

Para que el PICO caiga en el frame F de un evento:
  - "frame" del evento  = F - (pico_seg - desde_seg) * fps
  - o recortá el arranque con "desde_seg" (útil en el frame 0, donde no hay lugar para el build).
"""
import subprocess
import sys

import numpy as np

for path in sys.argv[1:]:
    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", path, "-ac", "1", "-ar", "16000", "-f", "s16le", "-"],
                         capture_output=True, check=True).stdout
    x = np.frombuffer(raw, dtype=np.int16).astype(np.float32) / 32768
    hop = 160
    n = len(x) // hop
    db = 20 * np.log10(np.sqrt(np.mean(x[: n * hop].reshape(n, hop) ** 2, axis=1)) + 1e-9)
    pk = int(db.argmax())
    onset = next(i for i, v in enumerate(db) if v > db[pk] - 20)
    tail = next((i for i in range(len(db) - 1, pk, -1) if db[i] > db[pk] - 30), pk)
    print(f"{path}\n  duración {len(x) / 16000:.2f}s · arranque {onset / 100:.2f}s · PICO {pk / 100:.2f}s "
          f"({db[pk]:.1f} dB RMS) · cola hasta {tail / 100:.2f}s · pico {np.abs(x).max():.2f}")
