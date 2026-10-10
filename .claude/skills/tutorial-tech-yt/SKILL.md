---
name: tutorial-tech-yt
description: Edita videos horizontales de YouTube (16:9) en CapCut con el estilo "Tutorial Tech YT". El hook va muy cargado (logos flotando, gráficas oscuras con acento violeta, miniaturas como prueba social, texto cinético en Akkordeon a pantalla completa sobre rojo o blanco), sigue una explicación a cámara y termina en un tutorial de pantalla limpio. Usar cuando diga "/tutorial-tech-yt", "editá con el estilo tutorial", "editá el tutorial de YouTube", "estilo Tutorial Tech YT", "editá el proyecto <X> con el estilo tutorial", o "aprendé de mis correcciones en <proyecto>" para este estilo.
---

# Tutorial Tech YT (estilo de edición)

> **Estado: v0, sin probar.** Esta versión salió de la ficha de 1 referencia (minuto 0–1). Cuando 2–3 videos salgan sin correcciones grandes, sacá este aviso y completá el "Plan modelo".

Todo en español rioplatense. **Nunca abrir CapCut ni usar el control de la computadora.** **Nunca inventar campos de CapCut.**

## Rutas

| Qué | Dónde |
| --- | --- |
| Carpeta del estilo | `/Volumes/Expansion/CLAUDE/CapCut Automation/estilos/Tutorial Tech YT/` |
| Ficha (fuente de verdad de los valores) | `…/estilos/Tutorial Tech YT/tutorial_tech_yt.json` |
| Ficha para editor humano | `…/estilos/Tutorial Tech YT/ficha tecnica para editor.md` |
| Proceso base de edición (pasos 0–10) | `~/.claude/skills/minimalist-edition/SKILL.md` |
| Herramientas | `/Volumes/Expansion/CLAUDE/CapCut Automation/herramientas/` (`build_estilo_crema.py`, `preview_estilo_crema.py`, `iconos.py`, `plantillas_capcut/`) |
| Guía del sistema | `/Volumes/Expansion/CLAUDE/GUIA - Sistema de edicion con Claude.md` |
| Copia de respaldo de esta skill | `…/skill (copia de respaldo)/tutorial-tech-yt/` |
| Copia de la ficha dentro de la skill | `estilo/` al lado de este archivo (JSON, ficha, indicación y `_analizadas.md`) |

Si la carpeta del estilo no está en el disco, copiá `estilo/` a `…/estilos/Tutorial Tech YT/` antes de editar. Cuando se actualice la ficha, actualizá las dos copias.

**Prioridad entre fuentes:**
1. Tus correcciones en CapCut (`reglas_aprendidas` del JSON).
2. Tus decisiones escritas (`decisiones_usuario` del JSON).
3. La referencia.

Si el JSON y esta skill se contradicen, gana el JSON. Actualizá esta skill para que vuelvan a coincidir.

## Proceso

1. **Pedir todo junto, en un solo mensaje:** el nombre del proyecto de CapCut y la carpeta de recursos. Se necesitan:
   - toma a cámara;
   - grabación de pantalla;
   - logos de las herramientas en PNG;
   - capturas de miniaturas del canal;
   - B-roll de ejemplo;
   - música y SFX.

   Si falta algún recurso, saltá ese elemento y avisá. No lo reemplaces con nada inventado.
2. **Transcribir** con faster-whisper `small` (es). La transcripción sirve para:
   - ubicar las 4 partes del video (ver "Estructura");
   - encontrar la frase-promesa para el texto cinético;
   - encontrar las frases clave para los subtítulos;
   - saber dónde va cada logo o gráfica.
3. **Revisar las plantillas.** Antes de armar, fijate en `plantillas_capcut/` que estén:
   - la fuente **Akkordeon**;
   - la transición de destello rojo (light leak);
   - el barrido de luz blanca;
   - las animaciones de entrada (fundido, zoom + giro, pop, máquina de escribir por palabra).

   Lo que falte, pedíselo al usuario: un proyecto suyo de CapCut que lo use, guardado en `plantillas_capcut/`. **No lo construyas a mano.**
4. **Editar** siguiendo los pasos 0–10 de `minimalist-edition/SKILL.md`, con los valores de `tutorial_tech_yt.json`:
   - En el plan poné `canvas` en 1920×1080 (16:9).
   - Si el constructor no soporta algo de este estilo, ampliá la herramienta sin romper los planes que ya existen. Probala reconstruyendo un plan viejo.
5. **Cerrar** siempre con:
   - `✅ Ya podés abrir CapCut.`
   - `⏱️ Tardé X minutos (hh:mm–hh:mm).`

## Estructura del video

| Parte | Duración de referencia | Qué pasa |
| --- | --- | --- |
| Hook | ≈0–22 s | Promesa y herramientas, "qué vas a aprender", prueba social, texto cinético, cierre con una frase subtitulada |
| Ejemplo | ≈2 s | B-roll del resultado en una tarjeta vertical |
| Explicación a cámara | ≈8 s | Plano más abierto, jump cuts |
| Tutorial de pantalla | Resto del video | Grabación de pantalla con la cámara en un recuadro, casi sin edición |

## Reglas fijas del estilo

### 1. Ritmo y cortes

- **Hook:**
  - Cortá toda pausa de más de 0,15 s.
  - Un cambio en pantalla cada **1–1,5 s** (la referencia da 1,26 s).
  - Ningún plano limpio a cámara más de 2 s.
- **Explicación a cámara:** jump cuts en las pausas, mismo encuadre, uno cada 1,5–3,5 s.
- **Tutorial de pantalla:** recortá solo las pausas largas. La edición se limita a reencuadres para que se lea.
- **Transiciones:**
  - destello rojo de 0,35 s en un jump cut del hook y en la entrada al B-roll;
  - barrido de luz blanca de 0,25 s al entrar a una placa gráfica;
  - en todo lo demás, corte seco.

