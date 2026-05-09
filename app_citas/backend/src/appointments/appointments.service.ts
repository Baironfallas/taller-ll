import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Brackets, Repository, SelectQueryBuilder } from 'typeorm';
import { AppointmentStatus } from '../common/enums/appointment-status.enum';
import { UserRole } from '../common/enums/user-role.enum';
import { ProfessionalSchedule } from '../professional-schedules/entities/professional-schedule.entity';
import { ProfessionalsService } from '../professionals/professionals.service';
import { User } from '../users/entities/user.entity';
import { UsersService } from '../users/users.service';
import { AppointmentResponseDto } from './dto/appointment-response.dto';
import { ChangeAppointmentStatusDto } from './dto/change-appointment-status.dto';
import { CreateAppointmentDto } from './dto/create-appointment.dto';
import { FilterAppointmentsDto } from './dto/filter-appointments.dto';
import { ReprogramAppointmentDto } from './dto/reprogram-appointment.dto';
import { UpdateAppointmentDto } from './dto/update-appointment.dto';
import { Appointment } from './entities/appointment.entity';

const ACTIVE_APPOINTMENT_STATUSES = [
  AppointmentStatus.PENDING,
  AppointmentStatus.CONFIRMED,
  AppointmentStatus.RESCHEDULED,
];

const EDITABLE_APPOINTMENT_STATUSES = [
  AppointmentStatus.PENDING,
  AppointmentStatus.CONFIRMED,
  AppointmentStatus.RESCHEDULED,
];

const STATUS_TRANSITIONS: Record<AppointmentStatus, AppointmentStatus[]> = {
  [AppointmentStatus.PENDING]: [
    AppointmentStatus.CONFIRMED,
    AppointmentStatus.CANCELLED,
    AppointmentStatus.REJECTED,
  ],
  [AppointmentStatus.CONFIRMED]: [
    AppointmentStatus.COMPLETED,
    AppointmentStatus.CANCELLED,
    AppointmentStatus.RESCHEDULED,
  ],
  [AppointmentStatus.CANCELLED]: [],
  [AppointmentStatus.COMPLETED]: [],
  [AppointmentStatus.REJECTED]: [],
  [AppointmentStatus.RESCHEDULED]: [
    AppointmentStatus.CONFIRMED,
    AppointmentStatus.CANCELLED,
  ],
};

@Injectable()
export class AppointmentsService {
  constructor(
    @InjectRepository(Appointment)
    private readonly appointmentsRepository: Repository<Appointment>,
    @InjectRepository(ProfessionalSchedule)
    private readonly schedulesRepository: Repository<ProfessionalSchedule>,
    private readonly usersService: UsersService,
    private readonly professionalsService: ProfessionalsService,
  ) {}

  async create(createAppointmentDto: CreateAppointmentDto, currentUser: User) {
    this.ensureCreateStartsPending(createAppointmentDto.estado);
    this.assertUserScope(currentUser, createAppointmentDto.userId);

    const user = await this.usersService.findEntityById(
      createAppointmentDto.userId,
    );
    if (!user.activo) {
      throw new BadRequestException('El usuario asociado no esta activo');
    }

    await this.ensureActiveProfessional(createAppointmentDto.professionalId);
    await this.validateScheduleAvailability(
      createAppointmentDto.professionalId,
      createAppointmentDto.userId,
      createAppointmentDto.fecha,
      createAppointmentDto.hora,
    );

    const appointment = this.appointmentsRepository.create({
      userId: createAppointmentDto.userId,
      professionalId: createAppointmentDto.professionalId,
      fecha: createAppointmentDto.fecha,
      hora: createAppointmentDto.hora,
      motivo: createAppointmentDto.motivo,
      detalles: createAppointmentDto.detalles ?? '',
      estado: AppointmentStatus.PENDING,
      ubicacion: createAppointmentDto.ubicacion ?? '',
      instrucciones: createAppointmentDto.instrucciones ?? '',
      fechaAnterior: null,
      horaAnterior: null,
      motivoCancelacion: null,
      motivoRechazo: null,
    });

    const savedAppointment =
      await this.appointmentsRepository.save(appointment);
    const fullAppointment = await this.findEntityById(savedAppointment.id);

    return this.buildMutationResponse(
      'Cita creada correctamente',
      fullAppointment.id,
    );
  }

