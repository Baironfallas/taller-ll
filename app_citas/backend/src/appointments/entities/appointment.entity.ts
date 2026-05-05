import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { AppointmentStatus } from '../../common/enums/appointment-status.enum';
import { User } from '../../users/entities/user.entity';
import { Professional } from '../../professionals/entities/professional.entity';

@Entity('appointments')
export class Appointment {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userId: number;

  @Column()
  professionalId: number;

  @Column({ type: 'date' })
  fecha: string;

  @Column({ type: 'time' })
  hora: string;

  @Column({ length: 180 })
  motivo: string;

  @Column({ type: 'text' })
  detalles: string;

  @Column({
    type: 'enum',
    enum: AppointmentStatus,
    default: AppointmentStatus.PENDING,
  })
  estado: AppointmentStatus;

  @Column({ length: 180 })
  ubicacion: string;

  @Column({ type: 'text' })
  instrucciones: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @ManyToOne(() => User, (user) => user.appointments, { eager: true })
  @JoinColumn({ name: 'userId' })
  user: User;

  @ManyToOne(() => Professional, (professional) => professional.appointments, {
    eager: true,
  })
  @JoinColumn({ name: 'professionalId' })
  professional: Professional;
}
