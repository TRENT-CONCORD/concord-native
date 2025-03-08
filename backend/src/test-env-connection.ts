import { DataSource } from "typeorm";

async function testConnection(env: string) {
  // Configuration based on environment
  const config = env === 'production' 
    ? {
        host: 'concord-api.postgres.database.azure.com',
        port: 5432,
        username: 'concordadmin',
        password: '8J09#8@!k', // Set this manually when testing production
        database: 'concord',
      }
    : {
        host: 'concord-dev-db.postgres.database.azure.com',
        port: 5432,
        username: 'concordadmindev',
        password: 'Jhvaj8zZrGm4',
        database: 'concord_dev',
      };
  
  // Create DataSource for the current environment
  const dataSource = new DataSource({
    type: "postgres",
    host: config.host,
    port: config.port,
    username: config.username,
    password: config.password,
    database: config.database,
    ssl: {
      rejectUnauthorized: true
    }
  });

  try {
    console.log(`\n--- Testing ${env.toUpperCase()} Database Connection ---`);
    console.log(`Host: ${config.host}`);
    console.log(`Database: ${config.database}`);
    console.log(`Username: ${config.username}`);
    
    console.log('Initializing connection...');
    await dataSource.initialize();
    console.log('✅ Connection successful!');
    
    // Run a simple query to verify the connection
    const result = await dataSource.query('SELECT NOW() as current_time');
    console.log(`Current time from database: ${result[0].current_time}`);
    
    await dataSource.destroy();
    console.log('Connection closed.');
    return true;
  } catch (error) {
    console.error(`❌ Error connecting to ${env} database:`, error);
    return false;
  }
}

async function runTests() {
  console.log('=== Database Connection Test ===');
  
  // Test development connection
  const devSuccess = await testConnection('development');
  
  // Test production connection if you have the credentials
  const prodSuccess = await testConnection('production');
  console.log(`Production: ${prodSuccess ? '✅ Connected' : '❌ Failed'}`);
  
  console.log('\n=== Test Results ===');
  console.log(`Development: ${devSuccess ? '✅ Connected' : '❌ Failed'}`);
}

runTests(); 