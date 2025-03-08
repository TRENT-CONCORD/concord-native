import AppDataSource from './data-source';

const testConnection = async () => {
  try {
    console.log('Attempting to connect to the database...');
    await AppDataSource.initialize();
    console.log('✅ Database connection successful!');
    
    // Run a simple query to verify the connection
    const result = await AppDataSource.query('SELECT NOW() as current_time');
    console.log('Current time from database:', result[0].current_time);
    
    await AppDataSource.destroy();
    console.log('Connection closed.');
    process.exit(0);
  } catch (error) {
    console.error('❌ Database connection failed:', error);
    process.exit(1);
  }
};

testConnection(); 