  async findAll(filters: FilterAppointmentsDto, currentUser: User) {
    if (filters.userId) {
      this.assertUserScope(currentUser, filters.userId);
    }

    this.validateDateRange(filters.fechaInicio, filters.fechaFin);

    const query = this.appointmentsRepository
      .createQueryBuilder('appointment')
      .leftJoinAndSelect('appointment.user', 'user')
      .leftJoinAndSelect('appointment.professional', 'professional');
    this.applyVisibilityScope(query, currentUser);

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

    const appointments = await query
      .orderBy('appointment.fecha', 'ASC')
      .addOrderBy('appointment.hora', 'ASC')
      .getMany();

    return appointments.map(
      (appointment) => new AppointmentResponseDto(appointment),
    );
  }

  async findOne(id: number, currentUser: User) {
    const appointment = await this.findManagedAppointment(id, currentUser);
    return new AppointmentResponseDto(appointment);
  }

  findByUser(userId: number, currentUser: User) {
    return this.findAll({ userId }, currentUser);
  }

  findByProfessional(professionalId: number, currentUser: User) {
    return this.findAll({ professionalId }, currentUser);
  }

  findByStatus(estado: AppointmentStatus, currentUser: User) {
    return this.findAll({ estado }, currentUser);
  }

  findByDateRange(fechaInicio: string, fechaFin: string, currentUser: User) {
    return this.findAll({ fechaInicio, fechaFin }, currentUser);
  }

  async update(
    id: number,
    updateAppointmentDto: UpdateAppointmentDto,
    currentUser: User,
  ) {
    const appointment = await this.findManagedAppointment(id, currentUser);
    this.ensureAppointmentEditable(appointment);

    if (!this.hasAtLeastOneValue(updateAppointmentDto)) {
      throw new BadRequestException(
        'No se enviaron cambios para actualizar la cita',
      );
    }

    const isScheduleChange =
      updateAppointmentDto.professionalId !== undefined ||
      updateAppointmentDto.fecha !== undefined ||
      updateAppointmentDto.hora !== undefined;

    if (isScheduleChange) {
      return this.applyReschedule(appointment, {
        professionalId: updateAppointmentDto.professionalId,
        fecha: updateAppointmentDto.fecha ?? appointment.fecha,
        hora: updateAppointmentDto.hora ?? this.normalizeTime(appointment.hora),
        appointmentReason: updateAppointmentDto.motivo,
        detalles: updateAppointmentDto.detalles,
        ubicacion: updateAppointmentDto.ubicacion,
        instrucciones: updateAppointmentDto.instrucciones,
      });
    }

    appointment.motivo = updateAppointmentDto.motivo ?? appointment.motivo;
    appointment.detalles =
      updateAppointmentDto.detalles ?? appointment.detalles;
    appointment.ubicacion =
      updateAppointmentDto.ubicacion ?? appointment.ubicacion;
    appointment.instrucciones =
      updateAppointmentDto.instrucciones ?? appointment.instrucciones;

    const savedAppointment =
      await this.appointmentsRepository.save(appointment);
    return this.buildMutationResponse(
      'Cita actualizada correctamente',
      savedAppointment.id,
    );
  }

  async confirm(id: number, currentUser: User) {
    const appointment = await this.findManagedAppointment(id, currentUser);
    this.assertStatusTransition(
      appointment.estado,
      AppointmentStatus.CONFIRMED,
    );

    await this.validateScheduleAvailability(
      appointment.professionalId,
      appointment.userId,
      appointment.fecha,
      this.normalizeTime(appointment.hora),
      appointment.id,
    );

    appointment.estado = AppointmentStatus.CONFIRMED;
    const savedAppointment =
      await this.appointmentsRepository.save(appointment);

    return this.buildMutationResponse(
      'Cita confirmada correctamente',
      savedAppointment.id,
    );
  }

