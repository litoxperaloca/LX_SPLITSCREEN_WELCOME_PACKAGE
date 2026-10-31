# Carpeta de publicacion en el Steam Workshop

Esto NO lo carga el juego como mod: es el material de la pagina del Workshop.

- `workshop.txt`  - titulo, descripcion (BBCode), tags y visibilidad de la pagina.
- `preview.png`   - la imagen de portada de la pagina (512x512).
- `sync-to-workshop.bat` - copia el mod a `%USERPROFILE%\Zomboid\Workshop\LX_SPLITSCREEN_WELCOME_PACKAGE\`,
  que es la carpeta donde el subidor del juego busca las cosas.

## Como publicar

1. Corre `sync-to-workshop.bat` (doble clic).
2. Abri Project Zomboid - menu principal - **Workshop**.
3. Elegi **LX_SPLITSCREEN_WELCOME_PACKAGE** y dale a crear/actualizar.
4. La primera vez Steam te da un ID: pegalo en `id=` de `workshop.txt`
   y volve a correr el .bat, asi las proximas subidas actualizan la misma pagina
   en vez de crear una nueva.
