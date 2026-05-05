import { UserRole } from '../../common/enums/user-role.enum';
import { User } from '../entities/user.entity';

export class UserResponseDto {
  id: number;
  nombre: string;
  apellido: string;
  email: string;
  telefono: string;
  rol: UserRole;
  activo: boolean;
  createdAt: Date;
  updatedAt: Date;

  constructor(user: User) {
    this.id = user.id;
    this.nombre = user.nombre;
    this.apellido = user.apellido;
    this.email = user.email;
    this.telefono = user.telefono;
    this.rol = user.rol;
    this.activo = user.activo;
    this.createdAt = user.createdAt;
    this.updatedAt = user.updatedAt;
  }
}
