# Errores comunes y su arreglo

Todos aparecieron en producción. Revisá esta lista en cada pasada de stills.

1. **Caption con cada palabra en una línea.** `phraseGroup` mete las frases en divs `absolute`;
   si el contenedor solo tiene `left`, mide 0 de ancho. Dale un `width` explícito o `left` + `right`.

2. **Palabra de impacto que toca los bordes.** Inter Display Black ocupa ~0.68 em por letra en
   mayúsculas. Con 10 letras, no pases de 150 px. Medilo en un still.

3. **Contador que tiembla o se pisa con la unidad.** Usá `font-variant-numeric: tabular-nums`
   y separá "hs" con un `margin-left`, no con un espacio.

4. **El vidrio deja de desenfocar el fondo durante las transiciones.** `opacity < 1` o `filter`
   en un ancestro corta el `backdrop-filter` (crea un backdrop root). Es aceptable en los 8 frames
   de transición, pero dejá `filter: none` cuando el blur es 0 y no uses `will-change`.

5. **Frame 0 vacío.** Es la portada por defecto y el primer impacto del scroll. Hacé que el
   personaje y la primera palabra ya estén visibles: nacen unos frames antes de 0.

6. **El cursor tapa el texto del botón.** Apuntá la punta al tercio derecho del botón.

7. **La voz real dura más que el guion estimado.** Pasó: el guion era de 22 s y la voz duró 26,2.
   Ajustá el video a la voz y avisale al usuario.

8. **Línea descentrada mientras entran las palabras.** Las palabras ocultas ya ocupan su lugar,
   y eso es lo esperado. Si molesta en un título, mostrá las primeras palabras desde el frame 0.

9. **Sin red para fuentes ni transcriptores.** Google Fonts, jsDelivr y PyPI pueden estar
   bloqueados. Usá las fuentes del sistema y `tiempos_vo.py` en lugar de Whisper; no reintentes
   descargas bloqueadas.

10. **Volumen.** El build normaliza a -14 LUFS. Si la voz queda tapada, bajá `sfx_gain` en
    `sfx_events.json`, no la voz.

11. **Elementos de una escena que se ven en otra.** Cada bloque de `renderFrame` va con su rango
    de frames (`if (f >= a - 4 && f < b + 4)`) y cada escena se oculta fuera de su ventana.
