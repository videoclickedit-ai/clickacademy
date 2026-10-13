"""Une los stills de <proyecto>/out en hojas de 6 para revisarlos de un vistazo.

Uso: python3 hoja_contactos.py <proyecto>/out   -> <proyecto>/out/hoja_stills_N.png
"""
import glob
import os
import sys

from PIL import Image

d = sys.argv[1]
fs = sorted(glob.glob(os.path.join(d, "still_*.png")))
w, h = 300, 533
for k in range(0, len(fs), 6):
    grp = fs[k:k + 6]
    sheet = Image.new("RGB", (w * len(grp), h), "white")
    for i, f in enumerate(grp):
        sheet.paste(Image.open(f).convert("RGB").resize((w, h)), (i * w, 0))
    dst = os.path.join(d, f"hoja_stills_{k // 6}.png")
    sheet.save(dst)
    print(dst, [os.path.basename(f) for f in grp])
