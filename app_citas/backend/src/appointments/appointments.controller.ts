import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseEnumPipe,
  ParseIntPipe,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { AppointmentStatus } from '../common/enums/appointment-status.enum';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { User } from '../users/entities/user.entity';
import { AppointmentsService } from './appointments.service';
import { ChangeAppointmentStatusDto } from './dto/change-appointment-status.dto';
import { CreateAppointmentDto } from './dto/create-appointment.dto';
import { FilterAppointmentsDto } from './dto/filter-appointments.dto';
import { ReprogramAppointmentDto } from './dto/reprogram-appointment.dto';
import { UpdateAppointmentDto } from './dto/update-appointment.dto';

@UseGuards(JwtAuthGuard)
@Controller('appointments')
export class AppointmentsController {
  constructor(private readonly appointmentsService: AppointmentsService) {}

  @Post()
  create(
    @Body() createAppointmentDto: CreateAppointmentDto,
    @CurrentUser() currentUser: User,
  ) {
    return this.appointmentsService.create(createAppointmentDto, currentUser);
  }

  @Get()
  findAll(
    @Query() filters: FilterAppointmentsDto,
    @CurrentUser() currentUser: User,
  ) {
    return this.appointmentsService.findAll(filters, currentUser);
  }

  @Get('user/:userId')
  findByUser(
    @Param('userId', ParseIntPipe) userId: number,
    @CurrentUser() currentUser: User,
  ) {
    return this.appointmentsService.findByUser(userId, currentUser);
  }

  @Get('professional/:professionalId')
  findByProfessional(
    @Param('professionalId', ParseIntPipe) professionalId: number,
    @CurrentUser() currentUser: User,
  ) {
    return this.appointmentsService.findByProfessional(
      professionalId,
      currentUser,
    );
  }

  @Get('status/:estado')
  findByStatus(
    @Param('estado', new ParseEnumPipe(AppointmentStatus))
    estado: AppointmentStatus,
    @CurrentUser() currentUser: User,
  ) {
    return this.appointmentsService.findByStatus(estado, currentUser);
  }

  @Get('range')
  findByDateRange(
    @Query('fechaInicio') fechaInicio: string,
    @Query('fechaFin') fechaFin: string,
    @CurrentUser() currentUser: User,
  ) {
    return this.appointmentsService.findByDateRange(
      fechaInicio,
      fechaFin,
      currentUser,
    );
  }

  @Get(':id')
  findOne(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser() currentUser: User,
  ) {
    return this.appointmentsService.findOne(id, currentUser);
  }

  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateAppointmentDto: UpdateAppointmentDto,
    @CurrentUser() currentUser: User,
  ) {
    return this.appointmentsService.update(
      id,
      updateAppointmentDto,
      currentUser,
    );
  }

  @Patch(':id/confirm')
  confirm(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser() currentUser: User,
  ) {
    return this.appointmentsService.confirm(id, currentUser);
  }

  @Patch(':id/cancel')
  cancel(
    @Param('id', ParseIntPipe) id: number,
    @Body() changeStatusDto: ChangeAppointmentStatusDto,
    @CurrentUser() currentUser: User,
  ) {
    return this.appointmentsService.cancel(id, changeStatusDto, currentUser);
  }

  @Patch(':id/complete')
  complete(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser() currentUser: User,
  ) {
    return this.appointmentsService.complete(id, currentUser);
  }

  @Patch(':id/reject')
  reject(
    @Param('id', ParseIntPipe) id: number,
    @Body() changeStatusDto: ChangeAppointmentStatusDto,
    @CurrentUser() currentUser: User,
  ) {
    return this.appointmentsService.reject(id, changeStatusDto, currentUser);
  }

  @Patch(':id/reschedule')
  reschedule(
    @Param('id', ParseIntPipe) id: number,
    @Body() reprogramAppointmentDto: ReprogramAppointmentDto,
    @CurrentUser() currentUser: User,
  ) {
    return this.appointmentsService.reschedule(
      id,
      reprogramAppointmentDto,
      currentUser,
    );
  }

  @Delete(':id')
  remove(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser() currentUser: User,
  ) {
    return this.appointmentsService.remove(id, currentUser);
  }
}
