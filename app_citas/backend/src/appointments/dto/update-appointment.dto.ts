import {
  IsDateString,
  IsInt,
  IsOptional,
  IsString,
  Matches,
} from 'class-validator';

export class UpdateAppointmentDto {
  @IsOptional()
  @IsInt()
  professionalId?: number;

  @IsOptional()
  @IsDateString()
  fecha?: string;

  @IsOptional()
  @Matches(/^([01]\d|2[0-3]):[0-5]\d$/)
  hora?: string;

  @IsOptional()
  @IsString()
  motivo?: string;

  @IsOptional()
  @IsString()
  detalles?: string;

  @IsOptional()
  @IsString()
  ubicacion?: string;

  @IsOptional()
  @IsString()
  instrucciones?: string;
}
