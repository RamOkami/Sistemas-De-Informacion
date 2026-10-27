export class CreateIncidenciaDto {
  codigo_seguimiento: string;
  categoria: string;
  sector: string;
  latitud: number;
  longitud: number;
  dentro_de_coquimbo: boolean;
  descripcion: string;
  jurisdiccion_valida: boolean;
  gravedad?: string;
  estado?: string;
  foto_inicial_url: string;
  id_departamento?: number;
}