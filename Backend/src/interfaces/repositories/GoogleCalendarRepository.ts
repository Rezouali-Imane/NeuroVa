import prisma from "../../infrastructure/database/prisma.client.js";
import type {
  ConnectCalendarDTO,
  DisconnectCalendarDTO,
  SaveGoogleEventDTO,
  SaveTokenDTO,
  UpdateaccessTokenDTO,
} from "../dtos/GoogleCalendar.dto.js";

export const GoogleCalendarRepository = {
  async connectCalendar(data: SaveTokenDTO) {
    return prisma.$transaction(async (tx) => {
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
    return prisma.$transaction(async (tx) => {
      await tx.googlecalendarsync.deleteMany({
        where: {userid: data.userid},
      });

      await tx.googlecalendartoken.deleteMany({
        where: {userid: data.userid},
      });

      await tx.task.updateMany({
        where: {userid: data.userid},
        data: {
          googleeventid: null,
          syncedwithgoogle: false,
        },
      });
    });
  },



  async updateAccessToken(data: UpdateaccessTokenDTO) {
    return prisma.googlecalendartoken.updateMany({
      where: {userid: data.userid},
      data: {
        accesstoken: data.accesstoken,
        expiresat: data.expiresat,
      },
    });
  },

  async getAccessToken(userid: string) {
  return prisma.googlecalendartoken.findFirst({
    where: {userid},
  });
},


async saveGoogleEventId(data: SaveGoogleEventDTO) {
  return prisma.task.update({
    where: {taskid: data.taskid},
    data: {
      googleeventid: data.googleeventid,
      syncedwithgoogle: true,
    },
  });
},


async createTaskFromGoogleEvent(data: {
  userid: string;
  title: string;
   listid: string; 
  description: string;
  deadline: Date; 
  googleeventid: string;
}) {
  return prisma.task.create({
    data: {
      userid: data.userid,
      title: data.title,
      listid: data.listid,
      description: data.description,
      deadline: data.deadline,
      googleeventid: data.googleeventid,
      syncedwithgoogle: true,
    },
  });
},

async removeGoogleEventFromTask(taskid: string) {
  return prisma.task.update({
    where: {taskid},
    data: {
      googleeventid: null,
      syncedwithgoogle: false,
    },
  });
},

  async getSync(userid: string) {
    return prisma.googlecalendarsync.findFirst({
      where: {userid},
    });
  },

  async getUnsyncedTasks(userid: string) {
    return prisma.task.findMany({
      where: {userid, syncedwithgoogle: false},
    });
  },

  async updateLastSynced(userid: string) {
    return prisma.googlecalendarsync.updateMany({
      where: {userid},
      data: {lastsyncedat: new Date()},
    });
  },
};
