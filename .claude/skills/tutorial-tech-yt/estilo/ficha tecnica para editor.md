# Ficha técnica para editor: Tutorial Tech YT

- **Estilo:** Tutorial Tech YT
- **Referencia analizada:** `videoplayback.mp4` (tutorial de CapCut de un canal de YouTube), **solo minuto 0:00–1:00**
- **Formato:** horizontal 16:9. La fuente vino en 640×360; armar el proyecto en **1920×1080**. Todos los px de esta ficha ya están pasados a 1080p.
- **Estructura del minuto:**
  - **0:00–0:21.8, hook:** promesa + logos + gráficas + texto a pantalla completa.
  - **0:21.8–0:24, ejemplo:** B-roll.
  - **0:24–0:32.2, explicación:** a cámara.
  - **0:32.2–1:00, tutorial:** grabación de pantalla.

> Todo lo que lleva **(estimado)** no se pudo medir directo: no había transcripción (faster-whisper no se pudo instalar en este entorno) y el audio no se escucha, se mide.

---

## 1. Ritmo y estilo de cortes

**Qué hace**
- El minuto tiene dos velocidades:
  - **Hook (0–24 s):** muy rápido, cambia algo en pantalla todo el tiempo.
  - **Explicación y tutorial (24–60 s):** mucho más calmo.
- Cortes secos entre planos a cámara.
- Hay jump cuts con el mismo encuadre para sacar pausas.
- Usa tres transiciones con efecto:
  - destello de luz roja (light leak);
  - barrido de luz blanca;
  - salida del logo con desenfoque de movimiento.

**Valores**

| Tramo | Eventos visuales | Un cambio cada | Rango |
| --- | --- | --- | --- |
| 0–24 s (hook) | 19 | **1,26 s** | 0,12 s a 3,8 s |
| 24–32,2 s (a cámara) | 3 (2 jump cuts + 1 corte) | 2,7 s | 1,5 s a 3,4 s |
| 32,2–60 s (pantalla) | 1 (reencuadre a 57,3 s) | 27 s | — |

- **Cortes duros detectados:** 10 en el minuto, en 6,08 · 9,92 · 14,33 · 16,67 · 18,42 · 19,5 · 20,75 · 24,0 · 32,25 y 57,33 s.
- **Jump cuts sin cambiar de encuadre:** 25,5 y 28,8 s.
- **Silencios de más de 0,15 s:**
  - En el hook hay 1 solo (3,9 s), o sea que los silencios están recortados.
  - En la parte de pantalla hay 12: ahí no se recortan las pausas.
- **Transiciones con efecto:**
  - destello rojo a los 4,95 s (≈0,35 s), sobre un jump cut;
  - destello rojo a los 21,8 s (≈0,35 s), de cámara a B-roll;
  - barrido de luz blanca a los 14,35 s (≈0,25 s), de cámara a placa violeta.

**Cómo replicarlo en CapCut**
- **Hook:**
  - Cortá cada pausa de más de 0,15 s.
  - Meté un elemento nuevo (logo, gráfica, texto, B-roll o corte) cada 1–1,5 s.
  - No dejes ningún plano limpio a cámara más de 2 s sin algo encima.
- **Explicación a cámara:** jump cuts en las pausas, sin cambiar el encuadre, uno cada 1,5–3,5 s.
- **Tutorial de pantalla:** casi sin edición. Solo los reencuadres que hagan falta para que se lea la interfaz.
- **Transiciones:**
  - Efectos → Transiciones → tipo "Light leak / Destello" en rojo, 0,3–0,4 s.
  - Barrido de luz blanca de 0,25 s cuando entra una placa gráfica.
  - Todo lo demás, corte seco.

---

## 2. Subtítulos y textos

**Qué hace**
- No hay subtítulos continuos. En el minuto hay **una sola frase subtitulada**.
- Los textos grandes son **tipografía cinética a pantalla completa**, con fondo de color plano.
- Hay cuatro sistemas de texto:

