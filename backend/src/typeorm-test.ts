import { DataSource } from "typeorm";

async function testTypeORMConnection() {
  // Create a new DataSource with hardcoded credentials
  const dataSource = new DataSource({
    type: "postgres",
    host: 'concord-dev-db.postgres.database.azure.com',
    port: 5432,
    username: 'concordadmindev',
    password: 'Jhvaj8zZrGm4',
    database: 'concord_dev',
    ssl: {
      rejectUnauthorized: true
    }
  });

  try {
    console.log('Initializing TypeORM DataSource...');
    await dataSource.initialize();
    console.log('✅ TypeORM DataSource initialized successfully!');
    
    // Run a simple query to verify the connection
    const result = await dataSource.query('SELECT NOW() as current_time');
    console.log('Current time from database:', result[0].current_time);
    
    await dataSource.destroy();
    console.log('Connection closed.');
  } catch (error) {
    console.error('❌ Error initializing TypeORM DataSource:', error);
  }
}

testTypeORMConnection(); 