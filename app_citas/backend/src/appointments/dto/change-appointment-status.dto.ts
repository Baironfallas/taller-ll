import { IsOptional, IsString, MaxLength, MinLength } from 'class-validator';
import { Transform } from 'class-transformer';
import { trimToUndefined } from '../../common/utils/string-transform.util';

export class ChangeAppointmentStatusDto {
  @IsOptional()
  @Transform(trimToUndefined)
  @IsString()
  @MinLength(5)
  @MaxLength(500)
  motivo?: string;
}
