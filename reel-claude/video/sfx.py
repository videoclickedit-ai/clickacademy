"""Sintetiza los SFX del reel y los mezcla con la voz en off -> out/audio.wav (27 s, 48 kHz, estéreo)."""
import os
import subprocess
import wave

import numpy as np

SR = 48000
FPS = 30
DUR = 27.0
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "out")
rng = np.random.default_rng(7)


def t_(d):
    return np.arange(int(d * SR)) / SR


def env(t, a, d):
    return np.minimum(t / a, 1) * np.exp(-t * d)


def pop(f0=700, dur=0.16, decay=38):
    t = t_(dur)
    f = f0 * (0.55 + 1.1 * np.exp(-t * 40))
    s = np.sin(2 * np.pi * np.cumsum(f) / SR) * env(t, 0.002, decay)
    s[:200] += rng.normal(0, 0.25, 200) * np.linspace(1, 0, 200)
    return s


def click(strong=1.0):
    t = t_(0.06)
    n = np.diff(rng.normal(0, 1, len(t) + 1)) * np.exp(-t * 900) * 0.5
    s = np.sin(2 * np.pi * 2600 * t) * np.exp(-t * 160) * 0.6
    b = np.sin(2 * np.pi * 180 * t) * np.exp(-t * 60) * 0.5 * strong
    return (n + s + b) * strong


def tick(f=1900, a=1.0):
    t = t_(0.025)
    return np.sin(2 * np.pi * f * t) * np.exp(-t * 260) * a


def thud():
    t = t_(0.45)
    f = 55 + 70 * np.exp(-t * 18)
    return np.sin(2 * np.pi * np.cumsum(f) / SR) * env(t, 0.003, 9)


def whoosh(dur=0.42):
    t = t_(dur)
    n = rng.normal(0, 1, len(t))
    out = np.zeros_like(n)
    y = 0.0
    shape = np.sin(np.pi * t / dur) ** 2
    for i in range(len(n)):
        a = 0.02 + 0.25 * shape[i]
        y += a * (n[i] - y)
        out[i] = y
    out -= np.convolve(out, np.ones(64) / 64, mode="same")  # quita graves
    return out * shape * 2.2


def chime():
    s = np.zeros(int(0.9 * SR))
    for k, (f, off) in enumerate([(1046.5, 0.0), (1568.0, 0.09)]):
        t = t_(0.8)
        tone = sum(a * np.sin(2 * np.pi * f * h * t) for h, a in [(1, 1), (2, .3), (3, .1)])
        i = int(off * SR)
        s[i:i + len(t)] += tone * env(t, 0.003, 7) * (0.9 if k else 0.7)
    return s


def shimmer(dur=0.9):
    t = t_(dur)
    s = sum(np.sin(2 * np.pi * f * t + rng.uniform(0, 6)) * (0.6 + 0.4 * np.sin(2 * np.pi * rng.uniform(5, 11) * t))
            for f in rng.uniform(2200, 6500, 8))
    e = np.minimum(t / 0.08, 1) * np.exp(-t * 4.5)
    return s / 8 * e


def riser(dur=0.6):
    t = t_(dur)
    f = 180 * (4.5 ** (t / dur))
    tone = np.sin(2 * np.pi * np.cumsum(f) / SR)
    n = rng.normal(0, 1, len(t))
    n -= np.convolve(n, np.ones(32) / 32, mode="same")
    e = (t / dur) ** 2
    return (tone * 0.6 + n * 0.25) * e


def reverb(x, wet=0.18, length=0.5):
    t = t_(length)
    ir = rng.normal(0, 1, len(t)) * np.exp(-t * 9)
    ir[0] = 0
    n = 1 << int(np.ceil(np.log2(len(x) + len(ir))))
    y = np.fft.irfft(np.fft.rfft(x, n) * np.fft.rfft(ir, n), n)[:len(x)]
    y /= np.max(np.abs(y)) + 1e-9
    return x + y * wet * np.max(np.abs(x))


# ---------------- línea de tiempo (frames a 30 fps) ----------------
N = int(DUR * SR)
L = np.zeros(N)
R = np.zeros(N)


