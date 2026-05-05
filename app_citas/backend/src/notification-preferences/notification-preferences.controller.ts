import {
  Body,
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CreateNotificationPreferenceDto } from './dto/create-notification-preference.dto';
import { UpdateNotificationPreferenceDto } from './dto/update-notification-preference.dto';
import { NotificationPreferencesService } from './notification-preferences.service';

@UseGuards(JwtAuthGuard)
@Controller('notification-preferences')
export class NotificationPreferencesController {
  constructor(
    private readonly notificationPreferencesService: NotificationPreferencesService,
  ) {}

  @Post()
  create(@Body() createPreferenceDto: CreateNotificationPreferenceDto) {
    return this.notificationPreferencesService.create(createPreferenceDto);
  }

  @Get('user/:userId')
  findByUser(@Param('userId', ParseIntPipe) userId: number) {
    return this.notificationPreferencesService.findByUser(userId);
  }

  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updatePreferenceDto: UpdateNotificationPreferenceDto,
  ) {
    return this.notificationPreferencesService.update(id, updatePreferenceDto);
  }
}
