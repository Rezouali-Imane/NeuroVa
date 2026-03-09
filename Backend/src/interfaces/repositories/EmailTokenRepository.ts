import prisma from '../../infrastructure/database/prisma.client.js';

export const EmailTokenRepository = {
  async create(userid: string, token: string, expiresat: Date) {
    return await prisma.emailverificationtoken.create({
      data: {
        userid,
        token,
        expiresat,
        isverified: false,
      },
    });
  },

  async findValidToken(userid: string, token: string) {
    return await prisma.emailverificationtoken.findFirst({
      where: {
        userid,
        token,
        isverified: false,
        expiresat: {
          gte: new Date(),
        },
      },
    });
  },

  async markAsUsed(tokenid: string) {
    return await prisma.emailverificationtoken.update({
      where: { tokenid },
      data: {
        isverified: true,
        verifiedat: new Date(),
      },
    });
  },

  async invalidateOldTokens(userid: string) {
    return await prisma.emailverificationtoken.updateMany({
      where: {
        userid,
        isverified: false,
      },
      data: {
        isverified: true,
      },
    });
  }
};
