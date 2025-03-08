@echo off
echo Starting application in DEVELOPMENT mode...
set NODE_ENV=development
cd %~dp0
npx tsc
node -r reflect-metadata dist/index.js 