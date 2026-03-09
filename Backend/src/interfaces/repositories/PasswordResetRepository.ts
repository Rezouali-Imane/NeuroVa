import prisma from '../../infrastructure/database/prisma.client.js';

export const PasswordResetRepository = {
  async create(userid: string, tokenhash: string, expiresat: Date) {
    return await prisma.passwordresettoken.create({
      data: {
        userid,
        tokenhash,
        expiresat,
      },
    });
  },

  async findValidToken(userid: string, tokenhash: string) {
    return await prisma.passwordresettoken.findFirst({
      where: {
        userid,
        tokenhash,
        usedat: null,
        expiresat: {
          gte: new Date(),
        },
      },
    });
  },

  async markAsUsed(tokenid: string) {
    return await prisma.passwordresettoken.update({
      where: { tokenid },
      data: {
        usedat: new Date(),
      },
    });
  },

  async invalidateOldTokens(userid: string) {
    return await prisma.passwordresettoken.updateMany({
      where: {
        userid,
        usedat: null,
      },
      data: {
        usedat: new Date(),
      },
    });
  }
};
