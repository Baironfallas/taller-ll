import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProfessionalsModule } from '../professionals/professionals.module';
import { ProfessionalSchedule } from '../professional-schedules/entities/professional-schedule.entity';
import { UsersModule } from '../users/users.module';
import { AppointmentsController } from './appointments.controller';
import { AppointmentsService } from './appointments.service';
import { Appointment } from './entities/appointment.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([Appointment, ProfessionalSchedule]),
    UsersModule,
    ProfessionalsModule,
  ],
  controllers: [AppointmentsController],
  providers: [AppointmentsService],
  exports: [AppointmentsService],
})
export class AppointmentsModule {}
