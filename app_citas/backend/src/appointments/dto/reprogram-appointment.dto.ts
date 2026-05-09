import { Transform, Type } from 'class-transformer';
import {
  IsDateString,
  IsInt,
  IsOptional,
  IsString,
  MaxLength,
  MinLength,
  Matches,
} from 'class-validator';
import {
  trimString,
  trimToUndefined,
} from '../../common/utils/string-transform.util';

export class ReprogramAppointmentDto {
  @IsDateString()
  fecha: string;

  @Matches(/^([01]\d|2[0-3]):[0-5]\d$/)
  hora: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  professionalId?: number;

  @IsOptional()
  @Transform(trimToUndefined)
  @IsString()
  @MinLength(5)
  @MaxLength(500)
  motivo?: string;

  @IsOptional()
  @Transform(trimString)
  @IsString()
  @MinLength(5)
  @MaxLength(180)
  @Matches(/\S/, { message: 'El motivo no puede estar vacio' })
  appointmentReason?: string;

  @IsOptional()
  @Transform(trimToUndefined)
  @IsString()
  @MaxLength(1000)
  detalles?: string;

  @IsOptional()
  @Transform(trimToUndefined)
  @IsString()
  @MaxLength(180)
  ubicacion?: string;

  @IsOptional()
  @Transform(trimToUndefined)
  @IsString()
  @MaxLength(1000)
  instrucciones?: string;
}
