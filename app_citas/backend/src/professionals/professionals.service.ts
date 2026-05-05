import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Not, Repository } from 'typeorm';
import { AppointmentStatus } from '../common/enums/appointment-status.enum';
import { Appointment } from '../appointments/entities/appointment.entity';
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
      (professional) => !unavailableIds.has(professional.id),
    );
  }
}