### 2. Textos

- **Texto cinético (solo en la frase-promesa del hook):**
  - **Akkordeon en MAYÚSCULAS**, centrado, sin borde ni sombra.
  - Colores: blanco `#F3E9E8` sobre rojo `#D62C21`, o rojo `#E22F20` sobre blanco `#F7F7F7`. El fondo lleva un degradado radial suave.
  - 1 o 2 palabras por línea, interlineado ≈1,08.
  - Alto de la mayúscula: **216 px** con 2 palabras por línea y **258 px** con 1 palabra. Ajustá el tamaño de CapCut hasta llegar a esa altura (para arrancar, ≈59 y ≈70).
  - Cada línea va en un clip aparte, con entrada de fundido de 0,1 s. Entra una nueva cada 0,12–0,4 s.
  - Cada placa dura 1,1–1,3 s.
- **Subtítulos (solo en frases clave, nunca continuos):**
  - Sans medium en minúsculas (tipo SF Pro Display Medium o Inter Medium).
  - Blanco `#F3F2F2` con sombra suave.
  - Posición y = 85 %.
  - Aparecen palabra por palabra, a 0,12 s por palabra.
- **Letra manuscrita en las gráficas:** tipo Caveat Brush. Blanco sobre `#131313`, o violeta `#5F42BF` sobre `#ECE6F9`.
- **No** resaltes palabras sueltas: el énfasis es el bloque entero con fondo de color. **Nada de amarillo.**

### 3. Zooms

| Momento | Qué hacer |
| --- | --- |
| Primer clip | Keyframes de **133 % a 100 %** en 0,3 s, con ease-out |
| Hook | Plano medio corto fijo (≈111 % de la toma abierta) |
| Explicación a cámara | Corte al plano abierto (100 % de la toma) |
| Tutorial de pantalla | Reencuadre por corte al **180–200 %** sobre la zona que se explica |

- **Nada de zoom por frase.**

### 4. Material de apoyo (cada elemento dura 1,1–3,8 s)

- **Logos de herramientas:**
  - Flotan al costado de la cara: ≈19 % del ancho, en x 82 % o 20 % e y ≈48 %.
  - Duran 2–2,6 s.
  - Entrada: zoom desde 30 % con giro de −20°, en 0,25 s.
  - Salida: se deslizan con desenfoque de movimiento en 0,15 s.
- **Gráfica "qué vas a aprender":**
  - Fondo `#131313`, acento `#714BDE` y letra manuscrita.
  - Se arma por pasos, ≈0,35 s cada uno.
  - Dura ≈3,8 s.
- **Prueba social:**
  - 4 miniaturas, 2 por lado, ≈23 % del ancho cada una.
  - Entran con pop escalonado, una cada 0,1 s.
  - Duran ≈3,4 s.
  - Se suma la etiqueta del canal, abajo al centro (y 94 %).
- **Placa de promesa** ("te voy a mostrar…"):
  - Fondo violeta `#7A54DC` con una tarjeta `#ECE6F9`.
  - Dura ≈2,1 s.
  - Entra con el barrido de luz blanca.
- **B-roll de ejemplo:**
  - Clips verticales 9:16 dentro de una tarjeta centrada (25 % del ancho, 81 % del alto), sobre gris `#E0E0E0`.
  - 0,3–1 s por clip.
  - Entra con el destello rojo.
- **Tutorial de pantalla:** la cámara va en un recuadro abajo a la derecha, ≈17 % del ancho, con esquinas redondeadas.
- **Reparto del hook:** 67 % a cámara (con elementos flotantes), 26 % gráficas a pantalla completa, 7 % B-roll.

### 5. Color (solo en los planos a cámara, nunca en las placas)

| Ajuste | Valor |
| --- | --- |
| Contraste | +10 a +15 |
| Sombras | −10 |
| Negros | −10 (no levantarlos) |
| Saturación | −5 |
| Temperatura | −5 a −10 |
| Viñeta | 25–35 |

- La piel tiene que seguir cálida.
- Si el fondo está nítido, desenfocalo con una máscara invertida sobre la persona.

### 6. Audio

- **Voz:** ≈ −14 LUFS, con reducción de ruido.
- **Música:**
  - Tech o electrónica instrumental suave, a −20/−25 dB debajo de la voz (volumen ≈10–15 %).
  - **Va solo hasta que empieza el tutorial de pantalla.**
- **SFX:**

| Momento | Efecto |
| --- | --- |
| Destello rojo o barrido de luz | Whoosh |
| Corte de una gráfica a cámara | Swish |
| Cada bloque de texto cinético | Pop o clic |
| Entrada de las miniaturas | Pop o clic |

- Volumen de los SFX: −6/−10 dB debajo de la voz.
- **En el tutorial de pantalla no va ningún SFX.**

## Plan modelo

Pendiente. Se completa con el plan del primer video aprobado (proyecto `YOUTUBE EZE`).

## Aprender de correcciones

Cuando diga "aprendé de mis correcciones en <proyecto>", seguí la Fase 3 de `~/.claude/skills/nuevo-estilo/SKILL.md`:
- Pasá cada corrección general a `reglas_aprendidas` del JSON y a esta skill.
- Lo que sea de un solo video, anotalo como excepción.
- Si una corrección contradice una regla anterior, preguntá cuál queda.
- Guardá la copia actualizada en `…/skill (copia de respaldo)/tutorial-tech-yt/`.

## Ahorro de uso

- Una sesión nueva por video, con `/Volumes/Expansion` como carpeta de trabajo.
- Usá hojas de cuadros chicas.
- No releas código que funciona.
