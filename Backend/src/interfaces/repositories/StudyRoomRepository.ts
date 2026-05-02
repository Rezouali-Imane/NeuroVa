import prisma from "../../infrastructure/database/prisma.client.js";
import type {
  CreateRoomDTO,
  JoinRoomDTO,
  LeaveRoomDTO,
} from "../dtos/StudyRoom.dto.js";
import { randomBytes } from "crypto";

const generateRoomCode = (): string => {
  return randomBytes(3).toString("hex").toUpperCase();
};

export const StudyRoomRepository = {
  async create(data: CreateRoomDTO) {
    return await prisma.$transaction(async (tx) => {
      const roomcode = generateRoomCode();
      const room = await tx.studyroom.create({
        data: {
          roomname: data.roomname,
          sessionduration: 0,
          roomcode,
          isactive: false,
          ispublic: data.ispublic ?? true,
        },
      });

      await tx.studyroommember.create({
        data: {
          userid: data.ownerid,
          roomid: room.roomid,
          isowner: true,
          isactive: true,
        },
      });

      const now = new Date();
      await tx.focussession.create({
        data: {
          userid: data.ownerid,
          roomid: room.roomid,
          starttime: now,
          status: "SCHEDULED",
        },
      });

      return room;
    });
  },

  async findAllActive() {
    return await prisma.studyroom.findMany({
      where: { isactive: false, endedat: null },
      include: {
        studyroommember: {
          where: { isactive: true },
          include: {
            users: {
              select: {
                userid: true,
                username: true,
              },
            },
          },
        },
      },
      orderBy: { createdat: "desc" },
    });
  },

  async updateRoomDuration(roomid: string, duration: number) {
    return await prisma.studyroom.update({
      where: { roomid },
      data: { sessionduration: duration },
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
    return await prisma.studyroom.findFirst({
      where: { roomcode } as any,
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
    // Check if member already exists
    const existingMember = await prisma.studyroommember.findUnique({
      where: { userid_roomid: { userid: data.userid, roomid } },
    });

    if (existingMember) {
      // Reactivate existing member
      await prisma.studyroommember.update({
        where: { userid_roomid: { userid: data.userid, roomid } },
        data: {
          isactive: true,
          leftat: null,
        },
      });
    } else {
      // Create new member
      await prisma.studyroommember.create({
        data: {
          userid: data.userid,
          roomid,
          isowner: false,
          isactive: true,
        },
      });
    }

    // Create FocusSession if not exists
    const existing = await prisma.focussession.findFirst({
      where: { userid: data.userid, roomid },
    });
    if (!existing) {
      await prisma.focussession.create({
        data: {
          userid: data.userid,
          roomid,
          starttime: new Date(),
          status: "SCHEDULED",
        },
      });
    }

    return await prisma.studyroom.findUnique({
      where: { roomid },
      include: {
        studyroommember: {
          include: { users: { select: { userid: true, username: true } } },
        },
        focussession: true,
      },
    });
  },

  async isActiveMember(roomid: string, userid: string) {
    const member = await prisma.studyroommember.findFirst({
      where: {
        roomid,
        userid,
        isactive: true,
      },
      select: {
        memberid: true,
      },
    });
    return Boolean(member);
  },

  async leave(roomid: string, userid: string) {
    return await prisma.studyroommember.update({
      where: {
        userid_roomid: { userid, roomid },
      },
      data: {
        leftat: new Date(),
        isactive: false,
      },
      include: {
        users: { select: { username: true } },
      },
    });
  },

  async startSession(roomid: string) {
    return await prisma.$transaction([
      prisma.studyroom.update({
        where: { roomid },
        data: { isactive: true },
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
        data: { isactive: false, endedat: now },
      }),
      prisma.focussession.updateMany({
        where: { roomid, status: { in: ["SCHEDULED", "ACTIVE"] } },
        data: { status: "CANCELED", endtime: now },
      }),
      prisma.studyroommember.updateMany({
        where: { roomid, isactive: true },
        data: { leftat: now, isactive: false },
      }),
    ]);
  },

  async cancelFocusSession(roomid: string, userid: string) {
    return await prisma.focussession.updateMany({
      where: { roomid, userid, status: { in: ["SCHEDULED", "ACTIVE"] } },
      data: { status: "CANCELED", endtime: new Date() },
    });
  },

  async completeAllFocusSessions(roomid: string) {
    return await prisma.focussession.updateMany({
      where: { roomid, status: "ACTIVE" },
      data: { status: "COMPLETED", endtime: new Date() },
    });
  },
};
