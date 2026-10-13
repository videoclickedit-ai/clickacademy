"""Sintetiza SFX desde <proyecto>/sfx_events.json y los mezcla con la voz en off.

Uso: python3 sfx.py <proyecto>          -> <proyecto>/out/audio.wav (48 kHz, estéreo)

Tipos de evento (todos aceptan "frame", "gain", "pan" de -1 a 1):
  pop      freq=700 dur=0.16 decay=38   burbuja / aparición
  click    fuerza=1.0                    click táctil
  tick     freq=1900                     tic corto (checks, contadores)
  thud     -                             golpe grave (impacto, alarma)
  whoosh   dur=0.42                      transición
  chime    -                             notificación (dos notas)
  shimmer  dur=0.9                       brillo
  riser    dur=0.6                       subida antes de un impacto
  moneda   -                             moneda / caja registradora corta
  conteo   desde, hasta, pasos=[[frame_limite, cada_n_frames], ...], pendiente=6 (Hz por frame; negativa = baja)
  muestra  archivo="audio/x.wav", desde_seg=0, hasta_seg=None   usa un audio del usuario (SFX real)
  tipeo    desde, teclas=30, cada=1.2    teclado
  serie    frames=[...], sub={evento}    el mismo evento en varios frames
"""
import json
import os
import subprocess
import sys
import wave

import numpy as np

SR = 48000
rng = np.random.default_rng(7)


def t_(d):
    return np.arange(int(d * SR)) / SR


def env(t, a, d):
    return np.minimum(t / a, 1) * np.exp(-t * d)


def pop(freq=700, dur=0.16, decay=38, **_):
    t = t_(dur)
    f = freq * (0.55 + 1.1 * np.exp(-t * 40))
    s = np.sin(2 * np.pi * np.cumsum(f) / SR) * env(t, 0.002, decay)
    s[:200] += rng.normal(0, 0.25, 200) * np.linspace(1, 0, 200)
    return s


def click(fuerza=1.0, **_):
    t = t_(0.06)
    n = np.diff(rng.normal(0, 1, len(t) + 1)) * np.exp(-t * 900) * 0.5
    s = np.sin(2 * np.pi * 2600 * t) * np.exp(-t * 160) * 0.6
    b = np.sin(2 * np.pi * 180 * t) * np.exp(-t * 60) * 0.5 * fuerza
    return (n + s + b) * fuerza


def tick(freq=1900, **_):
    t = t_(0.025)
    return np.sin(2 * np.pi * freq * t) * np.exp(-t * 260)


def thud(**_):
    t = t_(0.45)
    f = 55 + 70 * np.exp(-t * 18)
    return np.sin(2 * np.pi * np.cumsum(f) / SR) * env(t, 0.003, 9)


def whoosh(dur=0.42, **_):
    t = t_(dur)
    n = rng.normal(0, 1, len(t))
    out = np.zeros_like(n)
    y = 0.0
    shape = np.sin(np.pi * t / dur) ** 2
    for i in range(len(n)):
        y += (0.02 + 0.25 * shape[i]) * (n[i] - y)
        out[i] = y
    out -= np.convolve(out, np.ones(64) / 64, mode="same")
    return out * shape * 2.2


def chime(**_):
    s = np.zeros(int(0.9 * SR))
    for k, (f, off) in enumerate([(1046.5, 0.0), (1568.0, 0.09)]):
        t = t_(0.8)
        tone = sum(a * np.sin(2 * np.pi * f * h * t) for h, a in [(1, 1), (2, .3), (3, .1)])
        i = int(off * SR)
        s[i:i + len(t)] += tone * env(t, 0.003, 7) * (0.9 if k else 0.7)
    return s


def shimmer(dur=0.9, **_):
    t = t_(dur)
    s = sum(np.sin(2 * np.pi * f * t + rng.uniform(0, 6)) * (0.6 + 0.4 * np.sin(2 * np.pi * rng.uniform(5, 11) * t))
            for f in rng.uniform(2200, 6500, 8))
    return s / 8 * np.minimum(t / 0.08, 1) * np.exp(-t * 4.5)


def moneda(**_):
    t = t_(0.7)
    s = sum(a * np.sin(2 * np.pi * f * t) * np.exp(-t * d) for f, a, d in
            [(2793, 1, 9), (4186, .6, 12), (5274, .35, 16), (7040, .2, 22)])
    s2 = np.zeros_like(s)
    k = int(0.06 * SR)
    s2[k:] = s[:-k] * 0.55
    return (s + s2) * np.minimum(t / 0.001, 1) * 0.6


