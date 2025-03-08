@echo off
echo Starting application in PRODUCTION mode...
set NODE_ENV=production
cd %~dp0
npx tsc
node -r reflect-metadata dist/main.js 