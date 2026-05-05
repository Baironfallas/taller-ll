import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { UserResponseDto } from '../users/dto/user-response.dto';
import { User } from '../users/entities/user.entity';
import { UsersService } from '../users/users.service';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
  ) {}

  async register(registerDto: RegisterDto) {
    const user = await this.usersService.create(registerDto);
    return { message: 'Usuario registrado correctamente', user };
  }

  async login(loginDto: LoginDto) {
    const user = await this.usersService.findByEmail(loginDto.email);
    if (!user || !user.activo) {
      throw new UnauthorizedException('Credenciales inválidas');
    }

    const passwordMatches = await bcrypt.compare(
      loginDto.password,
      user.password,
    );
    if (!passwordMatches) {
      throw new UnauthorizedException('Credenciales inválidas');
    }

    const payload = { sub: user.id, email: user.email, rol: user.rol };
    return {
      accessToken: await this.jwtService.signAsync(payload),
      user: new UserResponseDto(user),
    };
  }

  me(user: User) {
    return new UserResponseDto(user);
  }

  logout() {
    return {
      message: 'Sesión cerrada correctamente. Elimina el token en el frontend.',
    };
  }

  forgotPassword(forgotPasswordDto: ForgotPasswordDto) {
    return {
      message:
        'Si el correo existe, se enviarán instrucciones para recuperar la contraseña.',
      email: forgotPasswordDto.email,
    };
  }

  async resetPassword(resetPasswordDto: ResetPasswordDto) {
    await this.usersService.updatePasswordByEmail(
      resetPasswordDto.email,
      resetPasswordDto.newPassword,
    );
    return { message: 'Contraseña restablecida correctamente' };
  }
}
