import type { Request, Response } from 'express';
import multer from 'multer';
import type { FileFilterCallback } from 'multer';
import type { AuthRequest } from '../../infrastructure/middleware/authMiddleware.js';
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
import { SendImageMessage } from '../../usecases/ai/SendImageMessage.js';
import { TranscribeAudio } from '../../usecases/ai/TranscribeAudio.js';
import { GetInsights } from '../../usecases/ai/GetInsights.js';
import { FilterContent } from '../../usecases/contentModeration/FilterContent.js';
import { AnalyzeImage } from '../../usecases/contentModeration/AnalyzeImage.js';
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

export const imageUpload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 8 * 1024 * 1024 },
  fileFilter: (_req: Request, file: Express.Multer.File, cb: FileFilterCallback) => {
    if (file.mimetype.startsWith('image/')) cb(null, true);
    else cb(new Error('Only image files are allowed'));
  },
});

export const voiceUpload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 20 * 1024 * 1024 },
  fileFilter: (_req: Request, file: Express.Multer.File, cb: FileFilterCallback) => {
    if (file.mimetype.startsWith('audio/')) cb(null, true);
    else cb(new Error('Only audio files are allowed'));
  },
});

// Middleware to extract and validate user ID from auth token
export const extractUserId = (req: AuthRequest, res: Response, next: Function) => {
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
  async sendMessage(req: AuthRequest, res: Response) {
    try {
      const userid = (req.user as any)?.userid;
      if (!userid) {
        throw new AIError(AIErrorCode.UNAUTHORIZED, 'Authentication required', 401);
      }

      const payload = {
        ...req.body,
        userid,
      };

      const incomingContent = typeof payload.content === 'string' ? payload.content : '';
      const incomingTextDecision = await FilterContent(userid, incomingContent);
      if (incomingTextDecision.decision === 'BLOCK') {
        return res.status(403).json({
          success: false,
          message: 'Message blocked by content moderation policy',
          moderation: incomingTextDecision,
        });
      }

      if (typeof payload.imageUrl === 'string' && payload.imageUrl.trim()) {
        const imageDecision = await AnalyzeImage({ userid, imageUrl: payload.imageUrl });
        if (imageDecision.decision === 'BLOCK') {
          return res.status(403).json({
            success: false,
            message: 'Image blocked by content moderation policy',
            moderation: imageDecision,
          });
        }
      }

      const result = await SendMessage(payload);

      const outgoingDecision = await FilterContent(userid, result.reply);
      if (outgoingDecision.decision === 'BLOCK') {
        return res.status(200).json({
          success: true,
          data: {
            ...result,
            reply:
              'I cannot help with that request. I can help with safe academic topics, study plans, and productivity tasks.',
            actions: [],
            moderation: {
              blocked: true,
              direction: 'outgoing',
              reason: outgoingDecision.reason,
            },
          },
        });
      }

      res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      handleAIError(error, res);
    }
  },

  async getChatHistory(req: AuthRequest, res: Response) {
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

  async sendImageMessage(req: AuthRequest, res: Response) {
    try {
      const userid = (req.user as any)?.userid;
      if (!userid) {
        throw new AIError(AIErrorCode.UNAUTHORIZED, 'Authentication required', 401);
      }

      const file = req.file;
      if (!file) {
        throw new AIError(AIErrorCode.VALIDATION_ERROR, 'No image uploaded', 400);
      }

      const base64 = file.buffer.toString('base64');
      const imageDataUrl = `data:${file.mimetype};base64,${base64}`;

      const imageDecision = await AnalyzeImage({ userid, imageUrl: file.originalname });
      if (imageDecision.decision === 'BLOCK') {
        return res.status(403).json({
          success: false,
          message: 'Image blocked by content moderation policy',
          moderation: imageDecision,
        });
      }

      const prompt = String(req.body.prompt ?? '');
      const promptDecision = await FilterContent(userid, prompt);
      if (promptDecision.decision === 'BLOCK') {
        return res.status(403).json({
          success: false,
          message: 'Prompt blocked by content moderation policy',
          moderation: promptDecision,
        });
      }

      const result = await SendImageMessage({
        userid,
        prompt,
        imageDataUrl,
        directchat: String(req.body.directchat ?? 'false').toLowerCase() === 'true',
        faithmode: String(req.body.faithmode ?? 'false').toLowerCase() === 'true',
      });

      const outgoingDecision = await FilterContent(userid, result.reply);
      if (outgoingDecision.decision === 'BLOCK') {
        return res.status(200).json({
          success: true,
          data: {
            ...result,
            reply:
              'I cannot help with that request. I can help with safe academic topics, study plans, and productivity tasks.',
            actions: [],
          },
        });
      }

      return res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      handleAIError(error, res);
    }
  },

  async sendVoiceMessage(req: AuthRequest, res: Response) {
    try {
      const userid = (req.user as any)?.userid;
      if (!userid) {
        throw new AIError(AIErrorCode.UNAUTHORIZED, 'Authentication required', 401);
      }

      const file = req.file;
      if (!file) {
        throw new AIError(AIErrorCode.VALIDATION_ERROR, 'No audio uploaded', 400);
      }

      const transcript = await TranscribeAudio(file.buffer, file.originalname, file.mimetype);

      const prefix = String(req.body.promptPrefix ?? '').trim();
      const content = prefix ? `${prefix}\n\n${transcript}` : transcript;

      const incomingDecision = await FilterContent(userid, content);
      if (incomingDecision.decision === 'BLOCK') {
        return res.status(403).json({
          success: false,
          message: 'Voice message blocked by content moderation policy',
          moderation: incomingDecision,
        });
      }

      const result = await SendMessage({
        userid,
        content,
        directchat: String(req.body.directchat ?? 'false').toLowerCase() === 'true',
        faithmode: String(req.body.faithmode ?? 'false').toLowerCase() === 'true',
      });

      const outgoingDecision = await FilterContent(userid, result.reply);
      if (outgoingDecision.decision === 'BLOCK') {
        return res.status(200).json({
          success: true,
          data: {
            ...result,
            reply:
              'I cannot help with that request. I can help with safe academic topics, study plans, and productivity tasks.',
            actions: [],
            transcript,
          },
        });
      }

      return res.status(200).json({ success: true, data: { ...result, transcript } });
    } catch (error: any) {
      handleAIError(error, res);
    }
  },

  async clearChatHistory(req: AuthRequest, res: Response) {
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

  async generateStudyPlan(req: AuthRequest, res: Response) {
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

  async analyzeWeakness(req: AuthRequest, res: Response) {
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


  async getMemory(req: AuthRequest, res: Response) {
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

  async updateMemory(req: AuthRequest, res: Response) {
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

  async uploadDocument(req: AuthRequest, res: Response) {
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

  async getKnowledgeBase(req: AuthRequest, res: Response) {
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

  async deleteDocument(req: AuthRequest, res: Response) {
    try {
      const id = req.params['id'] as string;
      const result = await DeleteDocument(id);
      res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      handleAIError(error, res);
    }
  },

  async scheduleFocusSession(req: AuthRequest, res: Response) {
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

  async sendReminders(req: AuthRequest, res: Response) {
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

  async getInsights(req: AuthRequest, res: Response) {
    try {
      const userid = req.params['userid'] as string;
      const requestUserId = (req.user as any)?.userid;

      // Validate user can only access their own insights
      validateUserAccess(requestUserId, userid);

      const insights = await GetInsights(userid);
      res.status(200).json({ success: true, data: insights });
    } catch (error: any) {
      handleAIError(error, res);
    }
  },
};