| Sistema | Dónde | Fuente (la más parecida) | Color | Tamaño medido (1080p) | Posición |
| --- | --- | --- | --- | --- | --- |
| **A. Texto cinético a pantalla completa** | 18,4–20,75 s | **Akkordeon**, en mayúsculas (elegida por el usuario; la referencia usa una condensada tipo Anton) | Blanco `#F3E9E8` sobre rojo `#D62C21`, o rojo `#E22F20` sobre blanco `#F7F7F7` | Altura de mayúscula 216 px (2 palabras por línea) a 258 px (1 palabra por línea) | Centrado (x 50 %, y 50 %) |
| **B. Subtítulo** | 20,98–21,8 s | Sans regular/medium, en minúsculas con mayúscula inicial y tracking apretado, tipo **SF Pro Display Medium** / Inter Medium | Blanco `#F3F2F2` con sombra suave | ≈51 px de ascendente a descendente | Centrado en x, **y ≈ 85 %** (918 px) |
| **C. Manuscrita en gráficas** | 6–10 s y 14,6–16,7 s | Marcador/pincel, tipo **Caveat Brush** / Kalam Bold | Blanco sobre `#131313`; violeta `#5F42BF` sobre placa `#ECE6F9` | Título ≈ 8–12 % del alto | Izquierda o centro de la gráfica |
| **D. Versalitas espaciadas** | 14,6–16,7 s | Sans bold, en mayúsculas, con tracking muy abierto | Gris | Chico (≈3 % del alto) | Arriba del título de la placa |

- **Palabras por bloque:**
  - **A:** 2 palabras por línea ("THAT STOP / THE SCROLL") o 1 palabra por línea ("EVERY / SINGLE / TIME"). Las líneas se suman de a una hacia abajo, con interlineado apretado (≈1,05–1,1).
  - **B:** frase de 4 palabras en una línea ("Let's get into this").
- **Animación:**
  - **A:** cada bloque entra con fade rápido (≈0,1 s: aparece al 40 % de opacidad y llega al 100 %). Entra un bloque nuevo cada 0,12–0,4 s. **A 8 fps no se ve rebote.**
  - **B:** aparece palabra por palabra, ≈0,12 s por palabra.
  - **C:** se va construyendo (en la línea de tiempo aparecen los puntos de a uno, ≈0,35 s cada uno). La línea de abajo entra con fade.
- **Resaltado:** no hay palabras resaltadas dentro de un bloque. El énfasis está en **el bloque entero**: color de fondo plano (rojo o blanco) con texto en el color opuesto. No hay amarillo en los textos del editor; el amarillo aparece solo dentro de las miniaturas de YouTube.
- **Para qué se usan:** los textos A tapan la cámara justo en la frase-promesa del hook ("that stop the scroll every single time"). El subtítulo B aparece solo en la frase que cierra el hook.

**Cómo replicarlo en CapCut**
- **Texto A:**
  - Fondo: un sólido rojo `#D62C21` (o blanco `#F7F7F7`) con un degradado radial suave (centro un poco más claro).
  - Texto con **Akkordeon** en mayúsculas, centrado, sin borde ni sombra.
  - Tamaño: que la mayúscula mida **216 px** de alto (2 palabras por línea) o **258 px** (1 palabra por línea). Para arrancar, en CapCut ≈ **59** y ≈ **70** (estimado: la medida salió de otra fuente y la fórmula es para 9:16, así que validalo en el primer build).
  - Cada línea va en un clip de texto aparte que entra 0,12–0,4 s después del anterior, con animación de entrada "Fundido" de 0,1 s.
  - Duración total de la placa: 1,1–1,3 s.
- **Subtítulo B:**
  - Fuente sans medium en minúsculas, blanco, sombra negra al 40 % con desenfoque bajo.
  - Tamaño CapCut ≈ **10–11** (estimado). Posición y = 85 %.
  - Animación "Máquina de escribir por palabra" (o una palabra por clip, cada 0,12 s).
- **Manuscrita:** Caveat Brush o similar, en blanco o violeta `#5F42BF`.

---

## 3. Zooms y movimientos de cámara