  async cancel(
    id: number,
    changeStatusDto: ChangeAppointmentStatusDto,
    currentUser: User,
  ) {
    const appointment = await this.findManagedAppointment(id, currentUser);
    this.assertStatusTransition(
      appointment.estado,
      AppointmentStatus.CANCELLED,
    );

    appointment.estado = AppointmentStatus.CANCELLED;
    appointment.motivoCancelacion = changeStatusDto.motivo ?? null;
    const savedAppointment =
      await this.appointmentsRepository.save(appointment);

    return this.buildMutationResponse(
      'Cita cancelada correctamente',
      savedAppointment.id,
    );
  }

  async complete(id: number, currentUser: User) {
    const appointment = await this.findManagedAppointment(id, currentUser);
    this.assertStatusTransition(
      appointment.estado,
      AppointmentStatus.COMPLETED,
    );

    appointment.estado = AppointmentStatus.COMPLETED;
    const savedAppointment =
      await this.appointmentsRepository.save(appointment);

    return this.buildMutationResponse(
      'Cita completada correctamente',
      savedAppointment.id,
    );
  }

  async reject(
    id: number,
    changeStatusDto: ChangeAppointmentStatusDto,
    currentUser: User,
  ) {
    const appointment = await this.findManagedAppointment(id, currentUser);
    this.assertStatusTransition(appointment.estado, AppointmentStatus.REJECTED);

    appointment.estado = AppointmentStatus.REJECTED;
    appointment.motivoRechazo = changeStatusDto.motivo ?? null;
    const savedAppointment =
      await this.appointmentsRepository.save(appointment);

    return this.buildMutationResponse(
      'Cita rechazada correctamente',
      savedAppointment.id,
    );
  }

  async reschedule(
    id: number,
    reprogramAppointmentDto: ReprogramAppointmentDto,
    currentUser: User,
  ) {
    const appointment = await this.findManagedAppointment(id, currentUser);
    this.ensureAppointmentEditable(appointment);

    return this.applyReschedule(appointment, reprogramAppointmentDto);
  }

  async remove(id: number, currentUser: User) {
    const appointment = await this.findManagedAppointment(id, currentUser);
    await this.appointmentsRepository.remove(appointment);
    return { message: 'Cita eliminada correctamente', id };
  }

  private async applyReschedule(
    appointment: Appointment,
    payload: {
      fecha: string;
      hora: string;
      professionalId?: number;
      motivo?: string;
      appointmentReason?: string;
      detalles?: string;
      ubicacion?: string;
      instrucciones?: string;
    },
  ) {
    const nextProfessionalId =
      payload.professionalId ?? appointment.professionalId;
    const nextFecha = payload.fecha;
    const nextHora = payload.hora;

    const isSameSchedule =
      nextProfessionalId === appointment.professionalId &&
      nextFecha === appointment.fecha &&
      nextHora === this.normalizeTime(appointment.hora);

    if (isSameSchedule) {
      throw new BadRequestException(
        'La reprogramacion debe cambiar la fecha, la hora o el profesional',
      );
    }

    await this.ensureActiveProfessional(nextProfessionalId);
    await this.validateScheduleAvailability(
      nextProfessionalId,
      appointment.userId,
      nextFecha,
      nextHora,
      appointment.id,
    );

    appointment.fechaAnterior = appointment.fecha;
    appointment.horaAnterior = this.normalizeTime(appointment.hora);
    appointment.professionalId = nextProfessionalId;
    appointment.fecha = nextFecha;
    appointment.hora = nextHora;
    appointment.motivo = payload.appointmentReason ?? appointment.motivo;
    appointment.detalles = payload.detalles ?? appointment.detalles;
    appointment.ubicacion = payload.ubicacion ?? appointment.ubicacion;
    appointment.instrucciones =
      payload.instrucciones ?? appointment.instrucciones;

    if (
      appointment.estado === AppointmentStatus.CONFIRMED ||
      appointment.estado === AppointmentStatus.RESCHEDULED
    ) {
      appointment.estado = AppointmentStatus.RESCHEDULED;
    }

    const savedAppointment =
      await this.appointmentsRepository.save(appointment);
    return this.buildMutationResponse(
      'Cita reprogramada correctamente',
      savedAppointment.id,
    );
  }

