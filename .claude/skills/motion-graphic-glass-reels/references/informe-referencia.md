# Informe de referencia + guion adaptado

Es la plantilla del **Modo 1**. El informe tiene que poder dárselo a un editor (o a vos mismo en el
Modo 2) y que sepa **exactamente qué poner, dónde y cuándo**, sin mirar la referencia.

## Cómo llenarlo

- **Medido** (de `analisis.json`, tal cual): duración, resolución, fps, cambios de plano, paleta HEX,
  tramos de voz y golpes de sonido. No redondees a ojo lo que el script ya midió.
- **Observado** (mirando `hoja_XX.png` y `escena_XX_grilla.png`): estilo, elementos, textos en pantalla
  y coordenadas. Las coordenadas son % con origen arriba a la izquierda: leelas de la grilla.
- **Estimado** (keyframes, curvas, radios de glow): escribí "(estimado)". No lo presentes como medido.
- **Guion original**: leelo del texto en pantalla de las hojas. Si no hay texto ni transcripción,
  pedíselo al usuario. No lo inventes.
- **Escenas**: agrupá los planos medidos en escenas por beat narrativo (hook, problema…). Una escena
  puede tener varios planos.

## Reglas para adaptar el guion (sección M)

1. **Mensaje del usuario primero**: tema, público, dolor, promesa y CTA (palabra a comentar). Si no
   están claros y no salen de la conversación, preguntalos una sola vez, juntos.
2. **Respetá la estructura de la referencia**, no su contenido: los mismos beats, en el mismo orden,
   con la misma duración por beat y la misma cantidad de palabras por beat (±15 %). En español de
   reel entran ~2,6–3 palabras por segundo.
3. **Mismo tipo de hook** (pregunta, amenaza, contradicción, dato…) y misma mecánica de payoff.
4. **Traducí cada metáfora visual** al mensaje nuevo, manteniendo la mecánica: si en la referencia un
   cursor enciende 3 focos y el tercero falla, en la adaptación algo equivalente se activa 3 veces y la
   tercera sale mal. Decí explícitamente qué reemplaza a qué.
5. **Lenguaje del usuario**: voseo rioplatense si el usuario escribe así, frases cortas que se puedan
   decir en voz alta, la palabra clave del CTA en mayúsculas.

## Plantilla (usá estos títulos)

```markdown
# Informe · <nombre de la referencia> → <tema adaptado>

## A. ADN visual del video
Un párrafo: estilo (2D/3D/vidrio/flat/neón…), fondo, paleta, recurso gráfico principal, cómo
cuenta la historia (qué contrapone) y ritmo de edición.

## B. Ficha técnica
- Duración total: <s exactos> · Resolución: <WxH> (9:16) · FPS: <fps>
- Estilo: <etiqueta corta>
- Paleta: Fondo <HEX> · Texto <HEX> · Acentos <HEX> (<nombre>)
- Densidad: <baja/media/alta> (<n> elementos por escena)
- Ritmo: un cambio cada <x> s en promedio (<n> planos medidos)

## C. Guion original y estructura narrativa
| Tiempo | Beat | Texto (locución / en pantalla) |

## D. Storyboard técnico (original)
### Escena 1 (E1) · <beat>
- Tiempo: <mm:ss–mm:ss> (<s> / <frames> f) · Planos: <ids>
- Texto en pantalla: "<…>" (X <%>, Y <%>)
- Composición: <elemento> (X <%>, Y <%>, tamaño ≈ <% del ancho>) · …
- Comportamiento: <qué pasa> en <s / palabra>. …

## E. Sistema de coordenadas y zonas
Origen (0,0) arriba-izq · Textos Y <a–b %> · Zona central X <a–b %>, Y <a–b %> ·
Zona segura inferior Y <a–b %> · Márgenes laterales <%>.

## F. Tipografía y subtítulos
Familia (o equivalente libre) · Pesos · Tamaños (px a 1080 de ancho) · Color · Alineación ·
Palabras por bloque · Entrada (pop, blur, máquina de escribir…) · Palabras resaltadas y cómo.

## G. Motion graphics y keyframes (estimados)
Por cada animación clave: 0.00 s → propiedad/valor · 0.15 s → … · curva (ease / bezier).

## H. Gráficos, formas y elementos
Trazos (px), rellenos, radios, glow (capas y radios), sombras.

## I. Recursos e imágenes
Vector / 3D / foto / video de archivo · formato sugerido · estilo unificado.

## J. Color, luz y tratamiento
Fondo, contraste, fuentes de luz / glow, grano, viñeta.

## K. Audio y sound design
Voz (tipo, ritmo) · Música (sí/no, estilo, volumen) · SFX: <tiempo> <tipo> (de los golpes medidos).

## L. Montaje y transiciones
Tipo de corte, transiciones internas, qué marca cada cambio (palabra, golpe, beat).

## M. Guion adaptado
Para: <tema> · Público: <…> · Dolor: <…> · CTA: comentá <PALABRA>
| Beat | Tiempo | Original | Adaptado | Palabras (orig → adapt) |

## N. Storyboard adaptado · qué poner en cada escena
### Escena 1 (E1) · <beat> · <mm:ss–mm:ss>
- Locución: "<texto adaptado>"
- Texto en pantalla: "<texto>" — X <%>, Y <%> — <estilo> — resaltar "<palabra>" en <color>
- Elementos: <qué va> (reemplaza a <elemento original>) — X <%>, Y <%> — tamaño <…>
- Acción: <qué hace, en qué palabra o segundo>
- SFX: <tipo> en <s>
- Color de acento: <HEX>

## O. Timeline maestro (adaptado)
| Inicio | Fin | Escena | Elementos visibles | Animación / SFX | Locución |

## P. Inventario de assets
Vectores / íconos · componentes (glow, HUD, tarjetas…) · SFX con nombre de archivo sugerido ·
qué hay que pedirle al usuario (voz, logos, capturas).
```
