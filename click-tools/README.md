# Click Tools — Send to CapCut

Elimina el proceso manual de "buscar imagen → guardar → abrir CapCut → importar" a un clic derecho: **🎬 Enviar a CapCut**.

## Estado actual: FASE 1 (spike técnico) — en validación

Antes de construir la extensión de Chrome o el bridge completo, hay que demostrar el paso más
difícil y menos controlable del proyecto: **lograr que una imagen local llegue al proyecto
abierto de CapCut Desktop**, de forma automatizada.

Ese spike vive en [`scripts/fase1-spike/`](./scripts/fase1-spike/) y usa el adapter de macOS en
[`bridge/src/platform/macos/`](./bridge/src/platform/macos/).

> **Nota de entorno:** este spike se escribió y se probó estructuralmente (el generador de
> `test.png`, decodificación del PNG) desde un sandbox Linux sin GUI, que no puede ejecutar CapCut
> Desktop ni Accessibility APIs de macOS. Todo lo que involucra CapCut real fue verificado
> iterando en vivo con el usuario en su Mac.

### Cómo correr el spike (macOS, con CapCut abierto y un proyecto cargado)

```bash
cd click-tools/scripts/fase1-spike
./run-spike-macos.sh
```

La primera vez, macOS va a pedir permiso de Accessibility para la Terminal
(**System Settings → Privacy & Security → Accessibility**). Si no aparece el diálogo, agregalo
manualmente y volvé a correr el script.

### Qué se probó y qué se descartó

1. **Estrategia A (pegar desde el portapapeles / Cmd+V):** descartada. Confirmado en vivo que
   CapCut no acepta pegar una imagen copiada directo en su panel de medios — Cmd+V no hizo nada.
2. **Estrategia C, intento 1 (clic ciego en el menú Archivo → Importar + navegar el diálogo con
   Cmd+Shift+G):** parcialmente funcionaba, pero **Archivo → Importar (o su atajo Cmd+I) no abre
   el selector de archivos del sistema directamente** — abre la propia pantalla de CapCut
   ("Archivos multimedia"), que lista lo ya importado en el proyecto. Ahí adentro hay un botón
   "Importar" que sí abre el selector nativo del sistema.
3. **Hallazgo clave:** ese botón interno (y en general todo el contenido de las ventanas de
   CapCut) **no está expuesto a la Accessibility API de macOS** — un escaneo con System Events no
   encontró ningún botón. CapCut dibuja su interfaz con un toolkit propio que no implementa
   `NSAccessibility` para sus widgets internos. Por eso no podemos hacerle clic a ese botón por
   nombre, y **decidimos no adivinar coordenadas de píxeles a ciegas** dentro del proyecto real del
   usuario — el riesgo de tocar otra cosa por error no vale la pena para un atajo no verificado.
4. **El panel nativo que abre ese botón sí es 100% accesible** (es un `NSOpenPanel` estándar del
   sistema, no dibujado por CapCut) — pero automatizar `Cmd+Shift+G` ("Ir a la carpeta") ahí adentro
   (incluso poniéndole el valor directo al campo de texto vía Accessibility, sin depender de que el
   foco de teclado esté bien puesto) **falló repetidamente en pruebas reales**: el panel seguía
   abriendo en su carpeta por defecto en vez de la del archivo. Después de varios intentos sin
   identificar la causa exacta, se abandonó ese camino en vez de seguir agregando parches cada vez
   más fràgiles.

### Diseño resultante (implementado)

Se abandonó automatizar la ventana de importar de CapCut. En cambio: la automatización deja el
archivo descargado **ya seleccionado en el Finder**, y el usuario lo arrastra a CapCut con la mano
— una sola acción, estándar de macOS, que no depende de que CapCut exponga nada a Accessibility
porque es el usuario quien arrastra, no un script fingiendo hacerlo. Esto además cubre gratis el
caso de soltarlo directo en la línea de tiempo, si el usuario quiere.