**Qué hace**
- Usa pocos zooms y bien elegidos. **No** hay zoom en cada idea.
- Medí el ancho de la cara cuadro a cuadro en todos los planos a cámara:
  - **Apertura (0,0–0,3 s):** zoom out animado, de **≈133 % a 100 %** (cara de 237 a 177 px de 640). Arranca encima de la cara y se abre rápido.
  - **Plano base del hook:** plano medio corto, cara ≈178 px (28 % del ancho). Es la escala 100 % de esta ficha. Se mantiene igual en todos los cortes del hook: 0,5–4,8 · 10–14,3 · 16,7–18,4 · 20,8–21,8 s.
  - **Tramo de explicación (24–32,2 s):** cambia por corte a un **plano más abierto, ≈90 %** (cara de 160 px). O sea, el hook va ≈11 % más cerrado que la explicación.
  - **Dentro de 27,5–32 s** la cara baja de 163 a 155 px (−5 %). Puede ser un zoom out muy lento o que él se echa atrás (estimado).
  - **Pantalla (57,33 s):** reencuadre por corte sobre la línea de tiempo de CapCut, ≈**200 %** (estimado), para que se lea.
- Fuera de eso, dentro de cada plano la escala no cambia (±3 %).

**Valores**

| Momento | Técnica | Escala |
| --- | --- | --- |
| 0,0–0,3 s | Keyframe, zoom out con ease-out | 133 % → 100 % |
| Hook | Plano fijo | 100 % (medio corto) |
| 24 s | Corte a plano abierto | 100 % → 90 % |
| 57,33 s | Reencuadre por corte (pantalla) | ≈200 % (estimado) |

**Cómo replicarlo en CapCut**
- **Primer clip:** keyframe en 0 s con escala 133 % y otro en 0,3 s con 100 %, curva ease-out.
- **Hook:** todo el hook en un plano medio corto. Si tu toma es abierta, escalá a ≈111 % y mantenelo.
- **Cuando termina el hook y empieza la explicación:** volvé al plano abierto (100 % de tu toma).
- **Grabación de pantalla:** cortá y escalá al 180–200 % sobre la zona que se está explicando.

---

## 4. B-roll y material de apoyo

**Qué hace**
- En el hook hay un apoyo visual casi permanente: o algo flota al lado de la cara, o la cámara se tapa con una gráfica.
- Cada apoyo ilustra literalmente lo que se dice (herramienta, cantidad de principios, prueba social, ejemplo de resultado).

**Valores (inventario 0–32 s)**

| Tiempo | Duración | Qué se ve | Integración | Tipo |
| --- | --- | --- | --- | --- |
| 0,08–2,25 s | 2,2 s | Logo de CapCut (ícono blanco redondeado con sombra) | Flota a la derecha de la cara (x 82 %, y 47 %, ≈19 % del ancho) | Literal |
| 2,25–4,85 s | 2,6 s | Logo de After Effects | Flota a la izquierda (x 20 %, y 49 %, ≈19 % del ancho) | Literal |
| 6,08–9,92 s | 3,8 s | Línea de tiempo "7 principles" (puntos violetas `#714BDE`, 1→7, con el ícono de Ae en el 7, más "to make CapCut look like After Effects") | Pantalla completa, fondo `#131313` | Gráfica animada |
| 10,6–14,35 s | 3,7 s | Etiqueta del canal (avatar + nombre + suscriptores) | Abajo al centro, y ≈ 94 % | Prueba social |
| 10,97–14,35 s | 3,4 s | 4 miniaturas de videos del canal | 2 por lado, a la altura de la cara (≈23 % del ancho cada una) | Prueba social |
| 14,58–16,67 s | 2,1 s | Placa "I'll show you / 10 Tricks / with the exact settings" con un ícono 3D de sliders | Pantalla completa: fondo violeta `#7A54DC` con formas 3D desenfocadas y tarjeta clara `#ECE6F9` | Gráfica |
| 18,42–20,75 s | 2,3 s | Texto cinético (ver sección 2) | Pantalla completa | Texto |
| 21,8–24,0 s | 2,2 s | 3 clips verticales de arquitectura (1,0 / 0,35 / 0,8 s) | Tarjeta vertical 9:16 centrada (≈25 % del ancho, 81 % del alto) sobre gris claro `#E0E0E0` | Ejemplo del resultado |
| 32,25–60 s | 27,7 s | Grabación de pantalla de CapCut | Pantalla completa, con la cámara en un recuadro abajo a la derecha (≈17 % del ancho, esquinas redondeadas) | Tutorial |

