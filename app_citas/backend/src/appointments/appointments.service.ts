import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Brackets, Repository } from 'typeorm';
import { AppointmentStatus } from '../common/enums/appointment-status.enum';
import { ProfessionalsService } from '../professionals/professionals.service';
import { UsersService } from '../users/users.service';
import { CreateAppointmentDto } from './dto/create-appointment.dto';
import { FilterAppointmentsDto } from './dto/filter-appointments.dto';
import { UpdateAppointmentDto } from './dto/update-appointment.dto';
import { Appointment } from './entities/appointment.entity';

@Injectable()
export class AppointmentsService {
  constructor(
    @InjectRepository(Appointment)
    private readonly appointmentsRepository: Repository<Appointment>,
    private readonly usersService: UsersService,
    private readonly professionalsService: ProfessionalsService,
  ) {}

  async create(createAppointmentDto: CreateAppointmentDto) {
    await this.usersService.findEntityById(createAppointmentDto.userId);
    const professional = await this.professionalsService.findOne(
      createAppointmentDto.professionalId,
    );
    if (!professional.activo) {
      throw new BadRequestException('El profesional no está activo');
    }

    await this.validateScheduleAvailability(
      createAppointmentDto.professionalId,
      createAppointmentDto.fecha,
      createAppointmentDto.hora,
    );

    const appointment = this.appointmentsRepository.create({
      ...createAppointmentDto,
      estado: createAppointmentDto.estado ?? AppointmentStatus.PENDING,
    });
    return this.appointmentsRepository.save(appointment);
  }

  findAll(filters: FilterAppointmentsDto) {
    const query = this.appointmentsRepository.createQueryBuilder('appointment');

    if (filters.userId) {
      query.andWhere('appointment.userId = :userId', {
        userId: filters.userId,
      });
    }
    if (filters.professionalId) {
      query.andWhere('appointment.professionalId = :professionalId', {
        professionalId: filters.professionalId,
      });
    }
    if (filters.estado) {
      query.andWhere('appointment.estado = :estado', {
        estado: filters.estado,
      });
    }
    if (filters.fecha) {
      query.andWhere('appointment.fecha = :fecha', { fecha: filters.fecha });
    }
    if (filters.fechaInicio && filters.fechaFin) {
      query.andWhere('appointment.fecha BETWEEN :fechaInicio AND :fechaFin', {
        fechaInicio: filters.fechaInicio,
        fechaFin: filters.fechaFin,
      });
    }
    if (filters.texto) {
      query.andWhere(
        new Brackets((qb) => {
          qb.where('appointment.motivo LIKE :texto', {
            texto: `%${filters.texto}%`,
          }).orWhere('appointment.detalles LIKE :texto', {
            texto: `%${filters.texto}%`,
          });
        }),
      );
    }

    return query
      .orderBy('appointment.fecha', 'ASC')
      .addOrderBy('appointment.hora', 'ASC')
      .getMany();
  }

  async findOne(id: number) {
    const appointment = await this.appointmentsRepository.findOne({
      where: { id },
    });
    if (!appointment) {
      throw new NotFoundException('Cita no encontrada');
    }
    return appointment;
  }

  findByUser(userId: number) {
    return this.findAll({ userId });
  }

  findByProfessional(professionalId: number) {
    return this.findAll({ professionalId });
  }

  async update(id: number, updateAppointmentDto: UpdateAppointmentDto) {
    const appointment = await this.findOne(id);
    if (
      [AppointmentStatus.CANCELLED, AppointmentStatus.COMPLETED].includes(
        appointment.estado,
      )
    ) {
      throw new BadRequestException(
        'No se puede editar una cita cancelada o completada',
      );
    }

    const professionalId =
      updateAppointmentDto.professionalId ?? appointment.professionalId;
    const fecha = updateAppointmentDto.fecha ?? appointment.fecha;
    const hora = updateAppointmentDto.hora ?? appointment.hora.slice(0, 5);

    if (updateAppointmentDto.professionalId) {
      const professional = await this.professionalsService.findOne(
        updateAppointmentDto.professionalId,
      );
      if (!professional.activo) {
        throw new BadRequestException('El profesional no está activo');
      }
    }

    if (
      professionalId !== appointment.professionalId ||
      fecha !== appointment.fecha ||
      hora !== appointment.hora.slice(0, 5)
    ) {
      await this.validateScheduleAvailability(professionalId, fecha, hora, id);
    }

    Object.assign(appointment, updateAppointmentDto);
    return this.appointmentsRepository.save(appointment);
  }

  async confirm(id: number) {
    const appointment = await this.findOne(id);
    if (appointment.estado === AppointmentStatus.CANCELLED) {
      throw new BadRequestException('No se puede confirmar una cita cancelada');
    }
    if (appointment.estado === AppointmentStatus.COMPLETED) {
      throw new BadRequestException(
        'No se puede confirmar una cita completada',
      );
    }
    await this.validateScheduleAvailability(
      appointment.professionalId,
      appointment.fecha,
      appointment.hora.slice(0, 5),
      appointment.id,
    );
    appointment.estado = AppointmentStatus.CONFIRMED;
    return this.appointmentsRepository.save(appointment);
  }

  async cancel(id: number) {
    const appointment = await this.findOne(id);
    if (appointment.estado === AppointmentStatus.COMPLETED) {
      throw new BadRequestException('No se puede cancelar una cita completada');
    }
    appointment.estado = AppointmentStatus.CANCELLED;
    return this.appointmentsRepository.save(appointment);
  }

  async remove(id: number) {
    const appointment = await this.findOne(id);
    await this.appointmentsRepository.remove(appointment);
    return { message: 'Cita eliminada correctamente' };
  }

  private async validateScheduleAvailability(
    professionalId: number,
    fecha: string,
    hora: string,
    ignoreAppointmentId?: number,
  ) {
    const conflict = await this.appointmentsRepository
      .createQueryBuilder('appointment')
      .where('appointment.professionalId = :professionalId', { professionalId })
      .andWhere('appointment.fecha = :fecha', { fecha })
      .andWhere('appointment.hora = :hora', { hora })
      .andWhere('appointment.estado IN (:...statuses)', {
        statuses: [AppointmentStatus.PENDING, AppointmentStatus.CONFIRMED],
      })
      .andWhere(
        ignoreAppointmentId
          ? 'appointment.id != :ignoreAppointmentId'
          : '1 = 1',
        { ignoreAppointmentId },
      )
      .getOne();

    if (conflict) {
      throw new ConflictException(
        'El profesional ya tiene una cita en esa fecha y hora',
      );
    }
  }
}
