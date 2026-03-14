import prisma from '../../infrastructure/database/prisma.client.js';

export const StudentRepository = {
  async create(userid: string, major?: string) {
    const createData = {
      userid,
      ...(major ? { major } : {}),
    };

    return await prisma.student.create({
      data: createData,
    });
  },

  async findByUserId(userid: string) {
    return await prisma.student.findUnique({
      where: { userid },
      include: {
        users: true,
      },
    });
  }
};

export const AdminRepository = {
  async create(userid: string) {
    return await prisma.admin.create({
      data: {
        userid,
      },
    });
  },

  async findByUserId(userid: string) {
    return await prisma.admin.findUnique({
      where: { userid },
      include: {
        users: true,
      },
    });
  }
};
