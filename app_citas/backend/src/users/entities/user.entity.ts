import {
  Column,
  CreateDateColumn,
  Entity,
  OneToMany,
  OneToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { UserRole } from '../../common/enums/user-role.enum';
import { Appointment } from '../../appointments/entities/appointment.entity';
import { NotificationPreference } from '../../notification-preferences/entities/notification-preference.entity';
import { Notification } from '../../notifications/entities/notification.entity';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 100 })
  nombre: string;

  @Column({ length: 100 })
  apellido: string;

  @Column({ unique: true, length: 150 })
  email: string;

  @Column()
  password: string;

  @Column({ length: 30 })
  telefono: string;

  @Column({ type: 'enum', enum: UserRole, default: UserRole.USER })
  rol: UserRole;

  @Column({ default: true })
  activo: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @OneToMany(() => Appointment, (appointment) => appointment.user)
  appointments: Appointment[];

  @OneToOne(() => NotificationPreference, (preference) => preference.user)
  notificationPreference: NotificationPreference;

  @OneToMany(() => Notification, (notification) => notification.user)
  notifications: Notification[];
}
