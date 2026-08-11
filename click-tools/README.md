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
> Desktop ni Accessibility APIs de macOS. El AppleScript en sí **todavía no fue verificado contra
> un CapCut real** — eso requiere correrlo en tu Mac. Instrucciones abajo.

### Cómo correr el spike (macOS, con CapCut abierto y un proyecto cargado)

```bash
cd click-tools/scripts/fase1-spike
./run-spike-macos.sh
```

La primera vez, macOS va a pedir permiso de Accessibility para la Terminal
(**System Settings → Privacy & Security → Accessibility**). Si no aparece el diálogo, agregalo
manualmente y volvé a correr el script.

El script:
1. Genera `test.png` (400x300, sin dependencias — decodifica un base64 embebido).
2. Detecta si CapCut está corriendo (`isCapCutRunning`).
3. Lo enfoca (`focusCapCut`).
4. Intenta la **Estrategia A: pegar desde el portapapeles** — copia la imagen al clipboard como
   imagen y envía `Cmd+V` a CapCut. Es la estrategia menos frágil porque no depende de conocer la
   estructura interna de menús/accesibilidad de CapCut, solo de que CapCut acepte pegar imágenes
   en el panel de medios.
5. Imprime logs con las etapas: `CAPCUT_DETECTED`, `IMPORT_ATTEMPTED`, y pide **confirmación
   visual manual** (todavía no hay forma automatizada de verificar que el import ocurrió).

### Qué necesito que me reportes

Después de correrlo, decime:
- ¿Detectó CapCut corriendo? (sí/no)
- ¿Lo enfocó/trajo al frente? (sí/no)
- ¿Al hacer Cmd+V apareció la imagen en el panel de medios o timeline de CapCut? (sí/no)
- Cualquier error que haya impreso el script.

**Si Strategy A (clipboard) funciona:** es la ruta ganadora — simple, estable, sin necesidad de
mapear la interfaz de CapCut. Paso siguiente: agregar una forma de confirmar el import
automáticamente (o aceptar que el usuario vea el resultado en CapCut) e integrar esto al bridge.

**Si Strategy A no funciona:** corré el diagnóstico de accesibilidad para mapear los nombres reales
de menús/botones de CapCut, y con eso construimos la Estrategia C (automatización vía menú
File → Import):

```bash
osascript ../../bridge/src/platform/macos/ui-inspector.applescript > capcut-ui-dump.txt
```

Mandame ese archivo y con los nombres reales de elementos escribo la Estrategia C correctamente,
en vez de adivinar nombres de menú que probablemente no coincidan con los reales de CapCut.

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
- No se modifica el proyecto/drafts de CapCut por ingeniería inversa de sus archivos internos —
  eso queda explícitamente fuera de la V1.
- El adapter de Windows (`bridge/src/platform/windows/`) todavía no está implementado — se
  construye después de validar el approach en macOS.
