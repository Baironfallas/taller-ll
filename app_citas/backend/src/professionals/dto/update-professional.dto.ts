import { IsEmail, IsOptional, IsString } from 'class-validator';

export class UpdateProfessionalDto {
  @IsOptional()
  @IsString()
  nombre?: string;

  @IsOptional()
  @IsString()
  apellido?: string;

  @IsOptional()
  @IsString()
  especialidad?: string;

  @IsOptional()
  @IsString()
  descripcion?: string;

  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @IsString()
  telefono?: string;
}
