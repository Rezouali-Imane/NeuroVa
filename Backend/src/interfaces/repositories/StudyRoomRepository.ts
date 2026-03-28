import prisma from "../../infrastructure/database/prisma.client.js";
import type {
  CreateRoomDTO,
  JoinRoomDTO,
  LeaveRoomDTO,
} from "../dtos/StudyRoom.dto.js";
import { randomBytes } from "crypto";

const generateRoomCode = (): string => {
  return randomBytes(3).toString("hex").toUpperCase();
}

export const StudyRoomRepository = {
  async create(data: CreateRoomDTO) {
    return await prisma.$transaction(async (tx) => {
      const roomcode =  generateRoomCode();

      //  Create StudyRoom
      const room = await tx.studyroom.create({
        data: {
          roomname: data.roomname,
          sessionduration: data.sessionduration,
          roomcode,
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
          status: "SCHEDULED",
        },
      });

      return room;
    });
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

  async findByCode(roomcode: string) {
    return await prisma.studyroom.findUnique({
      where: { roomcode },
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

  async join(data: JoinRoomDTO, roomid: string) {
    return await prisma.studyroommember.create({
      data: {
        userid: data.userid,
        roomid,
        isowner: false,
      },
      include: {
        users: {
          select: { username: true },
        },
      },
    });
  },

  async leave(roomid: string, userid: string) {
    return await prisma.studyroommember.update({
      where: {
        userid_roomid: { userid, roomid },
      },
      data: { leftat: new Date() },
      include: {
        users: { select: { username: true },},
      },
    });
  },

  async startSession(roomid: string) {
    return await prisma.$transaction([
      prisma.studyroom.update({
        where: {roomid},
        data: {isactive: true},
      }),
      prisma.focussession.updateMany({
        where: { roomid, status: "SCHEDULED" },
        data: { status: "ACTIVE", starttime: new Date() },
      }),
    ]);
  },

  async closeRoom(roomid: string) {
    const now = new Date();
    return await prisma.$transaction([
      prisma.studyroom.update({
        where: { roomid },
        data: { isactive: false },
      }),
      prisma.focussession.updateMany({
        where: { roomid, status: { in: ["SCHEDULED", "ACTIVE"]} },
        data: { status: "CANCELED", endtime: now },
      }),
      prisma.studyroommember.updateMany({
        where: { roomid, leftat: null, },
        data: { leftat: now },
      }),
    ]);
  },
};
