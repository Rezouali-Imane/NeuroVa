import prisma from"../../infrastructure/database/prisma.client.js" ;
import type { CreateRoomDTO, JoinRoomDTO, LeaveRoomDTO } from "../dtos/StudyRoom.dto.js";

export const StudyRoomRepository = {
    async create(data: CreateRoomDTO) {
        return await prisma.$transaction(async (tx) => {
            // Create  StudyRoom
            const room = await tx.studyroom.create({
                data: {
                    roomname: data.roomname,
                    sessionduration: data.sessionduration,
                    isactive: false,
                },
            });

            // Create Study Room Owner
            await tx.studyroommember.create({
                data: {
                    userid: data.ownerid,
                    roomid: room.roomid,
                    isowner: true,
                },
            });

            //  Create initial Focus Session for the owner StudyRoom
            await tx.focussession.create({
                data: {
                    userid: data.ownerid,
                    roomid: room.roomid,
                    starttime: data.starttime,
                    endtime: data.endtime,
                    status: 'SCHEDULED',
                },
            });

            return room;
        });
    },

    async join(data: JoinRoomDTO, starttime: Date, endtime: Date) {
        return await prisma.$transaction(async (tx) => {
            const member = await tx.studyroommember.create({
                data: {
                    userid: data.userid,
                    roomid: data.roomid,
                    isowner: false,
                },
            });

            await tx.focussession.create({
                data: {
                    userid: data.userid,
                    roomid: data.roomid,
                    starttime: starttime,
                    endtime: endtime,
                    status: 'SCHEDULED',
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
                    roomid: data.roomid 
                },
            },
            data: {
                leftat: new Date(),
            },
        });
    },

    async findById(roomid: string) {
        return await prisma.studyroom.findUnique({
            where: { roomid },
            include: { studyroommember: true, focussession: true },
        });
    }
};