def put(sig, frame, gain=1.0, pan=0.0):
    i = int(frame / FPS * SR)
    if i >= N:
        return
    seg = sig[: N - i] * gain
    L[i:i + len(seg)] += seg * np.sqrt((1 - pan) / 2) * 1.414
    R[i:i + len(seg)] += seg * np.sqrt((1 + pan) / 2) * 1.414


# Escena 1 · Hook
put(pop(950), 0, 0.35)
put(click(0.6), 1, 0.25)
put(pop(560, 0.22, 26), 49, 0.55)
put(shimmer(0.8), 50, 0.22, 0.3)
put(pop(1100), 63, 0.2)
put(click(0.5), 93, 0.3)
put(pop(1300), 94, 0.2)

# Transiciones
for fr, pan in [(113, -0.4), (285, 0.4), (476, -0.4), (645, 0.4)]:
    put(whoosh(), fr, 0.4, pan)

# Escena 2 · Problema: conteo acelerado + tarjetas
fr, step = 121.0, 3.0
while fr < 256:
    put(tick(2100 + (fr - 121) * 6, 1), fr, 0.12, rng.uniform(-.2, .2))
    step = 3.0 if fr < 169 else 2.0 if fr < 207 else 1.4
    fr += step
for fr in (169, 207):
    put(pop(480, 0.2, 28), fr, 0.5)
put(pop(420, 0.22, 26), 256, 0.5)
put(thud(), 256, 0.55)
for fr, pan in [(226, -.5), (238, .5), (264, .4), (271, -.5), (279, 0)]:
    put(pop(1150, 0.12, 50), fr, 0.22, pan)

# Escena 3 · Solución
put(pop(380, 0.22, 24), 294, 0.4)
for k in range(34):
    put(click(0.25), 300 + k * 1.2 + rng.uniform(-.3, .3), 0.18 * rng.uniform(.6, 1), rng.uniform(-.2, .2))
for fr in (312, 317, 322, 327, 332):
    put(tick(2600), fr, 0.18)
for k, fr in enumerate((352, 356, 360, 364)):
    put(pop(1000 + k * 140, 0.12, 45), fr, 0.22)
for fr in (400, 413, 426):
    put(tick(2300), fr, 0.2)
put(pop(700, 0.16, 34), 430, 0.3)
put(whoosh(0.3), 432, 0.12, 0.6)
put(click(1.4), 456, 0.6)
put(shimmer(0.9), 459, 0.22)

# Escena 4 · Lección
put(pop(420, 0.2, 26), 485, 0.3)
put(riser(0.55), 557, 0.35)
put(thud(), 572, 0.6)
put(pop(520, 0.22, 24), 572, 0.45)
put(shimmer(1.1), 576, 0.3, -0.2)
for k, fr in enumerate(range(577, 606, 3)):
    put(tick(1500 + k * 140), fr, 0.14)
put(pop(1250, 0.12, 45), 606, 0.25)

# Escena 5 · CTA
put(pop(500, 0.2, 26), 701, 0.5)
put(pop(450, 0.22, 24), 721, 0.5)
put(chime(), 723, 0.42)
put(tick(2800), 727, 0.2)
put(pop(1100, 0.12, 45), 741, 0.18)
put(shimmer(1.2), 776, 0.14)

sfx = np.stack([reverb(L), reverb(R)])

# ---------------- voz en off ----------------
raw = subprocess.run(["ffmpeg", "-v", "error", "-i", os.path.join(HERE, "audio", "vo.mp3"), "-ac", "2", "-ar", str(SR),
                      "-f", "f32le", "-"], capture_output=True, check=True).stdout
vo = np.frombuffer(raw, dtype=np.float32).reshape(-1, 2).T
mixbus = np.zeros((2, N))
mixbus[:, :min(N, vo.shape[1])] += vo[:, :N] * 0.9
mixbus += sfx * 0.55
mixbus /= max(1.0, np.max(np.abs(mixbus)) / 0.95)

os.makedirs(OUT, exist_ok=True)
pcm = (np.clip(mixbus.T, -1, 1) * 32767).astype(np.int16)
with wave.open(os.path.join(OUT, "audio.wav"), "wb") as w:
    w.setnchannels(2)
    w.setsampwidth(2)
    w.setframerate(SR)
    w.writeframes(pcm.tobytes())
print("ok", os.path.join(OUT, "audio.wav"))