  private async findManagedAppointment(id: number, currentUser: User) {
    const appointment = await this.findEntityById(id);
    this.assertAppointmentOwnership(currentUser, appointment);
    return appointment;
  }

  async findEntityById(id: number) {
    const appointment = await this.appointmentsRepository.findOne({
      where: { id },
    });

    if (!appointment) {
      throw new NotFoundException('Cita no encontrada');
    }

    return appointment;
  }

  private async buildMutationResponse(message: string, appointmentId: number) {
    const fullAppointment = await this.findEntityById(appointmentId);
    return {
      message,
      ...new AppointmentResponseDto(fullAppointment),
    };
  }

  private applyVisibilityScope(
    query: SelectQueryBuilder<Appointment>,
    currentUser: User,
  ) {
    if (currentUser.rol === UserRole.USER) {
      query.andWhere('appointment.userId = :currentUserId', {
        currentUserId: currentUser.id,
      });
    }
  }

  private async ensureActiveProfessional(professionalId: number) {
    const professional =
      await this.professionalsService.findOne(professionalId);
    if (!professional.activo) {
      throw new BadRequestException('El profesional no esta activo');
    }

    return professional;
  }

  private ensureCreateStartsPending(status?: AppointmentStatus) {
    if (status && status !== AppointmentStatus.PENDING) {
      throw new BadRequestException(
        'Las citas nuevas solo pueden crearse en estado PENDING',
      );
    }
  }

  private ensureAppointmentEditable(appointment: Appointment) {
    if (!EDITABLE_APPOINTMENT_STATUSES.includes(appointment.estado)) {
      throw new BadRequestException(
        'La cita no puede editarse en su estado actual',
      );
    }
  }

  private assertStatusTransition(
    currentStatus: AppointmentStatus,
    nextStatus: AppointmentStatus,
  ) {
    if (!STATUS_TRANSITIONS[currentStatus].includes(nextStatus)) {
      throw new BadRequestException(
        `No se permite cambiar la cita de ${currentStatus} a ${nextStatus}`,
      );
    }
  }

  private async validateScheduleAvailability(
    professionalId: number,
    userId: number,
    fecha: string,
    hora: string,
    ignoreAppointmentId?: number,
  ) {
    this.validateDateAndTime(fecha, hora);
    await this.validateProfessionalWorkingHours(professionalId, fecha, hora);
    await this.validateProfessionalConflict(
      professionalId,
      fecha,
      hora,
      ignoreAppointmentId,
    );
    await this.validateUserConflict(userId, fecha, hora, ignoreAppointmentId);
  }

  private validateDateAndTime(fecha: string, hora: string) {
    const appointmentDate = this.parseDate(fecha);
    const [hour, minute] = hora.split(':').map(Number);

    if (Number.isNaN(hour) || Number.isNaN(minute)) {
      throw new BadRequestException('La hora de la cita no es valida');
    }

    const appointmentDateTime = new Date(
      appointmentDate.getFullYear(),
      appointmentDate.getMonth(),
      appointmentDate.getDate(),
      hour,
      minute,
      0,
      0,
    );
    const now = new Date();

    if (appointmentDateTime.getTime() <= now.getTime()) {
      throw new BadRequestException(
        'No se pueden crear o mover citas en una fecha u hora pasada',
      );
    }
  }

  private async validateProfessionalWorkingHours(
    professionalId: number,
    fecha: string,
    hora: string,
  ) {
    const diaSemana = this.getDayOfWeek(fecha);
    const schedule = await this.schedulesRepository
      .createQueryBuilder('schedule')
      .where('schedule.professionalId = :professionalId', { professionalId })
      .andWhere('schedule.activo = :activo', { activo: true })
      .andWhere('schedule.diaSemana = :diaSemana', { diaSemana })
      .andWhere('schedule.horaInicio <= :hora', { hora })
      .andWhere('schedule.horaFin > :hora', { hora })
      .getOne();

    if (!schedule) {
      throw new BadRequestException(
        'El profesional no tiene disponibilidad configurada para ese horario',
      );
    }
  }

