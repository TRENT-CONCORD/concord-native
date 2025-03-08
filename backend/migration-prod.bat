@echo off
echo Running migrations in PRODUCTION mode...
set NODE_ENV=production
npx tsc -p ./tsconfig.json
npx typeorm migration:run --dataSource dist/cli-config.js 