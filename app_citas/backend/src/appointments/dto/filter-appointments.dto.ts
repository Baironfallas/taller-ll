import {
  IsDateString,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
} from 'class-validator';
import { Transform, Type } from 'class-transformer';
import { AppointmentStatus } from '../../common/enums/appointment-status.enum';
import { trimToUndefined } from '../../common/utils/string-transform.util';

export class FilterAppointmentsDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  userId?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  professionalId?: number;

  @IsOptional()
  @IsEnum(AppointmentStatus)
  estado?: AppointmentStatus;

  @IsOptional()
  @IsDateString()
  fecha?: string;

  @IsOptional()
  @IsDateString()
  fechaInicio?: string;

  @IsOptional()
  @IsDateString()
  fechaFin?: string;

  @IsOptional()
  @Transform(trimToUndefined)
  @IsString()
  texto?: string;
}
