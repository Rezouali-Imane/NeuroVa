import prisma from '../../infrastructure/database/prisma.client.js';
import type { CreateDisciplineAlertDTO } from '../../interfaces/dtos/DigitalDiscipline.dto.js';

export const TriggerAlert = async (userid: string, data: CreateDisciplineAlertDTO) => {
  return prisma.disciplinealert.create({
    data: {
      userid,
      appname: data.appname ?? null,
      identifier: data.identifier ?? null,
      alerttype: data.alerttype,
      message: data.message,
      isread: data.isread ?? false,
    },
  });
};
