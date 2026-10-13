---
name: motion-graphic-glass-reels
description: Motion graphics verticales (Reels/TikTok/Shorts 9:16) de punta a punta. ANALIZA un reel de referencia y entrega un informe con ADN visual, ficha técnica, storyboard con coordenadas, keyframes, sound design y el GUION ADAPTADO a lo que el usuario quiere comunicar, con indicaciones claras escena por escena. Y PRODUCE el video terminado (MP4 con voz + SFX) renderizado acá con HTML + Chromium + ffmpeg, sin After Effects. Estilo base vidrio 3D / glassmorphism, adaptable al de la referencia (dark neón, flat, etc.). Usar SIEMPRE que pidan "analizá este reel", "sacá el ADN visual", "desarmá esta referencia", "adaptá este guion a mi mensaje", "storyboard de este video", "haceme un motion graphic", "animá este guion", "video animado con esta voz", "como esta referencia pero con mi guion", o cuando suban un video de referencia, un guion por escenas o una voz en off para un reel animado. También para cambiar y re-renderizar un reel hecho con esta skill. NO usar para editar video filmado (talking head).
---

# Motion Graphic · Glass Reels

Dos modos, que suelen ir encadenados:

| Modo | Cuándo | Entregás |
|---|---|---|
| **1 · Analizar y adaptar** | Suben un reel de referencia y quieren entenderlo o usarlo para su mensaje | `informe.md`: ADN, ficha técnica, storyboard medido, guion adaptado y qué poner en cada escena |
| **2 · Producir** | Hay guion (o un informe) + voz en off | MP4 terminado con voz + SFX |

Si suben una referencia **y** su guion/voz, hacé el 1 y seguí con el 2 sin preguntar. Si solo suben
la referencia, entregá el informe y cerrá con una línea: "¿Lo produzco? Mandame la voz en off".

## Modo 1 · Analizar y adaptar

1. **Archivo.** Necesitás el video. Si mandan un link y no se puede bajar, pedí el archivo.
2. **Medir.** `python3 scripts/analizar_referencia.py ref.mp4 <proyecto>/ref`. Leé el resumen y
   `analisis.json` (ficha, cambios de plano, paleta HEX, tramos de voz, golpes de sonido).
3. **Mirar.** Abrí las `hoja_XX.png` (narrativa y texto en pantalla) y cada `escena_XX_grilla.png`
   (grilla del 10 %: de ahí salen las coordenadas X/Y en %). Leé el guion del texto en pantalla. Si
   no hay texto ni transcripción, pedíselo al usuario: no lo inventes.
4. **Mensaje del usuario.** Tema, público, dolor y CTA. Usá lo que ya se sepa de la conversación.
   Si falta algo, preguntá una sola vez, todo junto.
5. **Escribir** `<proyecto>/informe.md` con la plantilla y las reglas de adaptación de
   `references/informe-referencia.md` (secciones A–P). Separá lo medido de lo estimado. El guion
   adaptado mantiene la estructura de la referencia (beats, duración y palabras por beat) y cambia el
   contenido. Cada escena del storyboard adaptado dice qué texto, qué elemento, dónde, qué hace,
   cuándo, qué SFX y qué color.
6. **Entregar.** Mandá el archivo y, en el chat, 4–5 líneas: estilo en una frase, estructura, guion
   adaptado completo y qué hace falta para producirlo.

## Modo 2 · Producir

Entregás un **MP4 terminado** (video + voz + SFX), no un tutorial de After Effects. Todo se arma
en HTML, Chromium captura frame por frame y ffmpeg codifica. La plantilla en
`assets/plantilla/` es un reel real aprobado por el usuario: partí siempre de ahí.

El motor no está atado al vidrio: si viene de un informe con otro estilo (dark neón, flat…),
cambiá los tokens (`:root`, `BG`, glow, tipografía) según el ADN y seguí el storyboard adaptado (N).

### Qué pedir (una sola vez, solo si falta)

- **Guion por escenas**: texto exacto de la voz + qué se ve en cada escena (o el informe del Modo 1).
- **Voz en off** (mp3/wav). Los tiempos salen de la voz: sin ella, los cortes son adivinados.
  Si no está, preguntá si la tiene antes de animar.
- Opcional: **video de referencia**, paleta/marca y **sonidos propios**.

### Flujo

1. **Proyecto.** Creá `<proyecto>/` y copiá `assets/plantilla/index.html` y `sfx_events.json`.
   Poné la voz en `<proyecto>/audio/vo.mp3`.

2. **Referencia (si hay).** Si ya hay informe, usalo. Si no, corré
   `python3 scripts/analizar_referencia.py ref.mp4 <proyecto>/ref` y mirá las hojas. Copiá los
   colores reales que imprime, no los que "parecen".

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