- **Reparto del hook y la explicación (0–32,2 s):** 67 % a cámara (con elementos flotantes el 60 % de ese tiempo), 26 % gráfica a pantalla completa y 7 % B-roll.
- **Duración de cada apoyo:** 1,1–3,8 s, con un promedio ≈2,5 s.
- **Animaciones de entrada:**
  - **Logos:** entran escalando desde ≈30 % con un giro de ≈−20° y llegan al 100 % en 0,25 s.
  - **Salida del logo:** se desatura o se desliza con desenfoque de movimiento.
  - **Miniaturas:** entran escalonadas, las 4 en 0,4 s.

**Cómo replicarlo en CapCut**
- **Logos:** PNG con fondo transparente, ≈19 % del ancho, al costado de la cara. Animación de entrada "Zoom + giro" de 0,25 s. Salida "Deslizar con desenfoque" de 0,15 s.
- **Prueba social:** capturas de miniaturas en recuadros con sombra, 2 por lado, entrada "Pop" escalonada cada 0,1 s.
- **Gráficas a pantalla completa:**
  - fondo oscuro `#131313` o violeta `#7A54DC`;
  - violeta `#714BDE` como color de acento;
  - títulos con letra manuscrita.
- **B-roll de ejemplo:** clips verticales dentro de una tarjeta centrada sobre gris claro, de 0,3 a 1 s cada uno, entrando con el destello rojo.
- **Tutorial:** recuadro con la cámara abajo a la derecha, ≈17 % del ancho, esquinas redondeadas.

---

## 5. Color grading y tratamiento visual

**Qué hace**
- Estética de estudio oscuro:
  - pared gris azulada con paneles acústicos que tienen un borde azul;
  - piel cálida y natural;
  - negros profundos.
- Separación fuerte entre la persona y el fondo, por luz y por foco.

**Valores (63 cuadros a cámara)**
- **Saturación media:** 0,31 (moderada). Piel `#A37771` (saturación 0,30, cálida). Pared `#4F5564` (tono azul, saturación 0,21).
- **Contraste:** luminancia p5 = 1,3 % (negros aplastados, **no** levantados) y p95 = 59 % (altas sin quemar). Contraste alto en sombras.
- **Temperatura:** relación R/B = 0,93, fría en general por el fondo, mientras la piel queda cálida.
- **Viñeta:** las esquinas tienen el 52 % del brillo del centro (fuerte, entre la luz y la viñeta).
- **Foco:** el fondo está 3,7 veces menos nítido que la cara (poca profundidad de campo).
- **Acento:** aro de luz verde en el micrófono.

**Cómo replicarlo en CapCut (estimado, ajustar a ojo)**
- Contraste **+10 a +15**. Sombras **−10**. Negros **−10**, sin levantar.
- Saturación **−5**. Temperatura **−5 a −10** (fría).
- Si la piel se enfría, máscara o "Ajuste de piel" para devolverle calidez.
- Viñeta **25–35**.
- Si tu fondo está nítido, desenfocalo un poco con una máscara invertida sobre la persona.
- En las placas gráficas no apliques el grading: mantené los colores planos de la sección 2.

---

## 6. Audio, música y efectos de sonido (SFX)

**Qué hace**
- En el hook y la explicación hay una cama de música baja todo el tiempo.
- En el tutorial de pantalla **no hay música**: solo voz.
- Casi cada evento visual del hook lleva su SFX. En el tramo de pantalla no hay SFX.

**Valores**
- **Sonoridad integrada:** hook y explicación (0–32,2 s) −21,4 LUFS; pantalla (32,2–60 s) −26,7 LUFS, o sea 5 LU más bajo, sin música.
- **Piso en las micro pausas:**
  - Hook: ≈ −50 dBFS (hay música).
  - Pantalla: −75 a −84 dBFS (silencio real).
  - Música ≈ **20–25 dB por debajo de la voz** (estimado).