def riser(dur=0.6, **_):
    t = t_(dur)
    tone = np.sin(2 * np.pi * np.cumsum(180 * (4.5 ** (t / dur))) / SR)
    n = rng.normal(0, 1, len(t))
    n -= np.convolve(n, np.ones(32) / 32, mode="same")
    return (tone * 0.6 + n * 0.25) * (t / dur) ** 2


SYNTH = dict(pop=pop, click=click, tick=tick, thud=thud, whoosh=whoosh, chime=chime, shimmer=shimmer, riser=riser,
             moneda=moneda)


def cargar(path, desde=0.0, hasta=None):
    """Audio del usuario -> estéreo float a SR."""
    args = ["ffmpeg", "-v", "error", "-ss", str(desde), "-i", path]
    if hasta is not None:
        args += ["-t", str(hasta - desde)]
    raw = subprocess.run(args + ["-ac", "2", "-ar", str(SR), "-f", "f32le", "-"], capture_output=True, check=True).stdout
    return np.frombuffer(raw, dtype=np.float32).reshape(-1, 2).T


def reverb(x, wet=0.18, length=0.5):
    t = t_(length)
    ir = rng.normal(0, 1, len(t)) * np.exp(-t * 9)
    ir[0] = 0
    n = 1 << int(np.ceil(np.log2(len(x) + len(ir))))
    y = np.fft.irfft(np.fft.rfft(x, n) * np.fft.rfft(ir, n), n)[:len(x)]
    y /= np.max(np.abs(y)) + 1e-9
    return x + y * wet * np.max(np.abs(x))


def main(proj):
    cfg = json.load(open(os.path.join(proj, "sfx_events.json")))
    fps, dur = cfg.get("fps", 30), cfg["duracion_seg"]
    N = int(dur * SR)
    L, R = np.zeros(N), np.zeros(N)

    def put(sig, frame, gain=1.0, pan=0.0):
        i = int(frame / fps * SR)
        if i < 0 or i >= N:
            return
        seg = sig[: N - i] * gain
        L[i:i + len(seg)] += seg * np.sqrt((1 - pan) / 2) * 1.414
        R[i:i + len(seg)] += seg * np.sqrt((1 + pan) / 2) * 1.414

    def play(ev):
        tipo, gain, pan = ev["tipo"], ev.get("gain", 0.3), ev.get("pan", 0.0)
        if tipo == "serie":
            for k, fr in enumerate(ev["frames"]):
                sub = dict(ev["sub"])
                if "freq" in sub and ev.get("subir_freq"):
                    sub["freq"] = sub["freq"] + k * ev["subir_freq"]
                play({**sub, "frame": fr})
        elif tipo == "muestra":
            st = cargar(os.path.join(proj, ev["archivo"]), ev.get("desde_seg", 0.0), ev.get("hasta_seg"))
            i = int(ev["frame"] / fps * SR)
            if 0 <= i < N:
                seg = st[:, : N - i] * gain
                L[i:i + seg.shape[1]] += seg[0] * min(1.0, 1 - pan)
                R[i:i + seg.shape[1]] += seg[1] * min(1.0, 1 + pan)
        elif tipo == "conteo":
            fr, f0 = float(ev["desde"]), float(ev["desde"])
            while fr < ev["hasta"]:
                put(tick(ev.get("freq", 2100) + (fr - f0) * ev.get("pendiente", 6)), fr, gain, rng.uniform(-.2, .2))
                fr += next((paso for lim, paso in ev["pasos"] if fr < lim), ev["pasos"][-1][1])
        elif tipo == "tipeo":
            for k in range(ev.get("teclas", 30)):
                put(click(0.25), ev["desde"] + k * ev.get("cada", 1.2) + rng.uniform(-.3, .3),
                    gain * rng.uniform(.6, 1), rng.uniform(-.2, .2))
        else:
            put(SYNTH[tipo](**ev), ev["frame"], gain, pan)

    for ev in cfg["eventos"]:
        play(ev)
    sfx = np.stack([reverb(L), reverb(R)])

    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", os.path.join(proj, cfg.get("vo", "audio/vo.mp3")), "-ac", "2",
                          "-ar", str(SR), "-f", "f32le", "-"], capture_output=True, check=True).stdout
    vo = np.frombuffer(raw, dtype=np.float32).reshape(-1, 2).T
    bus = np.zeros((2, N))
    bus[:, :min(N, vo.shape[1])] += vo[:, :N] * cfg.get("vo_gain", 0.9)
    bus += sfx * cfg.get("sfx_gain", 0.55)
    bus /= max(1.0, np.max(np.abs(bus)) / 0.95)

    os.makedirs(os.path.join(proj, "out"), exist_ok=True)
    dst = os.path.join(proj, "out", "audio.wav")
    with wave.open(dst, "wb") as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes((np.clip(bus.T, -1, 1) * 32767).astype(np.int16).tobytes())
    print("ok", dst)


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else ".")
