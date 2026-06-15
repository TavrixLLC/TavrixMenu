import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import * as fs from 'fs';
import * as path from 'path';
import { AppModule } from '../src/app.module';
import { NestExpressApplication } from '@nestjs/platform-express';

async function bootstrap() {
  // Disable logging to keep stdout clean during CLI run
  const app = await NestFactory.create<NestExpressApplication>(AppModule, { logger: false });
  
  const swaggerConfig = new DocumentBuilder()
    .setTitle('Tavrix Menu API')
    .setDescription(
      [
        'Tavrix Menu backend API.',
        'Production and staging clients must send real Clerk JWTs with Authorization: Bearer <clerk-jwt>.',
        'Development can use dev tokens only when NODE_ENV=development.',
        'Development auth header example:',
        'Authorization: Bearer dev:user_tavrix_owner;email=owner@tavrix.local;name=Tavrix%20Owner'
      ].join('\n\n')
    )
    .setVersion('0.1.0')
    .addServer('http://localhost:3000')
    .addBearerAuth()
    .build();

  const swaggerDocument = SwaggerModule.createDocument(app, swaggerConfig);
  const outputPath = path.join(__dirname, '..', 'openapi.json');
  fs.writeFileSync(outputPath, JSON.stringify(swaggerDocument, null, 2), 'utf8');
  console.log(`OpenAPI spec successfully written to: ${outputPath}`);
  await app.close();
}

void bootstrap();
