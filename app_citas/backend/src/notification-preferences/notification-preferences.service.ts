import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UsersService } from '../users/users.service';
import { CreateNotificationPreferenceDto } from './dto/create-notification-preference.dto';
import { UpdateNotificationPreferenceDto } from './dto/update-notification-preference.dto';
import { NotificationPreference } from './entities/notification-preference.entity';

@Injectable()
export class NotificationPreferencesService {
  constructor(
    @InjectRepository(NotificationPreference)
    private readonly preferencesRepository: Repository<NotificationPreference>,
    private readonly usersService: UsersService,
  ) {}

  async create(createPreferenceDto: CreateNotificationPreferenceDto) {
    await this.usersService.findEntityById(createPreferenceDto.userId);
    const existingPreference = await this.preferencesRepository.findOne({
      where: { userId: createPreferenceDto.userId },
    });
    if (existingPreference) {
      throw new ConflictException(
        'El usuario ya tiene preferencias registradas',
      );
    }

    const preference = this.preferencesRepository.create(createPreferenceDto);
    return this.preferencesRepository.save(preference);
  }

  async findByUser(userId: number) {
    const preference = await this.preferencesRepository.findOne({
      where: { userId },
    });
    if (!preference) {
      throw new NotFoundException(
        'Preferencias de notificación no encontradas',
      );
    }
    return preference;
  }

  async update(
    id: number,
    updatePreferenceDto: UpdateNotificationPreferenceDto,
  ) {
    const preference = await this.preferencesRepository.findOne({
      where: { id },
    });
    if (!preference) {
      throw new NotFoundException(
        'Preferencias de notificación no encontradas',
      );
    }

    Object.assign(preference, updatePreferenceDto);
    return this.preferencesRepository.save(preference);
  }
}
