import {
  IsDateString,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
} from 'class-validator';
import { Type } from 'class-transformer';
import { AppointmentStatus } from '../../common/enums/appointment-status.enum';

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
  @IsString()
  texto?: string;
}
