# Carpeta de publicacion en el Steam Workshop

Esto NO lo carga el juego como mod: es el material de la pagina del Workshop.

- `workshop.txt` - titulo, descripcion (BBCode, EN/ES/RU), tags, visibilidad y el `id=`
  de la pagina ya publicada.
- `preview.png` - portada. **Exactamente 256x256 y menos de 1000 KB**, o el juego la rechaza.
- `sync-to-workshop.ps1` - hace el trabajo. El `.bat` solo lo lanza con doble clic.

## Como publicar

1. **Cerra Project Zomboid.** Con el juego abierto, Windows bloquea los `.jar` que ya
   cargo y la copia falla a medias. El script te avisa si lo detecta.
2. Doble clic en `sync-to-workshop.bat`.
3. Abri el juego - menu principal - **Workshop** - elegi **LX_SPLITSCREEN_WELCOME_PACKAGE** y publica/actualiza.

## Limites que impone Steam

Estos no los valida el juego: los rechaza Steam **despues** de crear el item, y el
error que vas a ver es `result=8` (`k_EResultInvalidParam`), que no dice cual fue.

| Campo | Limite |
|---|---|
| Descripcion | **8000 bytes** (el cirilico pesa 2 bytes por caracter) |
| Titulo | 128 caracteres |
| preview.png | 256x256, menos de 1000 KB |
| Tags | tienen que existir en la lista de PZ |

La descripcion de este repo se genera recortada para entrar con margen. El detalle
completo en los tres idiomas vive en el `README.md` de la raiz, enlazado desde la pagina.

## Sobre el `id=`

La primera publicacion hace que Steam cree el item y le asigne un id, que el juego
escribe en `%USERPROFILE%\Zomboid\Workshop\LX_SPLITSCREEN_WELCOME_PACKAGE\workshop.txt`.

El script lo **recupera solo**: si la carpeta de subida tiene id y el repo no, lo copia
al repo antes de pisar nada, y te lo avisa para que lo commitees. Si ese id se pierde,
la proxima subida crea un item NUEVO en vez de actualizar el que ya tenes.

## Si la subida falla

El juego valida el contenido **antes** de crear el item:

- **Falla sin asignarte id** -> el problema es tu contenido. El mensaje en pantalla
  te dice cual (preview, `mod.info`, extensiones, estructura).
- **Te asigna id y despues falla** -> el contenido estaba bien; lo rechazo Steam.
  Revisa la tabla de limites de arriba. Si es `result=15` en vez de `8`, es el acuerdo
  legal del Workshop: <https://steamcommunity.com/sharedfiles/workshoplegalagreement>

Ojo: el subidor muestra el error **solo en pantalla**, no lo escribe en ningun log
(hay un TODO en el codigo del juego al respecto). Si falla, leelo antes de cerrar.
