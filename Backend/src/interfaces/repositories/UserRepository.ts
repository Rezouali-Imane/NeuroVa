import prisma from '../../infrastructure/database/prisma.client.js';
import { UserRole } from '../../entities/User.js';

export const UserRepository = {
  async findByEmail(email: string) {
    if (!email) return null;
    
    return await prisma.users.findUnique({
      where: { email },
      include: {
        student: true,
        admin: true
      }
    });
  },

  async findByUsername(username: string) {
    return await prisma.users.findUnique({
      where: { username },
    });
  },

  async findByEmailOrUsername(identifier: string) {
    return await prisma.users.findFirst({
      where: {
        OR: [{ email: identifier }, { username: identifier }],
      },
    });
  },

  async findById(userid: string) {
    return await prisma.users.findUnique({
      where: { userid },
      include: {
        student: true,
        admin: true
      }
    });
  },

  async create(data: {
    userid?: string;
    name: string;
    lastname: string;
    username: string;
    email: string;
    passwordhash: string;
    userrole?: UserRole;
  }) {
    return await prisma.users.create({
      data: {
        ...data,
        userrole: data.userrole ?? "STUDENT",
        isverified: false,
        islocked: false,
      },
    });
  },

  async updateLoginAttempts(userid: string, attempts: number, lock: boolean) {
    return await prisma.users.update({
      where: { userid },
      data: {
        failedloginattempts: attempts,
        islocked: lock,
      },
    });
  },

  async markUserAsVerified(userid: string) {
    return await prisma.$transaction(async (tx) => {
      await tx.users.update({
        where: { userid },
        data: {
          isverified: true,
          failedloginattempts: 0,
          islocked: false,
        },
      });

      await tx.emailverificationtoken.updateMany({
        where: { userid, isverified: false },
        data: {
          isverified: true,
          verifiedat: new Date(),
        },
      });
    });
  },

  async resetUserPassword(userid: string, newPasswordHash: string) {
    return await prisma.users.update({
      where: { userid },
      data: {
        passwordhash: newPasswordHash,
        failedloginattempts: 0,
        islocked: false,
      },
    });
  }
};