1. Detecta CapCut, lo enfoca.
2. Abre el Finder con la imagen ya seleccionada (sin que el usuario tenga que buscarla).
3. Notificación: "Arrastrá la imagen hacia CapCut".
4. El usuario hace un solo arrastre, a donde quiera (panel de medios o línea de tiempo).

Es más manual que el diseño anterior (que apuntaba a cero clics), pero es **determinístico y no
depende de automatización frágil que no se pudo hacer confiable** — prioridad de estabilidad por
sobre intentar automatizar el 100% con hacks cada vez menos confiables.

## Arquitectura (destino final)

```
click-tools/
  extension/          # Chrome Extension (Manifest V3) — FASE 3
  bridge/              # Click Bridge — app local que conecta Chrome con CapCut
    src/
      server/          # Native Messaging host / servidor local — FASE 2
      downloader/       # Descarga + normalización de imágenes — FASE 2
      capcut/           # Orquestación: usa CapCutController del adapter activo
      platform/
        macos/          # CapCutController implementado con AppleScript (este spike)
        windows/         # CapCutController implementado con UI Automation (pendiente)
  shared/
    types/              # Contratos TypeScript compartidos (CapCutController, etc.)
  scripts/
    fase1-spike/         # Spike técnico standalone, sin dependencias del bridge
```

Regla de oro: **la lógica de Chrome nunca toca automatización de CapCut, y la automatización de
CapCut nunca sabe nada de Chrome.** Todo pasa por la interfaz `CapCutController`
(`shared/types/capcut-controller.d.ts`), que cada plataforma implementa a su manera.

## Por qué este orden (FASE 1 antes que nada)

Construir la extensión de Chrome y el bridge completo es trabajo relativamente predecible.
Lo que **no** sabemos todavía es si CapCut acepta pegado por clipboard, si su árbol de
accesibilidad es automatizable, o si hace falta caer al fallback manual (dejar el archivo en
`ClickTools/Inbox` y abrir el selector ahí). Validar esto primero evita construir todo el resto
sobre un supuesto que podría no cumplirse.

## Roadmap

- [x] **FASE 1** — Spike: `test.png` → CapCut (macOS). *En validación por el usuario.*
- [ ] **FASE 2** — Click Bridge: URL de imagen → descarga → archivo → CapCut.
- [ ] **FASE 3** — Chrome Extension: clic derecho → Click Bridge → CapCut.
- [ ] **FASE 4** — Feedback de UI: Loading / Success / Error.
- [ ] **FASE 5** — Empaquetado e instrucciones de instalación.

## Limitaciones conocidas (documentadas a medida que aparecen)

- CapCut Desktop no tiene una API pública ni SDK oficial. Todo lo que hacemos acá es
  automatización de UI/OS (clipboard, Accessibility), no integración oficial.
- CapCut no acepta pegar imágenes desde el portapapeles (Cmd+V) en su panel de medios.
- El contenido interno de las ventanas de CapCut (botones, listas, timeline) no está expuesto a
  la Accessibility API de macOS — solo su menú nativo de arriba (Archivo, Editar, etc.) lo está.
  Esto significa que **no se puede automatizar el 100% del flujo sin al menos un clic manual**
  en la versión actual de CapCut, salvo que se use automatización por coordenadas de píxeles
  (deliberadamente evitada por ser frágil y riesgosa sobre el proyecto real del usuario).
- Ni arrastrar a la línea de tiempo ni automatizar el diálogo de importar de CapCut resultaron
  viables de forma estable — la V1 deja el archivo ya seleccionado en Finder y el usuario hace un
  solo arrastre manual hacia CapCut (a donde quiera: panel de medios o línea de tiempo).
- No se modifica el proyecto/drafts de CapCut por ingeniería inversa de sus archivos internos —
  eso queda explícitamente fuera de la V1.
- El adapter de Windows (`bridge/src/platform/windows/`) todavía no está implementado — se
  construye después de validar el approach en macOS.
