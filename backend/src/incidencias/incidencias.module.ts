import { Module } from '@nestjs/common';
import { IncidenciasService } from './incidencias.service';
import { IncidenciasController } from './incidencias.controller';
import { PrismaService } from '../prisma/prisma.service';

@Module({
  controllers: [IncidenciasController],
  providers: [IncidenciasService, PrismaService],
})
export class IncidenciasModule {}