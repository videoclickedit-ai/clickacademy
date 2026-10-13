# Reel Claude — 1080x1920 · 30 fps · 27 s (810 f)

Referencia visual: GatesFX (vidrio 3D, fondos claros con pozos de azul).
Sistema visual completo: [`design-tokens.json`](design-tokens.json).

## Mapa de tiempos (desde la VO de ElevenLabs, 26,2 s)

Tiempos estimados por pausas del audio (±3 frames). Verificar contra la forma de onda en AE.

| Escena | Comp | Frames | Tiempo | Duración |
|---|---|---|---|---|
| 1 Hook | `01_Hook` | 0 – 120 | 0:00.0 – 0:04.0 | 120 f |
| 2 Problema | `02_Problema` | 120 – 292 | 0:04.0 – 0:09.7 | 172 f |
| 3 Solución | `03_Solucion` | 292 – 483 | 0:09.7 – 0:16.1 | 191 f |
| 4 Lección | `04_Leccion` | 483 – 652 | 0:16.1 – 0:21.7 | 169 f |
| 5 CTA | `05_CTA` | 652 – 810 | 0:21.7 – 0:27.0 | 158 f |

Momentos clave (frame absoluto en el MASTER):

| Frame | VO | Acción |
|---|---|---|
| 0 | "Este video…" | Pop del título + click |
| ~96 | "…minutos" | Resaltar "minutos" |
| 169 | "pensando la idea" | Tarjeta 1 + contador `00:15 hs` |
| 208 | "diseñando los assets" | Tarjeta 2 + contador `01:30 hs` |
| 256 | "editando desde cero" | Tarjeta 3 + contador `03:45 hs` |
| 296 | "Claude estructuró el guion" | Prompt tipeándose en el dashboard |
| 349 | "definió el estilo visual" | Muestras de color/tipo en el dashboard |
| 395 | "armó el paso a paso" | Lista de pasos |
| 452 | "…animarlo" | Click en **Generar** |
| 487 | "La IA no reemplaza tu creatividad" | Frase arriba (caption) |
| 574 | "multiplica…" | "MULTIPLICA" en impacto + gráfico sube + brillo |
| 703 | "comentá" | Entra "Comentá" |
| 723 | "CLAUDE" | Bloque "CLAUDE" pop + notificación |
| 741 | "y te envío el acceso" | Ícono de mensaje en el personaje |
| 776 – 810 | (fin VO) | Hold final |

## Composiciones

| Comp | Tamaño | Duración |
|---|---|---|
| `00_MASTER_Reel_Claude` | 1080x1920 · 30 fps | 810 f |
| `01_Hook` … `05_CTA` | 1080x1920 · 30 fps | ver tabla |
| `PRE_Fondo_Azul`, `PRE_Fondo_Rojo` | 1080x1920 | 810 f |
| `PRE_Personaje_Glass` | 1080x1080 | 810 f |
| `PRE_Tarjeta_Glass` | 800x560 | 300 f |
| `PRE_Dashboard` | 960x1200 | 200 f |
| `PRE_Grafico` | 760x520 | 180 f |
| `PRE_Cursor_Glass` | 200x200 | 60 f |

## Panel de proyecto

```
REEL_CLAUDE/
├── 01_COMPS/
│   ├── 00_MASTER/
│   ├── 01_ESCENAS/
│   └── 02_PRECOMPS/
├── 02_ASSETS/
│   ├── Glass_3D/        personaje, cursor, burbujas
│   ├── UI/              dashboard, botón Generar
│   ├── Iconos/          reloj, mensaje
│   └── Fondos/
├── 03_AUDIO/
│   ├── VO/
│   └── Musica/
├── 04_SFX/              pop, click, conteo, notificacion, whoosh
├── 05_REFERENCIAS/
├── 06_RENDERS/
└── 99_SOLIDS/
```

## Capas — Escena 1 (Hook)

| # | Capa | Tipo |
|---|---|---|
| 1 | `ADJ_Glow` | Ajuste |
| 2 | `ADJ_DOF` | Ajuste |
| 3 | `CAM_Main` (push-in suave) | Cámara |
| 4 | `NULL_Cam` | Null |
| 5 | `TXT_Hook_L1` "Este video lo hizo Claude" | Texto |
| 6 | `TXT_Hook_L2` "en solo unos minutos." | Texto |
| 7 | `NULL_Texto_Pop` (padre de 5 y 6) | Null |
| 8 | `PRE_Personaje_Glass` | Precomp |
| 9 | `SHP_Sombra_Personaje` | Forma |
| 10 | `SHP_Burbuja_01..03` (desenfocadas) | Forma |
| 11 | `PRE_Fondo_Azul` | Precomp |

## Capas — Escena 2 (Problema)

| # | Capa | Tipo |
|---|---|---|
| 1 | `ADJ_Glow` | Ajuste |
| 2 | `CAM_Main` | Cámara |
| 3 | `NULL_Cam_Shake` (wiggle) | Null |
| 4 | `TXT_Contador` | Texto (expresión) |
| 5 | `TXT_Caption` (palabra por palabra) | Texto |
| 6 | `NULL_Stack_Tarjetas` | Null |
| 7 | `PRE_Tarjeta_Idea` / `_Assets` / `_Edicion` | Precomp |
| 8 | `PRE_Personaje_Glass` (variante roja) | Precomp |
| 9 | `SHP_Glow_Rojo` | Forma |
| 10 | `PRE_Fondo_Rojo` (entra desde azul) | Precomp |

Expresión para `TXT_Contador` → Source Text (frames relativos a la comp `02_Problema`):

```js
var f = timeToFrames(time);
var m = f < 49 ? linear(f, 0, 49, 0, 15)
      : f < 88 ? linear(f, 49, 88, 15, 90)
      : f < 136 ? linear(f, 88, 136, 90, 225)
      : 225;
m = Math.round(m);
var h = Math.floor(m / 60), mm = m % 60;
(h < 10 ? "0" : "") + h + ":" + (mm < 10 ? "0" : "") + mm + " hs";
```
