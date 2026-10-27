import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaService } from './prisma/prisma.service';
import { IncidenciasModule } from './incidencias/incidencias.module';

@Module({
  imports: [IncidenciasModule],
  controllers: [AppController],
  providers: [AppService, PrismaService],
})
export class AppModule {}