- **Género y BPM:** no se pueden confirmar porque el audio no se escucha. Las subidas de graves son irregulares y no dan un BPM fiable.
- **SFX:** transitorios medidos sobre cada evento visual (dB por encima de la mediana).

| Tiempo | Evento visual | Firma del audio | SFX probable (estimado) |
| --- | --- | --- | --- |
| 4,95 s | Destello rojo | Agudos +16 dB, graves +23 dB | Whoosh con golpe |
| 9,92 s | Corte de la gráfica a cámara | Agudos +21 dB | Swish |
| 10,97 s | Entran las miniaturas | Agudos +26 dB | Pop o clic |
| 14,35 s | Barrido de luz blanca | Graves +15 dB, agudos +10 dB | Whoosh |
| 16,67 s | Corte de la placa a cámara | Agudos +24 dB | Swish |
| 18,42 / 18,8 s | "THAT STOP" / "THE SCROLL" | Agudos +15 / +30 dB | Pop o clic por bloque |
| 19,5 / 19,62 / 19,75 s | "EVERY" / "SINGLE" / "TIME" | Agudos +12 a +18 dB | Clic o pop por palabra |
| 21,8 s | Destello rojo hacia el B-roll | Agudos +24 dB, graves +11 dB | Whoosh |
| 2,25 · 24,0 · 32,25 · 57,33 s | Cambio de logo, cortes de la explicación, pantalla | Sin pico claro | Sin SFX |

**Cómo replicarlo en CapCut**
- **Voz:** normalizá a ≈ −14 LUFS para YouTube. Activá la reducción de ruido.
- **Música:**
  - Tech o electrónica instrumental suave (estimado), a −20/−25 dB debajo de la voz (en CapCut, volumen ≈ 10–15 %).
  - **Cortala** cuando empieza la grabación de pantalla.
- **SFX:**
  - whoosh en cada destello o barrido;
  - swish en cada corte de una gráfica a cámara;
  - pop o clic en cada bloque de texto cinético y en la entrada de las miniaturas.
  - Volumen: que se escuchen pero no tapen la voz (≈ −6 a −10 dB debajo de la voz).
- **Tutorial de pantalla:** sin SFX.

---

## Checklist rápido para el editor

1. Proyecto 16:9 en 1920×1080. Hook hasta ≈22 s, explicación a cámara hasta ≈32 s, después el tutorial de pantalla.
2. Primer clip: zoom out animado de 133 % a 100 % en 0,3 s.
3. En el hook, cortá todas las pausas de más de 0,15 s y cambiá algo en pantalla cada 1–1,5 s.
4. Logos de las herramientas flotando al costado de la cara (≈19 % del ancho), con entrada de zoom + giro de 0,25 s.
5. Una gráfica oscura (`#131313`) con acentos violetas (`#714BDE`) y letra manuscrita para el "qué vas a aprender".
6. Prueba social: 4 miniaturas, 2 por lado, entrada pop escalonada, más la etiqueta del canal abajo al centro.
7. La frase-promesa va con texto cinético a pantalla completa: Akkordeon en mayúsculas, blanco sobre rojo `#D62C21` o rojo `#E22F20` sobre blanco, 1–2 palabras por línea, fade de 0,1 s, ≈1,2 s por placa.
8. Subtítulos solo en las frases clave: sans medium en minúsculas, blanco con sombra suave, y = 85 %, palabra por palabra.
9. B-roll de ejemplo en una tarjeta vertical centrada sobre gris claro, entrando con un destello rojo.
10. Plano medio corto en el hook y plano más abierto (≈−10 %) en la explicación. Sin zoom en cada frase.
11. Color: contraste alto, negros aplastados, fondo frío, piel cálida, viñeta 25–35.
12. Música baja (−20/−25 dB) solo hasta que empieza la pantalla. SFX en cada destello, corte de gráfica y bloque de texto. Nada de SFX en el tutorial.
