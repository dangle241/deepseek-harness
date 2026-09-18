@echo off
setlocal

cd /d "%~dp0.."

if not defined DEEPSEEK_API_KEY (
  echo DEEPSEEK_API_KEY is not set.
  exit /b 1
)

if not defined DEEPSEEK_BASE_URL set "DEEPSEEK_BASE_URL=http://localhost:20128/v1"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0generate-patch.ps1"
if errorlevel 1 exit /b %errorlevel%

call pnpm dsh --profile web --patch "%~dp0generated.patch.yml" --port 8080
exit /b %errorlevel%
