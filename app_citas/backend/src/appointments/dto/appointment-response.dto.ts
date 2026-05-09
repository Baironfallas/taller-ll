import { AppointmentStatus } from '../../common/enums/appointment-status.enum';
import { Appointment } from '../entities/appointment.entity';

class AppointmentUserSummaryDto {
  id: number;
  nombre: string;
  apellido: string;

  constructor(appointment: Appointment) {
    this.id = appointment.user.id;
    this.nombre = appointment.user.nombre;
    this.apellido = appointment.user.apellido;
  }
}

class AppointmentProfessionalSummaryDto {
  id: number;
  nombre: string;
  apellido: string;
  especialidad: string;

  constructor(appointment: Appointment) {
    this.id = appointment.professional.id;
    this.nombre = appointment.professional.nombre;
    this.apellido = appointment.professional.apellido;
    this.especialidad = appointment.professional.especialidad;
  }
}

export class AppointmentResponseDto {
  id: number;
  userId: number;
  professionalId: number;
  fecha: string;
  hora: string;
  motivo: string;
  detalles: string;
  estado: AppointmentStatus;
  fechaAnterior: string | null;
  horaAnterior: string | null;
  ubicacion: string;
  instrucciones: string;
  motivoCancelacion: string | null;
  motivoRechazo: string | null;
  createdAt: Date;
  updatedAt: Date;
  user: AppointmentUserSummaryDto;
  professional: AppointmentProfessionalSummaryDto;

  constructor(appointment: Appointment) {
    this.id = appointment.id;
    this.userId = appointment.userId;
    this.professionalId = appointment.professionalId;
    this.fecha = appointment.fecha;
    this.hora = AppointmentResponseDto.normalizeTime(appointment.hora);
    this.motivo = appointment.motivo;
    this.detalles = appointment.detalles;
    this.estado = appointment.estado;
    this.fechaAnterior = appointment.fechaAnterior;
    this.horaAnterior = appointment.horaAnterior
      ? AppointmentResponseDto.normalizeTime(appointment.horaAnterior)
      : null;
    this.ubicacion = appointment.ubicacion;
    this.instrucciones = appointment.instrucciones;
    this.motivoCancelacion = appointment.motivoCancelacion;
    this.motivoRechazo = appointment.motivoRechazo;
    this.createdAt = appointment.createdAt;
    this.updatedAt = appointment.updatedAt;
    this.user = new AppointmentUserSummaryDto(appointment);
    this.professional = new AppointmentProfessionalSummaryDto(appointment);
  }

  private static normalizeTime(value: string): string {
    return value.slice(0, 5);
  }
}
