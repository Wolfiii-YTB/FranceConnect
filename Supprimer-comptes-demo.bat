@echo off
setlocal
cd /d "%~dp0"
echo FranceConnect ENT - suppression des comptes de demonstration
echo Seuls les comptes fictifs connus sont supprimes. L'ADMIN_EMAIL configure (s'il n'est pas l'adresse demo) et les autres comptes sont proteges.
npm run db:cleanup-demo -- --apply
if errorlevel 1 (
  echo.
  echo Echec. Lancez d'abord Lancer-FranceConnect.bat pour demarrer PostgreSQL.
)
echo.
pause
