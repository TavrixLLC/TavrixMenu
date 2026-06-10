import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const configService = app.get(ConfigService);
  const port = configService.get<number>('API_PORT', 3000);

  app.enableCors({
    origin: true,
    credentials: true
  });

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true
    })
  );

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
  SwaggerModule.setup('docs', app, swaggerDocument);

  await app.listen(port);
}

void bootstrap();
