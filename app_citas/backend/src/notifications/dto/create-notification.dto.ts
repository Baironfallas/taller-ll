import {
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
} from 'class-validator';
import { NotificationType } from '../../common/enums/notification-type.enum';

export class CreateNotificationDto {
  @IsInt()
  userId: number;

  @IsOptional()
  @IsInt()
  appointmentId?: number;

  @IsString()
  @IsNotEmpty()
  titulo: string;

  @IsString()
  @IsNotEmpty()
  mensaje: string;

  @IsEnum(NotificationType)
  tipo: NotificationType;
}
