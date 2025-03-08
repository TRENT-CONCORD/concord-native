@echo off
echo Running migrations in DEVELOPMENT mode...
set NODE_ENV=development
npx tsc -p ./tsconfig.json
npx typeorm migration:run --dataSource dist/cli-config.js 