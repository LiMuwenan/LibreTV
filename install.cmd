@echo off
setlocal
cd /d "%~dp0"

where node >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Node.js not found. Please install Node.js 20 or newer first: https://nodejs.org/
  pause
  exit /b 1
)
for /f "delims=" %%v in ('node -v') do echo Node.js detected: %%v

if not exist ".env" (
  echo PASSWORD=change-me> .env
  echo [WARN] .env was missing, created with default password: change-me
)

echo [1/2] Installing dependencies ...
call npm install --no-audit --no-fund
if errorlevel 1 (
  echo [ERROR] npm install failed. Check network or npm registry settings.
  pause
  exit /b 1
)

echo [2/2] Building ...
call npm run build
if errorlevel 1 (
  echo [ERROR] npm run build failed.
  pause
  exit /b 1
)

echo.
echo Install finished. Run start.cmd to launch LibreTV.
pause
