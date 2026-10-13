---
name: motion-graphic-glass-reels
description: Crea y RENDERIZA videos de MOTION GRAPHICS verticales (Reels / TikTok / Shorts 9:16, 1080x1920, 30 fps) con estética de vidrio 3D / glassmorphism — fondos claros con pozos de azul cobalto, tarjetas de vidrio esmerilado, personaje burbuja, captions palabra por palabra sincronizados a la voz en off, contadores, dashboards con click, gráficos que crecen y CTA con notificación — y entrega el MP4 terminado con voz + SFX, sin After Effects (HTML + Chromium + ffmpeg). Usar SIEMPRE que pidan "haceme un motion graphic", "animá este guion", "video animado con esta voz en off", "reel en motion graphics", "estilo vidrio / glass / burbujas 3D", "como esta referencia pero con mi guion", "creámelo acá, no en After", o cuando entreguen un guion por escenas + una voz (ElevenLabs u otra) y quieran el video listo. También para cambiar textos, tiempos o colores de un reel ya hecho con esta skill y re-renderizarlo. NO usar para editar video filmado (talking head, cortes de cámara) ni para generar clips con IA de video.
---

# Motion Graphic · Glass Reels

Entregás un **MP4 terminado** (video + voz + SFX), no un tutorial de After Effects. Todo se arma
en HTML, Chromium captura frame por frame y ffmpeg codifica. La plantilla en
`assets/plantilla/` es un reel real aprobado por el usuario: partí siempre de ahí.

## Qué pedir (una sola vez, solo si falta)

- **Guion por escenas**: texto exacto de la voz + qué se ve en cada escena.
- **Voz en off** (mp3/wav). Los tiempos salen de la voz: sin ella, los cortes son adivinados.
  Si no está, preguntá si la tiene antes de animar.
- Opcional: **video de referencia** y paleta/marca. Sin referencia, usá el sistema por defecto.

## Flujo

1. **Proyecto.** Creá `<proyecto>/` y copiá `assets/plantilla/index.html` y `sfx_events.json`.
   Poné la voz en `<proyecto>/audio/vo.mp3`.

2. **Referencia (si hay).** `python3 scripts/analizar_referencia.py ref.mp4 <proyecto>/ref` y
   mirá las hojas. Copiá los colores reales que imprime, no los que "parecen". Anotá: tipo de
   fondo, jerarquía tipográfica, cómo entra cada elemento, cómo son las transiciones.

3. **Tiempos.** `python3 scripts/tiempos_vo.py <proyecto>/audio/vo.mp3`. Asigná el guion a los
   tramos en orden y repartí las sílabas de cada tramo; ajustá cada palabra al corte más cercano.
   La duración del video la manda la voz (VO + ~0.6 s de cierre). Si el usuario pidió una
   duración menor, decíselo: acelerar más de ~8% se nota, no lo comprimas en silencio.

4. **Mapa de escenas.** Antes de codear, escribí una tabla: escena, frames, y cada evento clave
   con su frame (aparición de palabra, pop, click, impacto). Cortá cada escena **4 frames antes**
   de que arranque su frase: la imagen anticipa a la voz.

5. **Construir `index.html`** adaptando la plantilla (el comentario de arriba explica cómo).
   Todo se calcula desde el número de frame en `renderFrame(f)`, así el render es exacto y
   reproducible. Reutilizá los bloques antes de inventar nuevos:

   | Bloque | Dónde está en la plantilla | Sirve para |
   |---|---|---|
   | Fondo vivo azul ↔ rojo (vía violeta) | `bgAt()` | Cambiar el clima entre problema y solución |
   | Personaje burbuja (feliz / triste / rojo) | `.char` + `animChar()` | Hook, problema, CTA |
   | Tarjetas de vidrio (cobalto / ice / roja) | `.glass` | Contenido, caos, dashboards |
   | Caption palabra por palabra | `phraseGroup()` / `buildCaption()` | Toda la voz en off |
   | Título + palabra de impacto + resaltado | escena `s1` | Hook |
   | Contador acelerado + tarjetas apilándose | escena `s2` | Problema / tiempo perdido |
   | Dashboard: prompt tipeándose, chips, pasos, botón con cursor, click y ripple | escena `s3` | Proceso / solución |
   | Gráfico que crece + "xN" + destellos | escena `s4` | Resultado / lección |
   | Bloque de palabra clave + burbuja de mensaje con badge | escena `s5` | CTA "comentá X" |

6. **Previsualizar y corregir.** `node scripts/render.js <proyecto> --stills 0,…` con un frame
   por evento clave y por borde de transición, después `python3 scripts/hoja_contactos.py
   <proyecto>/out` y mirá las hojas. Corregí y repetí hasta que estén limpias. Revisá
   `references/errores-comunes.md`: tiene los problemas que ya aparecieron y su arreglo.

7. **SFX.** Editá `sfx_events.json`: un evento por cada pop, click, impacto y transición, en el
   mismo frame que el visual. Los tipos disponibles están documentados al inicio de `scripts/sfx.py`.
   Los SFX acompañan; la voz siempre manda (gain 0.1–0.6).
   **Si el usuario manda sus propios sonidos, usalos primero** (tipo `muestra`) y sintetizá solo lo
   que falte. Medilos con `python3 scripts/picos_audio.py audio/*.wav`: un whoosh o un boom tienen
   el pico en el medio, no al principio. Alineá el **pico** con el frame del evento (arrancá el
   archivo `pico × fps` frames antes o recortá el inicio con `desde_seg`). Un archivo de 8 s con
   build y cola es un riser + impacto, no música: no lo uses como fondo.

8. **Render final.** `bash scripts/build.sh <proyecto>` → `<proyecto>/out/final.mp4`
   (unos 5 min para 800 frames; correlo en segundo plano). El build normaliza a -14 LUFS para Instagram.

9. **Entregar.** Mandá el MP4 con la herramienta de archivos si existe, y en pocas líneas:
   duración, qué agregaste que no estaba en el guion, qué sonido usaste en cada momento, si no
   tiene música (sugerí un audio en tendencia a volumen bajo), la fuente usada, que la sincronía es estimada (±3 frames) y qué
   segundo conviene usar de portada.

## Sistema visual

El detalle (paleta HEX, vidrio, personaje, tipografía, movimiento) está en
`references/sistema-visual.md`. Lo esencial:

- **Fondo claro con pozos de cobalto**, no azul oscuro plano: luz blanca arriba a la derecha y
  azul eléctrico abajo a la izquierda. Rojo/magenta solo para el problema.
- **Jerarquía**: caption chico (Inter SemiBold 56 px, gris casi negro) + una palabra de impacto
  enorme (Inter Display Black 150–250 px). Una palabra de impacto por escena.
- **Texto entre y=250 e y=1420**: abajo lo tapa la interfaz de Reels.
- **El frame 0 tiene contenido** (personaje + primera palabra): es la portada por defecto.
- **Pops con resorte** (0 → 115% → 100%), entradas de palabra en 6 frames, transiciones
  zoom + blur de 8 frames con whoosh.

## Entorno

Necesita Chromium (Playwright), ffmpeg con libx264, python3 con numpy y Pillow. `render.js`
busca Playwright como módulo local, global o en `PLAYWRIGHT_MODULE`. Si la red bloquea fuentes
externas, usá las del sistema (Inter / Inter Display). Si Montserrat y Anton están instaladas,
encajan mejor con la referencia: cambiá el `font-family`.
