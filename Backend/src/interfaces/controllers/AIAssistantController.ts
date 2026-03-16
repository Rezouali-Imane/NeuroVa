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

// Keep uploaded files in memory so we can process them immediately.
export const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 }, // 10 MB
  fileFilter: (_req: Request, file: Express.Multer.File, cb: FileFilterCallback) => {
    const allowed = ['application/pdf', 'text/plain', 'text/markdown'];
    if (allowed.includes(file.mimetype)) cb(null, true);
    else cb(new Error('Only PDF and text files are allowed'));
  },
});

export const AIAssistantController = {

  // Chat endpoints.

  async sendMessage(req: Request, res: Response) {
    try {
      const result = await SendMessage(req.body);
      res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async getChatHistory(req: Request, res: Response) {
    try {
      const userid = req.params['userid'] as string;
      const history = await GetChatHistory(userid);
      res.status(200).json({ success: true, data: history });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async clearChatHistory(req: Request, res: Response) {
    try {
      const userid = req.params['userid'] as string;
      const result = await ClearChatHistory(userid);
      res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  // Study planning and analysis endpoints.

  async generateStudyPlan(req: Request, res: Response) {
    try {
      const userid = req.params['userid'] as string;
      const { faithmode, city, country } = req.body;
      const result = await GenerateStudyPlan({ userid, faithmode, city, country });
      res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async analyzeWeakness(req: Request, res: Response) {
    try {
      const userid = req.params['userid'] as string;
      const result = await AnalyzeWeakness({ userid });
      res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  // Student memory endpoints.

  async getMemory(req: Request, res: Response) {
    try {
      const userid = req.params['userid'] as string;
      const result = await GetStudentMemory(userid);
      res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async updateMemory(req: Request, res: Response) {
    try {
      const userid = req.params['userid'] as string;
      const result = await UpdateStudentMemory({ userid, ...req.body });
      res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  // Knowledge base endpoints.

  async uploadDocument(req: Request, res: Response) {
    try {
      const file = req.file;
      if (!file) throw new Error('No file uploaded');
      const { userid, major, subject } = req.body;
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
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async getKnowledgeBase(req: Request, res: Response) {
    try {
      const userid = req.params['userid'] as string;
      const docs = await GetKnowledgeBase(userid);
      res.status(200).json({ success: true, data: docs });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async deleteDocument(req: Request, res: Response) {
    try {
      const id = req.params['id'] as string;
      const result = await DeleteDocument(id);
      res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  // Automation helpers.

  async scheduleFocusSession(req: Request, res: Response) {
    try {
      const userid = req.params['userid'] as string;
      const { taskid, durationMinutes } = req.body;
      const result = await ScheduleFocusSession({ userid, taskid, durationMinutes });
      res.status(201).json({ success: true, data: result });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },

  async sendReminders(req: Request, res: Response) {
    try {
      const userid = req.params['userid'] as string | undefined;
      const result = await SendTaskReminders(userid);
      res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      res.status(400).json({ success: false, message: error.message });
    }
  },
};