import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Professional } from '../../professionals/entities/professional.entity';

@Entity('professional_schedules')
@Index(['professionalId', 'diaSemana', 'horaInicio', 'horaFin'], {
  unique: true,
})
export class ProfessionalSchedule {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'profesional_id' })
  professionalId: number;

  @Column({ name: 'dia_semana' })
  diaSemana: number;

  @Column({ name: 'hora_inicio', type: 'time' })
  horaInicio: string;

  @Column({ name: 'hora_fin', type: 'time' })
  horaFin: string;

  @Column({ default: true })
  activo: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @ManyToOne(() => Professional, (professional) => professional.schedules, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'profesional_id' })
  professional: Professional;
}
