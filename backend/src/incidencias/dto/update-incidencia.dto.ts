import { PartialType } from '@nestjs/mapped-types';
import { CreateIncidenciaDto } from './create-incidencia.dto';

export class UpdateIncidenciaDto {
  jurisdiccion_valida?: boolean;
  gravedad?: string;
  estado?: string;
  id_cuadrilla?: number;
}