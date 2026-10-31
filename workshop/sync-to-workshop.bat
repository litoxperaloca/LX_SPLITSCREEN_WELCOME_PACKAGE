@echo off
REM ---------------------------------------------------------------
REM  LX_SPLITSCREEN_WELCOME_PACKAGE - sincroniza este repo con la carpeta que lee
REM  el subidor de Workshop de Project Zomboid.
REM  Corre esto cada vez que cambies el mod, ANTES de subir.
REM ---------------------------------------------------------------
setlocal
set MODID=LX_SPLITSCREEN_WELCOME_PACKAGE
set SRC=%~dp0..
set DST=%USERPROFILE%\Zomboid\Workshop\%MODID%

echo.
echo  Sincronizando %MODID%
echo    desde : %SRC%
echo    hacia : %DST%
echo.

if not exist "%DST%\Contents\mods\%MODID%" mkdir "%DST%\Contents\mods\%MODID%"
robocopy "%SRC%\42" "%DST%\Contents\mods\%MODID%\42" /MIR /NFL /NDL /NJH /NJS /NP
robocopy "%SRC%\common" "%DST%\Contents\mods\%MODID%\common" /MIR /NFL /NDL /NJH /NJS /NP
copy /Y "%~dp0workshop.txt" "%DST%\workshop.txt" >nul
copy /Y "%~dp0preview.png" "%DST%\preview.png" >nul

echo.
echo  Listo.
echo  Ahora: Project Zomboid - menu principal - Workshop - Create/Update
echo  y elegí %MODID%.
echo.
pause
