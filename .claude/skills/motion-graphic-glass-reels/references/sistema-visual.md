# Sistema visual · Glass Reels (1080x1920, 30 fps)

## Paleta

| Rol | HEX |
|---|---|
| Blanco (luz) | `#FFFFFF` |
| Niebla (fondo arriba) | `#E4ECFB` |
| Ice (acento) | `#A4C6FF` |
| Cielo | `#6E9BEA` |
| Azul eléctrico (pozos, núcleo del personaje) | `#2A5BDB` |
| Cobalto (marca, resaltados) | `#1240AB` |
| Navy (títulos) | `#0B2E73` |
| Caption | `#1A1F2E` |
| Alerta magenta | `#B31240` |
| Rojo pico | `#E0262B` |
| Rosa claro | `#F6C9D3` |
| Violeta (transición azul → rojo) | `#6B3FA0` |

**Fondo** = 4 capas: luz blanca radial arriba a la derecha (84%, 6%), pozo azul eléctrico
abajo a la izquierda (6%, 60%), pozo `#6E9BEA` abajo, y un lineal `#E4ECFB → #A4C6FF → #8FADEF`.
Las posiciones derivan lento (sin/cos) para que el fondo respire. Grano 7% en overlay.
El estado rojo usa `#FFFFFF → #F6C9D3 → #E0262B` con pozo `#B31240`, y el cambio pasa por violeta
en 12 frames.

## Vidrio

| Propiedad | Valor |
|---|---|
| Relleno cobalto | degradado a 135°: `rgba(234,241,255,.45)` → `rgba(42,91,219,.80)` |
| Relleno ice | `rgba(255,255,255,.38)` → `rgba(255,255,255,.14)` |
| Relleno rojo | `rgba(255,236,240,.55)` → `rgba(179,18,64,.80)` |
| Borde | 2 px, degradado vertical blanco 80% → 15% (máscara `xor`) |
| Desenfoque de fondo | `backdrop-filter: blur(24px) saturate(140%)` |
| Sombra | `0 24px 60px rgba(11,46,115,.22)` (navy, nunca negro) + inner glow blanco 35% |
| Radio | 40 px en grandes, 28 px en chicas, 999 px en pastillas |
| 3D | `perspective(1800px) rotateX(6–8°) rotateY(-6 ± 3°)` + flotación senoidal de 6 px |

## Personaje burbuja

- Cabeza de 220 px: radial con núcleo de color (`--core`) → borde casi blanco, aro blanco de
  3 px, glow del color del núcleo y brillo especular arriba a la izquierda.
- Ojos: puntos blancos de 18 px con glow. Boca: arco blanco de 5 px (`.sad` lo invierte).
- Cuerpo: cápsula de 440x560 con degradado blanco → transparente y máscara que lo funde abajo.
- Estados: azul (`--core #2A5BDB`), rojo (`.red`), triste (`.sad`), gota de sudor (`.drop`).
- Vida: respiración (bob), parpadeo de 4 frames, temblor (`shake`) cuando hay estrés.

## Tipografía

| Rol | Fuente | Tamaño |
|---|---|---|
| Caption de la voz | Inter SemiBold | 52–64 px, interlineado 66–68 |
| Palabra de impacto | Inter Display Black, tracking -0.045em | 150–250 px (máx. ~10 letras a 150 px) |
| Subtítulo cursiva | Inter Display Bold Italic, cobalto | 60–78 px |
| Contador | Inter Display Black, `tabular-nums` | 150–160 px |
| Etiqueta (overline) | Inter Bold, tracking .18em, gris 60% | 30 px |
| UI dentro de tarjetas | Inter 500–800 | 26–48 px |

Palabras resaltadas: `.hl` (cobalto), `.hlr` (magenta) o un bloque cobalto con texto blanco que
se abre de izquierda a derecha.

## Movimiento

| Recurso | Receta |
|---|---|
| Pop | `spring(f - inicio)` → 0 → ~115% → 100% en ~15 frames |
| Palabra | opacidad 0 → 1 + Y +26 px → 0 en 6 frames, desde 1 frame antes de la sílaba |
| Transición | la escena que sale hace zoom a 114% + blur 18 px en 8 frames; la que entra va de 90% a 100% |
| Cámara | zoom lento de 1 → 1.03 durante toda la escena |
| Click | botón a 90% (3 frames) → resorte, ripple, glow, cambio de label y barra de progreso |
| Impacto | resorte + brillo que barre la palabra o tarjeta + destellos |
| Contador | lineal por tramos, con un pulso de escala en cada hito y temblor al llegar al máximo |

## Layout

- Márgenes laterales de 80 px. Texto entre y=250 e y=1420.
- Captions arriba (y ≈ 236–330); el objeto principal al centro (y 430–1430); el personaje abajo
  o a la derecha en el CTA.
- El lado derecho, desde y≈1100, queda bajo los botones de Instagram: no pongas texto ahí.
