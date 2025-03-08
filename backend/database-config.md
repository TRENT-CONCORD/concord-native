# Concord Database Configuration

This document outlines the database configuration for the Concord application in both development and production environments.

## Environment Configuration

The application uses different database connections based on the `NODE_ENV` environment variable:

- `development` (default): Connects to the development database
- `production`: Connects to the production database

## Environment Files

- `.env`: Contains development database credentials
- `.env.production`: Contains production database credentials

## Database Servers

### Development

- **Host**: concord-dev-db.postgres.database.azure.com
- **Database**: concord_dev
- **Username**: concordadmindev
- **SSL**: Enabled and required

### Production

- **Host**: concord-api.postgres.database.azure.com
- **Database**: concord
- **Username**: concordadmin
- **SSL**: Enabled and required

## Running the Application

### Development Mode

```bash
cd backend
npm run start:dev
# or
./start-dev.bat
```

### Production Mode

```bash
cd backend
npm run start:prod
# or
./start-prod.bat
```

## Running Migrations

### Development Migrations

```bash
cd backend
npm run migrate:dev
# or
./migration-dev.bat
```

### Production Migrations

```bash
cd backend
npm run migrate:prod
# or
./migration-prod.bat
```

## Testing Connections

Use the test script to verify database connections:

```bash
cd backend
npx ts-node src/test-env-connection.ts
```

## Troubleshooting

If you encounter connection issues:

1. Verify the environment variables are set correctly
2. Check that the `.env` files exist and contain the correct credentials
3. Ensure the firewall rules in Azure allow connections from your IP address
4. Verify that SSL is properly configured 