import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Not, Repository } from 'typeorm';
import { AppointmentStatus } from '../common/enums/appointment-status.enum';
import { Appointment } from '../appointments/entities/appointment.entity';
import { ProfessionalSchedule } from '../professional-schedules/entities/professional-schedule.entity';
import { CreateProfessionalDto } from './dto/create-professional.dto';
import { UpdateProfessionalDto } from './dto/update-professional.dto';
import { Professional } from './entities/professional.entity';

@Injectable()
export class ProfessionalsService {
  constructor(
    @InjectRepository(Professional)
    private readonly professionalsRepository: Repository<Professional>,
    @InjectRepository(Appointment)
    private readonly appointmentsRepository: Repository<Appointment>,
    @InjectRepository(ProfessionalSchedule)
    private readonly schedulesRepository: Repository<ProfessionalSchedule>,
  ) {}

  async create(createProfessionalDto: CreateProfessionalDto) {
    const existingProfessional = await this.professionalsRepository.findOne({
      where: { email: createProfessionalDto.email },
    });
    if (existingProfessional) {
      throw new ConflictException('El correo ya pertenece a un profesional');
    }

    const professional = this.professionalsRepository.create(
      createProfessionalDto,
    );
    return this.professionalsRepository.save(professional);
  }

  findAll() {
    return this.professionalsRepository.find({ where: { activo: true } });
  }

  async findOne(id: number) {
    const professional = await this.professionalsRepository.findOne({
      where: { id },
    });
    if (!professional) {
      throw new NotFoundException('Profesional no encontrado');
    }
    return professional;
  }

  async update(id: number, updateProfessionalDto: UpdateProfessionalDto) {
    const professional = await this.findOne(id);
    if (
      updateProfessionalDto.email &&
      updateProfessionalDto.email !== professional.email
    ) {
      const existingProfessional = await this.professionalsRepository.findOne({
        where: { email: updateProfessionalDto.email, id: Not(id) },
      });
      if (existingProfessional) {
        throw new ConflictException('El correo ya pertenece a un profesional');
      }
    }

    Object.assign(professional, updateProfessionalDto);
    return this.professionalsRepository.save(professional);
  }

  async deactivate(id: number) {
    const professional = await this.findOne(id);
    professional.activo = false;
    return this.professionalsRepository.save(professional);
  }

  async findAvailable(fecha: string, hora: string) {
    const professionals = await this.professionalsRepository.find({
      where: { activo: true },
    });
    const diaSemana = this.getDiaSemana(fecha);
    const availableSchedules = await this.schedulesRepository
      .createQueryBuilder('schedule')
      .where('schedule.activo = :activo', { activo: true })
      .andWhere('schedule.diaSemana = :diaSemana', { diaSemana })
      .andWhere('schedule.horaInicio <= :hora', { hora })
      .andWhere('schedule.horaFin > :hora', { hora })
      .getMany();
    const scheduledIds = new Set(
      availableSchedules.map((schedule) => schedule.professionalId),
    );
    const unavailableAppointments = await this.appointmentsRepository.find({
      where: [
        { fecha, hora, estado: AppointmentStatus.PENDING },
        { fecha, hora, estado: AppointmentStatus.CONFIRMED },
      ],
    });
    const unavailableIds = new Set(
      unavailableAppointments.map((appointment) => appointment.professionalId),
    );
    return professionals.filter(
      (professional) =>
        scheduledIds.has(professional.id) &&
        !unavailableIds.has(professional.id),
    );
  }

  private getDiaSemana(fecha: string): number {
    const [year, month, day] = fecha.split('-').map(Number);
    return new Date(Date.UTC(year, month - 1, day)).getUTCDay();
  }
}
