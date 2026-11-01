@echo off
REM Lanza el sincronizador. La logica esta en el .ps1 de al lado.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0sync-to-workshop.ps1"
pause
