import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppointmentsModule } from '../appointments/appointments.module';
import { UsersModule } from '../users/users.module';
import { Notification } from './entities/notification.entity';
import { NotificationsController } from './notifications.controller';
import { NotificationsService } from './notifications.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([Notification]),
    UsersModule,
    AppointmentsModule,
  ],
  controllers: [NotificationsController],
  providers: [NotificationsService],
})
export class NotificationsModule {}