  private async validateProfessionalConflict(
    professionalId: number,
    fecha: string,
    hora: string,
    ignoreAppointmentId?: number,
  ) {
    const query = this.appointmentsRepository
      .createQueryBuilder('appointment')
      .where('appointment.professionalId = :professionalId', { professionalId })
      .andWhere('appointment.fecha = :fecha', { fecha })
      .andWhere('appointment.hora = :hora', { hora })
      .andWhere('appointment.estado IN (:...statuses)', {
        statuses: ACTIVE_APPOINTMENT_STATUSES,
      });

    if (ignoreAppointmentId) {
      query.andWhere('appointment.id != :ignoreAppointmentId', {
        ignoreAppointmentId,
      });
    }

    const conflict = await query.getOne();
    if (conflict) {
      throw new ConflictException(
        'El profesional ya tiene una cita activa en esa fecha y hora',
      );
    }
  }

  private async validateUserConflict(
    userId: number,
    fecha: string,
    hora: string,
    ignoreAppointmentId?: number,
  ) {
    const query = this.appointmentsRepository
      .createQueryBuilder('appointment')
      .where('appointment.userId = :userId', { userId })
      .andWhere('appointment.fecha = :fecha', { fecha })
      .andWhere('appointment.hora = :hora', { hora })
      .andWhere('appointment.estado IN (:...statuses)', {
        statuses: ACTIVE_APPOINTMENT_STATUSES,
      });

    if (ignoreAppointmentId) {
      query.andWhere('appointment.id != :ignoreAppointmentId', {
        ignoreAppointmentId,
      });
    }

    const conflict = await query.getOne();
    if (conflict) {
      throw new ConflictException(
        'El usuario ya tiene una cita activa en esa fecha y hora',
      );
    }
  }

  private validateDateRange(fechaInicio?: string, fechaFin?: string) {
    if ((fechaInicio && !fechaFin) || (!fechaInicio && fechaFin)) {
      throw new BadRequestException(
        'Para filtrar por rango debe enviar fechaInicio y fechaFin',
      );
    }

    if (!fechaInicio || !fechaFin) {
      return;
    }

    const start = this.parseDate(fechaInicio);
    const end = this.parseDate(fechaFin);

    if (start.getTime() > end.getTime()) {
      throw new BadRequestException(
        'La fechaInicio no puede ser mayor que la fechaFin',
      );
    }
  }

  private assertUserScope(currentUser: User, targetUserId: number) {
    if (currentUser.rol === UserRole.USER && currentUser.id !== targetUserId) {
      throw new ForbiddenException(
        'No puede operar sobre citas de otro usuario',
      );
    }
  }

  private assertAppointmentOwnership(
    currentUser: User,
    appointment: Appointment,
  ) {
    if (
      currentUser.rol === UserRole.USER &&
      appointment.userId !== currentUser.id
    ) {
      throw new ForbiddenException('No puede acceder a una cita ajena');
    }
  }

  private hasAtLeastOneValue(payload: object) {
    return Object.values(payload).some((value) => value !== undefined);
  }

  private parseDate(fecha: string) {
    const [year, month, day] = fecha.split('-').map(Number);
    const date = new Date(year, month - 1, day);

    if (
      Number.isNaN(date.getTime()) ||
      date.getFullYear() !== year ||
      date.getMonth() !== month - 1 ||
      date.getDate() !== day
    ) {
      throw new BadRequestException('La fecha de la cita no es valida');
    }

    return date;
  }

  private getDayOfWeek(fecha: string) {
    const [year, month, day] = fecha.split('-').map(Number);
    return new Date(Date.UTC(year, month - 1, day)).getUTCDay();
  }

  private normalizeTime(value: string) {
    return value.slice(0, 5);
  }
}
