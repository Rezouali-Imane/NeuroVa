import prisma from "../../infrastructure/database/prisma.client.js";
import type {
  CreateRoomDTO,
  JoinRoomDTO,
  LeaveRoomDTO,
} from "../dtos/StudyRoom.dto.js";

export const StudyRoomRepository = {
  async create(data: CreateRoomDTO) {
    return await prisma.$transaction(async (tx) => {
      //  Create StudyRoom
      const room = await tx.studyroom.create({
        data: {
          roomname: data.roomname,
          sessionduration: data.sessionduration,
          isactive: false,
        },
      });

      //  Create Study Room Owner
      await tx.studyroommember.create({
        data: {
          userid: data.ownerid,
          roomid: room.roomid,
          isowner: true,
        },
      });

      // Create initial Focus Session
      await tx.focussession.create({
        data: {
          userid: data.ownerid,
          roomid: room.roomid,
          starttime: null,
          endtime: null,
          status: "SCHEDULED",
        },
      });

      return room;
    });
  },

  async join(data: JoinRoomDTO, starttime: Date | null, endtime: Date | null) {
    return await prisma.$transaction(async (tx) => {
      const member = await tx.studyroommember.create({
        data: {
          userid: data.userid,
          roomid: data.roomid,
          isowner: false,
        },
        include: {
          users: {
            select: { username: true },
          },
        },
      });

      await tx.focussession.create({
        data: {
          userid: data.userid,
          roomid: data.roomid,
          starttime: starttime,
          endtime: endtime,
          status: "SCHEDULED",
        },
      });

      return member;
    });
  },

  async leave(data: LeaveRoomDTO) {
    return await prisma.studyroommember.update({
      where: {
        userid_roomid: {
          userid: data.userid,
          roomid: data.roomid,
        },
      },
      data: {
        leftat: new Date(),
      },
      include: {
        users: {
          select: { username: true },
        },
      },
    });
  },

  async closeRoom(roomid: string) {
    const now = new Date();
    return await prisma.$transaction([
      prisma.studyroom.update({
        where: { roomid },
        data: { isactive: false },
      }),
      prisma.focussession.updateMany({
        where: { roomid, status: "SCHEDULED" },
        data: { status: "CANCELED" },
      }),
      prisma.studyroommember.updateMany({
        where: {
          roomid,
          leftat: null,
        },
        data: {
          leftat: now,
        },
      }),
    ]);
  },

  async findById(roomid: string) {
    return await prisma.studyroom.findUnique({
      where: { roomid },
      include: {
        studyroommember: {
          include: {
            users: {
              select: { username: true },
            },
          },
        },
        focussession: true,
      },
    });
  },
};
