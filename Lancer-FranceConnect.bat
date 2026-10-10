@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\start-local.ps1"
if errorlevel 1 (
  echo.
  echo Le lancement a echoue. Corrigez le probleme indique ci-dessus puis relancez ce fichier.
  pause
)
