export declare function loadEnvironment(): void;
export declare function getDatabaseConfig(): {
    type: string;
    host: string;
    port: number;
    username: string;
    password: string;
    database: string;
    synchronize: boolean;
    logging: boolean;
    ssl: {
        rejectUnauthorized: boolean;
    };
    autoLoadEntities: boolean;
    migrationsRun: boolean;
    migrationsTableName: string;
    migrations: string[];
    entities: string[];
};
export declare function getServerConfig(): {
    port: number;
    cors: {
        origin: string;
        methods: string;
        credentials: boolean;
    };
    rateLimits: {
        windowMs: number;
        max: number;
    };
};
