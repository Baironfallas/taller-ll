import {
  Body,
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CreateProfessionalDto } from './dto/create-professional.dto';
import { UpdateProfessionalDto } from './dto/update-professional.dto';
import { ProfessionalsService } from './professionals.service';

@UseGuards(JwtAuthGuard)
@Controller('professionals')
export class ProfessionalsController {
  constructor(private readonly professionalsService: ProfessionalsService) {}

  @Post()
  create(@Body() createProfessionalDto: CreateProfessionalDto) {
    return this.professionalsService.create(createProfessionalDto);
  }

  @Get('available')
  findAvailable(@Query('fecha') fecha: string, @Query('hora') hora: string) {
    return this.professionalsService.findAvailable(fecha, hora);
  }

  @Get()
  findAll() {
    return this.professionalsService.findAll();
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.professionalsService.findOne(id);
  }

  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateProfessionalDto: UpdateProfessionalDto,
  ) {
    return this.professionalsService.update(id, updateProfessionalDto);
  }

  @Patch(':id/deactivate')
  deactivate(@Param('id', ParseIntPipe) id: number) {
    return this.professionalsService.deactivate(id);
  }
}
