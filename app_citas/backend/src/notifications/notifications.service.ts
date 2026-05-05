import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AppointmentsService } from '../appointments/appointments.service';
import { UsersService } from '../users/users.service';
import { CreateNotificationDto } from './dto/create-notification.dto';
import { Notification } from './entities/notification.entity';

@Injectable()
export class NotificationsService {
  constructor(
    @InjectRepository(Notification)
    private readonly notificationsRepository: Repository<Notification>,
    private readonly usersService: UsersService,
    private readonly appointmentsService: AppointmentsService,
  ) {}

  async create(createNotificationDto: CreateNotificationDto) {
    await this.usersService.findEntityById(createNotificationDto.userId);
    if (createNotificationDto.appointmentId) {
      await this.appointmentsService.findOne(
        createNotificationDto.appointmentId,
      );
    }

    const notification = this.notificationsRepository.create({
      ...createNotificationDto,
      appointmentId: createNotificationDto.appointmentId ?? null,
    });
    return this.notificationsRepository.save(notification);
  }

  findByUser(userId: number) {
    return this.notificationsRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  async markAsRead(id: number) {
    const notification = await this.findOne(id);
    notification.leida = true;
    return this.notificationsRepository.save(notification);
  }

  async remove(id: number) {
    const notification = await this.findOne(id);
    await this.notificationsRepository.remove(notification);
    return { message: 'Notificación eliminada correctamente' };
  }

  private async findOne(id: number) {
    const notification = await this.notificationsRepository.findOne({
      where: { id },
    });
    if (!notification) {
      throw new NotFoundException('Notificación no encontrada');
    }
    return notification;
  }
}
