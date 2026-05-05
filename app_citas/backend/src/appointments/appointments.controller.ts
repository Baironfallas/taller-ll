import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { AppointmentsService } from './appointments.service';
import { CreateAppointmentDto } from './dto/create-appointment.dto';
import { FilterAppointmentsDto } from './dto/filter-appointments.dto';
import { UpdateAppointmentDto } from './dto/update-appointment.dto';

@UseGuards(JwtAuthGuard)
@Controller('appointments')
export class AppointmentsController {
  constructor(private readonly appointmentsService: AppointmentsService) {}

  @Post()
  create(@Body() createAppointmentDto: CreateAppointmentDto) {
    return this.appointmentsService.create(createAppointmentDto);
  }

  @Get()
  findAll(@Query() filters: FilterAppointmentsDto) {
    return this.appointmentsService.findAll(filters);
  }

  @Get('user/:userId')
  findByUser(@Param('userId', ParseIntPipe) userId: number) {
    return this.appointmentsService.findByUser(userId);
  }

  @Get('professional/:professionalId')
  findByProfessional(
    @Param('professionalId', ParseIntPipe) professionalId: number,
  ) {
    return this.appointmentsService.findByProfessional(professionalId);
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.appointmentsService.findOne(id);
  }

  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateAppointmentDto: UpdateAppointmentDto,
  ) {
    return this.appointmentsService.update(id, updateAppointmentDto);
  }

  @Patch(':id/confirm')
  confirm(@Param('id', ParseIntPipe) id: number) {
    return this.appointmentsService.confirm(id);
  }

  @Patch(':id/cancel')
  cancel(@Param('id', ParseIntPipe) id: number) {
    return this.appointmentsService.cancel(id);
  }

  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.appointmentsService.remove(id);
  }
}
