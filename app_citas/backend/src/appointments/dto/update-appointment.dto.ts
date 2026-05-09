import {
  IsDateString,
  IsInt,
  IsOptional,
  IsString,
  MaxLength,
  MinLength,
  Matches,
} from 'class-validator';
import { Transform, Type } from 'class-transformer';
import {
  trimString,
  trimToUndefined,
} from '../../common/utils/string-transform.util';

export class UpdateAppointmentDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  professionalId?: number;

  @IsOptional()
  @IsDateString()
  fecha?: string;

  @IsOptional()
  @Matches(/^([01]\d|2[0-3]):[0-5]\d$/)
  hora?: string;

  @IsOptional()
  @Transform(trimString)
  @IsString()
  @MinLength(5)
  @MaxLength(180)
  @Matches(/\S/, { message: 'El motivo no puede estar vacio' })
  motivo?: string;

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
