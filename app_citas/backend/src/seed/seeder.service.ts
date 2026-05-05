import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AppointmentType } from '../appointment-types/entities/appointment-type.entity';
import { ProfessionalSchedule } from '../professional-schedules/entities/professional-schedule.entity';
import { Professional } from '../professionals/entities/professional.entity';

type BaseProfessional = Pick<
  Professional,
  | 'nombre'
  | 'apellido'
  | 'especialidad'
  | 'descripcion'
  | 'email'
  | 'telefono'
  | 'activo'
>;

type BaseAppointmentType = Pick<
  AppointmentType,
  'nombre' | 'descripcion' | 'duracionMinutos' | 'activo'
>;

type BaseSchedule = Pick<
  ProfessionalSchedule,
  'professionalId' | 'diaSemana' | 'horaInicio' | 'horaFin' | 'activo'
>;

@Injectable()
export class SeederService implements OnModuleInit {
  private readonly logger = new Logger(SeederService.name);

  constructor(
    @InjectRepository(Professional)
    private readonly professionalsRepository: Repository<Professional>,
    @InjectRepository(AppointmentType)
    private readonly appointmentTypesRepository: Repository<AppointmentType>,
    @InjectRepository(ProfessionalSchedule)
    private readonly schedulesRepository: Repository<ProfessionalSchedule>,
  ) {}

  async onModuleInit(): Promise<void> {
    await this.seedBaseData();
  }

  private async seedBaseData(): Promise<void> {
    this.logger.log('Validando datos base de la aplicacion...');

    const professionals = await this.seedProfessionals();
    await this.seedAppointmentTypes();
    await this.seedProfessionalSchedules(professionals);

    this.logger.log('Validacion de datos base finalizada.');
  }

  private async seedProfessionals(): Promise<Professional[]> {
    const baseProfessionals: BaseProfessional[] = [
      {
        nombre: 'María Fernanda',
        apellido: 'López',
        especialidad: 'Medicina General',
        descripcion: 'Profesional en Medicina General.',
        email: 'maria.lopez@citas.com',
        telefono: '8888-1111',
        activo: true,
      },
      {
        nombre: 'Carlos',
        apellido: 'Ramírez Soto',
        especialidad: 'Psicología',
        descripcion: 'Profesional en Psicología.',
        email: 'carlos.ramirez@citas.com',
        telefono: '8888-2222',
        activo: true,
      },
      {
        nombre: 'Andrea',
        apellido: 'Vargas Mora',
        especialidad: 'Nutrición',
        descripcion: 'Profesional en Nutrición.',
        email: 'andrea.vargas@citas.com',
        telefono: '8888-3333',
        activo: true,
      },
      {
        nombre: 'José Pablo',
        apellido: 'Herrera',
        especialidad: 'Odontología',
        descripcion: 'Profesional en Odontología.',
        email: 'jose.herrera@citas.com',
        telefono: '8888-4444',
        activo: true,
      },
    ];

    const seededProfessionals: Professional[] = [];

    for (const baseProfessional of baseProfessionals) {
      const existingProfessional = await this.professionalsRepository.findOne({
        where: { email: baseProfessional.email },
      });

      if (existingProfessional) {
        this.logger.log(`Profesional ya existente: ${baseProfessional.email}`);
        seededProfessionals.push(existingProfessional);
        continue;
      }

      const professional =
        this.professionalsRepository.create(baseProfessional);
      const savedProfessional =
        await this.professionalsRepository.save(professional);

      this.logger.log(`Profesional insertado: ${savedProfessional.email}`);
      seededProfessionals.push(savedProfessional);
    }

    return seededProfessionals;
  }

  private async seedAppointmentTypes(): Promise<void> {
    const baseAppointmentTypes: BaseAppointmentType[] = [
      {
        nombre: 'Consulta general',
        descripcion: 'Cita para revisión general del paciente.',
        duracionMinutos: 30,
        activo: true,
      },
      {
        nombre: 'Consulta de seguimiento',
        descripcion: 'Cita para dar seguimiento a un caso anterior.',
        duracionMinutos: 30,
        activo: true,
      },
      {
        nombre: 'Evaluación inicial',
        descripcion: 'Primera cita para conocer el caso del paciente.',
        duracionMinutos: 45,
        activo: true,
      },
      {
        nombre: 'Asesoría especializada',
        descripcion: 'Cita con un profesional según el área seleccionada.',
        duracionMinutos: 60,
        activo: true,
      },
    ];

    for (const baseAppointmentType of baseAppointmentTypes) {
      const existingAppointmentType =
        await this.appointmentTypesRepository.findOne({
          where: { nombre: baseAppointmentType.nombre },
        });

      if (existingAppointmentType) {
        this.logger.log(
          `Tipo de cita ya existente: ${baseAppointmentType.nombre}`,
        );
        continue;
      }

      const appointmentType =
        this.appointmentTypesRepository.create(baseAppointmentType);
      await this.appointmentTypesRepository.save(appointmentType);

      this.logger.log(`Tipo de cita insertado: ${baseAppointmentType.nombre}`);
    }
  }

  private async seedProfessionalSchedules(
    professionals: Professional[],
  ): Promise<void> {
    const professionalByEmail = new Map(
      professionals.map((professional) => [professional.email, professional]),
    );

    const schedulesByProfessionalEmail = [
      {
        email: 'maria.lopez@citas.com',
        schedules: [
          { diaSemana: 1, horaInicio: '08:00:00', horaFin: '12:00:00' },
          { diaSemana: 3, horaInicio: '13:00:00', horaFin: '17:00:00' },
        ],
      },
      {
        email: 'carlos.ramirez@citas.com',
        schedules: [
          { diaSemana: 2, horaInicio: '09:00:00', horaFin: '12:00:00' },
          { diaSemana: 4, horaInicio: '13:00:00', horaFin: '16:00:00' },
        ],
      },
      {
        email: 'andrea.vargas@citas.com',
        schedules: [
          { diaSemana: 1, horaInicio: '10:00:00', horaFin: '15:00:00' },
        ],
      },
      {
        email: 'jose.herrera@citas.com',
        schedules: [
          { diaSemana: 5, horaInicio: '08:00:00', horaFin: '12:00:00' },
        ],
      },
    ];

    for (const professionalSchedules of schedulesByProfessionalEmail) {
      const professional = professionalByEmail.get(professionalSchedules.email);

      if (!professional) {
        this.logger.warn(
          `No se encontraron horarios para insertar: ${professionalSchedules.email}`,
        );
        continue;
      }

      for (const schedule of professionalSchedules.schedules) {
        const baseSchedule: BaseSchedule = {
          professionalId: professional.id,
          diaSemana: schedule.diaSemana,
          horaInicio: schedule.horaInicio,
          horaFin: schedule.horaFin,
          activo: true,
        };

        const existingSchedule = await this.schedulesRepository.findOne({
          where: baseSchedule,
        });

        if (existingSchedule) {
          this.logger.log(
            `Horario ya existente: ${professional.email} dia ${schedule.diaSemana} ${schedule.horaInicio}-${schedule.horaFin}`,
          );
          continue;
        }

        const professionalSchedule =
          this.schedulesRepository.create(baseSchedule);
        await this.schedulesRepository.save(professionalSchedule);

        this.logger.log(
          `Horario insertado: ${professional.email} dia ${schedule.diaSemana} ${schedule.horaInicio}-${schedule.horaFin}`,
        );
      }
    }
  }
}
