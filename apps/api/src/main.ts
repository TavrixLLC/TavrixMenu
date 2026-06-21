import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { join } from 'path';
import { AppModule } from './app.module';
import { createAppleWalletRequestLogger } from './modules/apple-wallet/apple-wallet-request-logger';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);
  const configService = app.get(ConfigService);
  const port = configService.get<number>('API_PORT', 3000);
  const generatedAssetsPath = join(process.cwd(), 'public', 'generated');

  app.enableCors({
    origin: true,
    credentials: true
  });

  app.use(createAppleWalletRequestLogger());

  app.useStaticAssets(generatedAssetsPath, {
    prefix: '/generated/',
    dotfiles: 'deny',
    fallthrough: false,
    index: false
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
