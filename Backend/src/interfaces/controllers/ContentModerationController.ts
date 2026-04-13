import type { Request, Response } from 'express';
import { GetPolicy } from '../../usecases/contentModeration/GetPolicy.js';
import { UpdatePolicy } from '../../usecases/contentModeration/UpdatePolicy.js';
import { AnalyzeText } from '../../usecases/contentModeration/AnalyzeText.js';
import { AnalyzeImage } from '../../usecases/contentModeration/AnalyzeImage.js';
import { FilterContent } from '../../usecases/contentModeration/FilterContent.js';
import { AnalyzeAccess } from '../../usecases/contentModeration/AnalyzeAccess.js';
import type {
  AnalyzeAccessDTO,
  AnalyzeImageDTO,
  AnalyzeTextDTO,
  UpdateContentModerationPolicyDTO,
} from '../dtos/ContentModeration.dto.js';
import type { AuthRequest } from '../../infrastructure/middleware/authMiddleware.js';

const getUserId = (req: Request) => (req as AuthRequest).user?.userid;

export const ContentModerationController = {
  async getPolicy(req: Request, res: Response) {
    try {
      const userid = getUserId(req);
      if (!userid) {
        return res.status(401).json({ success: false, message: 'Authentication required' });
      }

      const policy = await GetPolicy(userid);
      return res.status(200).json({ success: true, data: policy });
    } catch (error: any) {
      return res.status(400).json({ success: false, message: error.message });
    }
  },

  async updatePolicy(req: Request, res: Response) {
    try {
      const userid = getUserId(req);
      if (!userid) {
        return res.status(401).json({ success: false, message: 'Authentication required' });
      }

      const data = req.body as UpdateContentModerationPolicyDTO;
      const policy = await UpdatePolicy(userid, data);
      return res.status(200).json({ success: true, data: policy });
    } catch (error: any) {
      return res.status(400).json({ success: false, message: error.message });
    }
  },

  async analyzeText(req: Request, res: Response) {
    try {
      const userid = getUserId(req);
      if (!userid) {
        return res.status(401).json({ success: false, message: 'Authentication required' });
      }

      const data = { userid, ...(req.body as Omit<AnalyzeTextDTO, 'userid'>) };
      const result = await AnalyzeText(data);
      return res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      return res.status(400).json({ success: false, message: error.message });
    }
  },

  async analyzeImage(req: Request, res: Response) {
    try {
      const userid = getUserId(req);
      if (!userid) {
        return res.status(401).json({ success: false, message: 'Authentication required' });
      }

      const data = { userid, ...(req.body as Omit<AnalyzeImageDTO, 'userid'>) };
      const result = await AnalyzeImage(data);
      return res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      return res.status(400).json({ success: false, message: error.message });
    }
  },

  async filterContent(req: Request, res: Response) {
    try {
      const userid = getUserId(req);
      if (!userid) {
        return res.status(401).json({ success: false, message: 'Authentication required' });
      }

      const { content } = req.body as { content?: string };
      if (!content) {
        return res.status(400).json({ success: false, message: 'Content is required' });
      }

      const result = await FilterContent(userid, content);
      return res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      return res.status(400).json({ success: false, message: error.message });
    }
  },

  async analyzeAccess(req: Request, res: Response) {
    try {
      const userid = getUserId(req);
      if (!userid) {
        return res.status(401).json({ success: false, message: 'Authentication required' });
      }

      const body = req.body as Omit<AnalyzeAccessDTO, 'userid'>;
      if (!body.content && !body.imageUrl && !body.url) {
        return res.status(400).json({
          success: false,
          message: 'Provide at least one of content, imageUrl, or url',
        });
      }

      const result = await AnalyzeAccess({ userid, ...body });
      return res.status(200).json({ success: true, data: result });
    } catch (error: any) {
      return res.status(400).json({ success: false, message: error.message });
    }
  },
};
