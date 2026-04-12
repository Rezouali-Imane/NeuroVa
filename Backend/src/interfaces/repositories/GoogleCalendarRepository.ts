import prisma from "../../infrastructure/database/prisma.client.js";
import type { ConnectCalendarDTO, DisconnectCalendarDTO } from "../dtos/GoogleCalendar.dto.js";

export const GoogleCalendarRepository = {

   async connectCalendar(data: ConnectCalendarDTO) {
   return await prisma.$transaction(async (tx) => {

    const token = await tx.googlecalendartoken.create({
      data: {
        userid: data.userid,
        accesstoken: data.accesstoken,
        refreshtoken: data.refreshtoken,
        expiresat: data.expiresat,
      },
    });

    await tx.googlecalendarsync.create({
      data: {
        userid: data.userid,
        tokenid: token.tokenid, 
        googlecalendarid: "primary", 
        isenabled: true,
        lastsyncedat: new Date(),
      },
    });

    return token;
  });
},

async disconnectCalendar(data: DisconnectCalendarDTO) {
  return await prisma.$transaction(async (tx) => {
    
    await tx.googlecalendarsync.deleteMany({
      where: { userid: data.userid },
    });

    await tx.googlecalendartoken.deleteMany({
      where: { userid: data.userid },
    });

    await tx.task.updateMany({
      where: { userid: data.userid },
      data: {
        googleeventid: null,
        syncedwithgoogle: false,
      },
    });
  });
}


}