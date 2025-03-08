module.exports = {
  moduleFileExtensions: ['js', 'json', 'ts'],
  rootDir: 'src',
  testRegex: '.*\\.spec\\.ts$',
  transform: {
    '^.+\\.(t|j)s$': 'ts-jest',
  },
  collectCoverageFrom: ['**/*.(t|j)s'],
  coverageDirectory: '../coverage',
  testEnvironment: 'node',
  moduleNameMapper: {
    '^src/(.*)$': '<rootDir>/$1',
  },
  setupFiles: ['<rootDir>/test/setup.ts'],
  globals: {
    'ts-jest': {
      tsconfig: {
        // Allow JavaScript files to be processed
        allowJs: true,
      },
    },
  },
  // Mock TypeORM entities to avoid decorator issues
  moduleNameMapper: {
    '^src/models/(.*)$': '<rootDir>/test/mocks/models.mock.ts',
    '^src/explore/models/(.*)$': '<rootDir>/test/mocks/models.mock.ts',
  },
}; 