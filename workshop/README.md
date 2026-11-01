# Carpeta de publicacion en el Steam Workshop

Esto NO lo carga el juego como mod: es el material de la pagina del Workshop.

- `workshop.txt` - titulo, descripcion (BBCode, EN/ES/RU), tags y visibilidad.
  El campo `id=` identifica la pagina ya publicada.
- `preview.png` - portada de la pagina. **Tiene que ser exactamente 256x256 y pesar
  menos de 1000 KB**, o el subidor del juego la rechaza.
- `sync-to-workshop.ps1` - hace el trabajo. `sync-to-workshop.bat` solo lo lanza
  con doble clic.

## Como publicar

1. Doble clic en `sync-to-workshop.bat`.
2. Project Zomboid - menu principal - **Workshop**.
3. Elegi **LX_SPLITSCREEN_WELCOME_PACKAGE** y dale a crear/actualizar.

## Sobre el `id=`

La primera publicacion hace que Steam cree el item y le asigne un id, que el juego
escribe en `%USERPROFILE%\Zomboid\Workshop\LX_SPLITSCREEN_WELCOME_PACKAGE\workshop.txt`.

El script lo **recupera solo**: en la proxima corrida se da cuenta de que la carpeta
de subida tiene un id y el repo no, y lo copia al repo antes de pisar nada. Te lo avisa
por pantalla para que lo commitees.

Eso importa porque si el `id=` se pierde, la siguiente subida crea un item NUEVO en
vez de actualizar el que ya tenes publicado.

## Si la subida falla

El juego valida el contenido **antes** de crear el item. Entonces:

- **Error antes de que te asigne un id** -> el problema es tu contenido: revisa el
  mensaje en pantalla (preview que no mide 256x256, falta `mod.info`, extensiones
  no permitidas, etc.).
- **Te asigna un id pero la subida falla** -> el contenido estaba bien y el problema
  es del lado de Steam. La causa mas comun es no haber aceptado el acuerdo legal del
  Workshop: entra a la pagina del item y aceptalo, o anda a
  <https://steamcommunity.com/sharedfiles/workshoplegalagreement>. Despues volve a
  subir; como el `id=` ya esta guardado, actualiza el item existente.

Ojo: el subidor muestra el error solo en pantalla, no lo escribe en ningun log
(hay un TODO en el codigo del juego al respecto). Si falla, **leelo antes de cerrar**.
