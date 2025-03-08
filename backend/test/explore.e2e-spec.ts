import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';
import { getConnection } from 'typeorm';

describe('ExploreController (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api');
    app.useGlobalPipes(new ValidationPipe({
      whitelist: true,
      transform: true,
    }));
    
    await app.init();
  });

  afterAll(async () => {
    // Clean up database connections
    const connection = getConnection();
    if (connection.isConnected) {
      await connection.close();
    }
    await app.close();
  });

  it('/api/explore (GET)', () => {
    return request(app.getHttpServer())
      .get('/api/explore')
      .expect(200)
      .expect((res) => {
        expect(Array.isArray(res.body)).toBeTruthy();
        if (res.body.length > 0) {
          expect(res.body[0]).toHaveProperty('id');
          expect(res.body[0]).toHaveProperty('displayName');
        }
      });
  });

  it('/api/explore (GET) with filters', () => {
    return request(app.getHttpServer())
      .get('/api/explore?minAge=20&maxAge=30')
      .expect(200)
      .expect((res) => {
        expect(Array.isArray(res.body)).toBeTruthy();
      });
  });

  it('/api/explore/filters (POST)', () => {
    const payload = {
      userId: 'testUser123',
      filters: {
        minAge: 18,
        maxAge: 30,
      },
    };
    
    return request(app.getHttpServer())
      .post('/api/explore/filters')
      .send(payload)
      .expect(201)
      .expect((res) => {
        expect(res.body).toBeDefined();
      });
  });

  it('/api/explore/filters/:userId (GET)', () => {
    const userId = 'testUser123';
    
    return request(app.getHttpServer())
      .get(`/api/explore/filters/${userId}`)
      .expect(200)
      .expect((res) => {
        expect(Array.isArray(res.body)).toBeTruthy();
      });
  });
}); 