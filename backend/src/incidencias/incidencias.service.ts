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

  async update(id: number, updateDto: UpdateIncidenciaDto) {
  const dataToUpdate: any = {};

  // Manejo explícito del cambio de estado al cambiar jurisdicción
  if (updateDto.jurisdiccion_valida !== undefined) {
    dataToUpdate.jurisdiccion_valida = updateDto.jurisdiccion_valida;
    if (!updateDto.jurisdiccion_valida) {
      dataToUpdate.estado = 'Descartada_OIRS';
    } else {
      dataToUpdate.estado = 'En_Espera'; // Se reactiva en la base de datos
    }
  }

  if (updateDto.estado !== undefined) {
    dataToUpdate.estado = updateDto.estado;
  }

  if (updateDto.gravedad !== undefined) {
    dataToUpdate.gravedad = updateDto.gravedad;
  }

  // 1. Actualizar la incidencia principal en PostgreSQL
  const incidenciaActualizada = await this.prisma.incidencias.update({
    where: { id_incidencia: id },
    data: dataToUpdate,
  });

  // 2. Si se envió una cuadrilla, crear o actualizar la Orden de Trabajo
  if (updateDto.id_cuadrilla) {
    await this.prisma.ordenes_trabajo.upsert({
      where: { id_incidencia: id },
      update: {
        id_cuadrilla: updateDto.id_cuadrilla,
      },
      create: {
        id_incidencia: id,
        id_cuadrilla: updateDto.id_cuadrilla,
        fecha_asignacion: new Date(),
      },
    });

    // Cambiar estado a 'Asignada'
    await this.prisma.incidencias.update({
      where: { id_incidencia: id },
      data: { estado: 'Asignada' },
    });
  }

    return incidenciaActualizada;
  }

  remove(id: number) {
    return this.prisma.incidencias.delete({
      where: { id_incidencia: id },
    });
  }
}