import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import * as bcrypt from 'bcrypt';
import { Repository } from 'typeorm';
import { ChangePasswordDto } from './dto/change-password.dto';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { UserResponseDto } from './dto/user-response.dto';
import { User } from './entities/user.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly usersRepository: Repository<User>,
  ) {}

  async create(createUserDto: CreateUserDto): Promise<UserResponseDto> {
    const existingUser = await this.usersRepository.findOne({
      where: { email: createUserDto.email },
    });
    if (existingUser) {
      throw new ConflictException('El correo ya se encuentra registrado');
    }

    const hashedPassword = await bcrypt.hash(createUserDto.password, 10);
    const user = this.usersRepository.create({
      ...createUserDto,
      password: hashedPassword,
    });
    const savedUser = await this.usersRepository.save(user);
    return new UserResponseDto(savedUser);
  }

  async findAll(): Promise<UserResponseDto[]> {
    const users = await this.usersRepository.find();
    return users.map((user) => new UserResponseDto(user));
  }

  async findOne(id: number): Promise<UserResponseDto> {
    const user = await this.findEntityById(id);
    return new UserResponseDto(user);
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.usersRepository.findOne({ where: { email } });
  }

  async findEntityById(id: number): Promise<User> {
    const user = await this.usersRepository.findOne({ where: { id } });
    if (!user) {
      throw new NotFoundException('Usuario no encontrado');
    }
    return user;
  }

  async update(
    id: number,
    updateUserDto: UpdateUserDto,
  ): Promise<UserResponseDto> {
    const user = await this.findEntityById(id);
    if (updateUserDto.email && updateUserDto.email !== user.email) {
      const existingUser = await this.usersRepository.findOne({
        where: { email: updateUserDto.email },
      });
      if (existingUser) {
        throw new ConflictException('El correo ya se encuentra registrado');
      }
    }

    Object.assign(user, updateUserDto);
    const updatedUser = await this.usersRepository.save(user);
    return new UserResponseDto(updatedUser);
  }

  async changePassword(
    id: number,
    changePasswordDto: ChangePasswordDto,
  ): Promise<{ message: string }> {
    const user = await this.findEntityById(id);
    const passwordMatches = await bcrypt.compare(
      changePasswordDto.currentPassword,
      user.password,
    );
    if (!passwordMatches) {
      throw new UnauthorizedException('La contraseña actual no es correcta');
    }

    if (changePasswordDto.currentPassword === changePasswordDto.newPassword) {
      throw new BadRequestException('La nueva contraseña debe ser diferente');
    }

    user.password = await bcrypt.hash(changePasswordDto.newPassword, 10);
    await this.usersRepository.save(user);
    return { message: 'Contraseña actualizada correctamente' };
  }

  async updatePasswordByEmail(
    email: string,
    newPassword: string,
  ): Promise<void> {
    const user = await this.findByEmail(email);
    if (!user) {
      throw new NotFoundException('Usuario no encontrado');
    }
    user.password = await bcrypt.hash(newPassword, 10);
    await this.usersRepository.save(user);
  }

  async deactivate(id: number): Promise<UserResponseDto> {
    const user = await this.findEntityById(id);
    user.activo = false;
    const updatedUser = await this.usersRepository.save(user);
    return new UserResponseDto(updatedUser);
  }
}
