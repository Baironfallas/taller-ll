import {
  IsDateString,
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Matches,
} from 'class-validator';
import { AppointmentStatus } from '../../common/enums/appointment-status.enum';

export class CreateAppointmentDto {
  @IsInt()
  userId: number;

  @IsInt()
  professionalId: number;

  @IsDateString()
  fecha: string;

  @Matches(/^([01]\d|2[0-3]):[0-5]\d$/)
  hora: string;

  @IsString()
  @IsNotEmpty()
  motivo: string;

  @IsString()
  @IsNotEmpty()
  detalles: string;

  @IsOptional()
  @IsEnum(AppointmentStatus)
  estado?: AppointmentStatus;

  @IsString()
  @IsNotEmpty()
  ubicacion: string;

  @IsString()
  @IsNotEmpty()
  instrucciones: string;
}
