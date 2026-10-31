@echo off
setlocal
cd /d "%~dp0"

set "LIBRETV_PROXY="
set "PEN="
set "SYSPROXY="
for /f "tokens=3" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable 2^>nul ^| findstr /i ProxyEnable') do set "PEN=%%a"
if /i "%PEN%"=="0x1" (
  for /f "tokens=3" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer 2^>nul ^| findstr /i ProxyServer') do set "SYSPROXY=%%a"
)
if defined SYSPROXY set "LIBRETV_PROXY=http://%SYSPROXY%"

set "CFG=%~dp0proxy-setup.cjs"
set "CFG=%CFG:\=/%"
set "NODE_OPTIONS=--require "%CFG%""

echo LibreTV starting ... open http://localhost:8080 in your browser.
call npm start
