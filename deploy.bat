@echo off
echo Running deployment script...
powershell.exe -ExecutionPolicy Bypass -File "%~dp0deploy.ps1"
if %ERRORLEVEL% NEQ 0 (
  echo Deployment failed with error code %ERRORLEVEL%
  pause
  exit /b %ERRORLEVEL%
)
echo Deployment completed successfully!
pause 