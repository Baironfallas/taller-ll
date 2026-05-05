import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppointmentType } from '../appointment-types/entities/appointment-type.entity';
import { ProfessionalSchedule } from '../professional-schedules/entities/professional-schedule.entity';
import { Professional } from '../professionals/entities/professional.entity';
import { SeederService } from './seeder.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Professional,
      AppointmentType,
      ProfessionalSchedule,
    ]),
  ],
  providers: [SeederService],
})
export class SeederModule {}
