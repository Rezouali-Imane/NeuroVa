import type { Request, Response } from 'express';
import multer from 'multer';
import type { FileFilterCallback } from 'multer';
import { SendMessage } from '../../usecases/ai/SendMessage.js';
import { GetChatHistory } from '../../usecases/ai/GetChatHistory.js';
import { ClearChatHistory } from '../../usecases/ai/ClearChatHistory.js';
import { GenerateStudyPlan } from '../../usecases/ai/GenerateStudyPlan.js';
import { AnalyzeWeakness } from '../../usecases/ai/Analyzeweakness.js';
import { GetStudentMemory } from '../../usecases/ai/Getstudentmemory.js';
import { UpdateStudentMemory } from '../../usecases/ai/Updatestudentmemory.js';
import { ProcessDocument } from '../../usecases/ai/Processdocument.js';
import { GetKnowledgeBase, DeleteDocument } from '../../usecases/ai/Knowledgebase.usecases.js';
import { ScheduleFocusSession } from '../../usecases/ai/Schedulefocussession.js';
import { SendTaskReminders } from '../../usecases/ai/Sendtaskreminders.js';
import {
  handleAIError,
  validateUserAccess,
  AIError,
  AIErrorCode,
} from '../../infrastructure/ai/error.handler.js';

export const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 }, // 10 MB
  fileFilter: (_req: Request, file: Express.Multer.File, cb: FileFilterCallback) => {
    const allowed = ['application/pdf', 'text/plain', 'text/markdown'];
    if (allowed.includes(file.mimetype)) cb(null, true);
    else cb(new Error('Only PDF and text files are allowed'));
  },
});

// Middleware to extract and validate user ID from auth token
export const extractUserId = (req: Request, res: Response, next: Function) => {
  try {
    // Assuming authMiddleware sets req.user
    if (!req.user) {
      throw new AIError(AIErrorCode.UNAUTHORIZED, 'Authentication required', 401);
    }
    next();
  } catch (error) {
    handleAIError(error, res);
  }
};

export const AIAssistantController = {
  async sendMessage(req: Request, res: Response) {
    try {
      const result = await SendMessage(req.body);
      res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      handleAIError(error, res);
    }
  },

  async getChatHistory(req: Request, res: Response) {
    try {
      const userid = req.params['userid'] as string;
      const requestUserId = (req.user as any)?.userid;

      // Validate user can only access their own history
      validateUserAccess(requestUserId, userid);

      const limit = Math.min(parseInt(req.query.limit as string) || 50, 100);
      const offset = parseInt(req.query.offset as string) || 0;

      const history = await GetChatHistory(userid);
      // Simple pagination
      const paginatedHistory = history.slice(offset, offset + limit);

      res.status(200).json({
        success: true,
        data: paginatedHistory,
        pagination: { limit, offset, total: history.length },
      });
    } catch (error: any) {
      handleAIError(error, res);
    }
  },

  async clearChatHistory(req: Request, res: Response) {
    try {
      const userid = req.params['userid'] as string;
      const requestUserId = (req.user as any)?.userid;

      validateUserAccess(requestUserId, userid);

      const result = await ClearChatHistory(userid);
      res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      handleAIError(error, res);
    }
  },

  async generateStudyPlan(req: Request, res: Response) {
    try {
      const userid = req.params['userid'] as string;
      const requestUserId = (req.user as any)?.userid;

      validateUserAccess(requestUserId, userid);

      const { faithmode, city, country } = req.body;
      const result = await GenerateStudyPlan({ userid, faithmode, city, country });
      res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      handleAIError(error, res);
    }
  },

  async analyzeWeakness(req: Request, res: Response) {
    try {
      const userid = req.params['userid'] as string;
      const requestUserId = (req.user as any)?.userid;

      validateUserAccess(requestUserId, userid);

      const result = await AnalyzeWeakness({ userid });
      res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      handleAIError(error, res);
    }
  },


  async getMemory(req: Request, res: Response) {
    try {
      const userid = req.params['userid'] as string;
      const requestUserId = (req.user as any)?.userid;

      validateUserAccess(requestUserId, userid);

      const result = await GetStudentMemory(userid);
      res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      handleAIError(error, res);
    }
  },

  async updateMemory(req: Request, res: Response) {
    try {
      const userid = req.params['userid'] as string;
      const requestUserId = (req.user as any)?.userid;

      validateUserAccess(requestUserId, userid);

      const result = await UpdateStudentMemory({ userid, ...req.body });
      res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      handleAIError(error, res);
    }
  },

  async uploadDocument(req: Request, res: Response) {
    try {
      const file = req.file;
      if (!file) {
        throw new AIError(AIErrorCode.VALIDATION_ERROR, 'No file uploaded', 400);
      }

      const userid = req.body.userid as string;
      const requestUserId = (req.user as any)?.userid;

      validateUserAccess(requestUserId, userid);

      const { major, subject } = req.body;
      const result = await ProcessDocument({
        userid,
        major,
        subject,
        filename: file.originalname,
        fileBuffer: file.buffer,
        mimetype: file.mimetype,
      });
      res.status(201).json({ success: true, data: result });
    } catch (error: any) {
      handleAIError(error, res);
    }
  },

  async getKnowledgeBase(req: Request, res: Response) {
    try {
      const userid = req.params['userid'] as string;
      const requestUserId = (req.user as any)?.userid;

      validateUserAccess(requestUserId, userid);

      const docs = await GetKnowledgeBase(userid);
      res.status(200).json({ success: true, data: docs });
    } catch (error: any) {
      handleAIError(error, res);
    }
  },

  async deleteDocument(req: Request, res: Response) {
    try {
      const id = req.params['id'] as string;
      const result = await DeleteDocument(id);
      res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      handleAIError(error, res);
    }
  },

  async scheduleFocusSession(req: Request, res: Response) {
    try {
      const userid = req.params['userid'] as string;
      const requestUserId = (req.user as any)?.userid;

      validateUserAccess(requestUserId, userid);

      const { taskid, durationMinutes } = req.body;
      const result = await ScheduleFocusSession({ userid, taskid, durationMinutes });
      res.status(201).json({ success: true, data: result });
    } catch (error: any) {
      handleAIError(error, res);
    }
  },

  async sendReminders(req: Request, res: Response) {
    try {
      const userid = req.params['userid'] as string | undefined;
      if (userid) {
        const requestUserId = (req.user as any)?.userid;
        validateUserAccess(requestUserId, userid);
      }
      const result = await SendTaskReminders(userid);
      res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      handleAIError(error, res);
    }
  },
};