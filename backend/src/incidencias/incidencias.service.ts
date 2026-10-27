import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateIncidenciaDto } from './dto/create-incidencia.dto';
import { UpdateIncidenciaDto } from './dto/update-incidencia.dto';

@Injectable()
export class IncidenciasService {
  constructor(private prisma: PrismaService) {}

  async create(createIncidenciaDto: CreateIncidenciaDto) {
  return this.prisma.incidencias.create({
    data: {
      codigo_seguimiento: createIncidenciaDto.codigo_seguimiento,
      categoria: createIncidenciaDto.categoria,
      sector: createIncidenciaDto.sector,
      latitud: createIncidenciaDto.latitud,
      longitud: createIncidenciaDto.longitud,
      dentro_de_coquimbo: createIncidenciaDto.dentro_de_coquimbo,
      descripcion: createIncidenciaDto.descripcion,
      jurisdiccion_valida: createIncidenciaDto.jurisdiccion_valida,
      gravedad: createIncidenciaDto.gravedad || 'Rutina',
      estado: createIncidenciaDto.estado || 'Ingresada',
      foto_inicial_url: createIncidenciaDto.foto_inicial_url,
      id_departamento: createIncidenciaDto.id_departamento || 1,
    },
  });
}

  findAll() {
    return this.prisma.incidencias.findMany({
      include: {
        departamentos: true,
        ordenes_trabajo: true,
      },
    });
  }

  findOne(id: number) {
    return this.prisma.incidencias.findUnique({
      where: { id_incidencia: id },
    });
  }

  update(id: number, updateIncidenciaDto: UpdateIncidenciaDto) {
    return this.prisma.incidencias.update({
      where: { id_incidencia: id },
      data: updateIncidenciaDto as any,
    });
  }

  remove(id: number) {
    return this.prisma.incidencias.delete({
      where: { id_incidencia: id },
    });
  }
}