import type { Request, Response } from 'express';
import { GetSettings } from '../../usecases/discipline/GetSettings.js';
import { UpdateSettings } from '../../usecases/discipline/UpdateSettings.js';
import { AddBlockedApp } from '../../usecases/discipline/AddBlockedApp.js';
import { RemoveBlockedApp } from '../../usecases/discipline/RemoveBlockedApp.js';
import { AddBlockedWebsite } from '../../usecases/discipline/AddBlockedWebsite.js';
import { RemoveBlockedWebsite } from '../../usecases/discipline/RemoveBlockedWebsite.js';
import { CreateUsageLimit } from '../../usecases/discipline/CreateUsageLimit.js';
import { LogUsage } from '../../usecases/discipline/LogUsage.js';
import { GetTodayUsage } from '../../usecases/discipline/GetTodayUsage.js';
import { TriggerAlert } from '../../usecases/discipline/TriggerAlert.js';
import { CalculateDisciplineScore } from '../../usecases/discipline/CalculateDisciplineScore.js';
import type {
  CreateBlockedAppDTO,
  CreateBlockedWebsiteDTO,
  CreateDisciplineAlertDTO,
  CreateUsageLimitDTO,
  CreateUsageLogDTO,
  UpdateDigitalDisciplineSettingsDTO,
} from '../dtos/DigitalDiscipline.dto.js';
import type { AuthRequest } from '../../infrastructure/middleware/authMiddleware.js';

const getUserId = (req: Request) => (req as AuthRequest).user?.userid;

export const DigitalDisciplineController = {
  async getSettings(req: Request, res: Response) {
    try {
      const userid = getUserId(req);
      if (!userid) {
        return res.status(401).json({ success: false, message: 'Authentication required' });
      }

      const settings = await GetSettings(userid);
      return res.status(200).json({ success: true, data: settings });
    } catch (error: any) {
      return res.status(400).json({ success: false, message: error.message });
    }
  },

  async updateSettings(req: Request, res: Response) {
    try {
      const userid = getUserId(req);
      if (!userid) {
        return res.status(401).json({ success: false, message: 'Authentication required' });
      }

      const data = req.body as UpdateDigitalDisciplineSettingsDTO;
      const settings = await UpdateSettings(userid, data);
      return res.status(200).json({ success: true, data: settings });
    } catch (error: any) {
      return res.status(400).json({ success: false, message: error.message });
    }
  },

  async addBlockedApp(req: Request, res: Response) {
    try {
      const userid = getUserId(req);
      if (!userid) {
        return res.status(401).json({ success: false, message: 'Authentication required' });
      }

      const data = req.body as CreateBlockedAppDTO;
      const item = await AddBlockedApp(userid, data);
      return res.status(201).json({ success: true, data: item });
    } catch (error: any) {
      return res.status(400).json({ success: false, message: error.message });
    }
  },

  async removeBlockedApp(req: Request, res: Response) {
    try {
      const userid = getUserId(req);
      if (!userid) {
        return res.status(401).json({ success: false, message: 'Authentication required' });
      }

      const appid = String(req.params['appid'] ?? '');
      const item = await RemoveBlockedApp(userid, appid);
      return res.status(200).json({ success: true, data: item });
    } catch (error: any) {
      return res.status(400).json({ success: false, message: error.message });
    }
  },

  async addBlockedWebsite(req: Request, res: Response) {
    try {
      const userid = getUserId(req);
      if (!userid) {
        return res.status(401).json({ success: false, message: 'Authentication required' });
      }

      const data = req.body as CreateBlockedWebsiteDTO;
      const item = await AddBlockedWebsite(userid, data);
      return res.status(201).json({ success: true, data: item });
    } catch (error: any) {
      return res.status(400).json({ success: false, message: error.message });
    }
  },

  async removeBlockedWebsite(req: Request, res: Response) {
    try {
      const userid = getUserId(req);
      if (!userid) {
        return res.status(401).json({ success: false, message: 'Authentication required' });
      }

      const websiteid = String(req.params['websiteid'] ?? '');
      const item = await RemoveBlockedWebsite(userid, websiteid);
      return res.status(200).json({ success: true, data: item });
    } catch (error: any) {
      return res.status(400).json({ success: false, message: error.message });
    }
  },

  async createUsageLimit(req: Request, res: Response) {
    try {
      const userid = getUserId(req);
      if (!userid) {
        return res.status(401).json({ success: false, message: 'Authentication required' });
      }

      const data = req.body as CreateUsageLimitDTO;
      const item = await CreateUsageLimit(userid, data);
      return res.status(201).json({ success: true, data: item });
    } catch (error: any) {
      return res.status(400).json({ success: false, message: error.message });
    }
  },

  async logUsage(req: Request, res: Response) {
    try {
      const userid = getUserId(req);
      if (!userid) {
        return res.status(401).json({ success: false, message: 'Authentication required' });
      }

      const data = req.body as CreateUsageLogDTO;
      const item = await LogUsage(userid, data);

      return res.status(201).json({ success: true, data: item });
    } catch (error: any) {
      return res.status(400).json({ success: false, message: error.message });
    }
  },

  async getTodayUsage(req: Request, res: Response) {
    try {
      const userid = getUserId(req);
      if (!userid) {
        return res.status(401).json({ success: false, message: 'Authentication required' });
      }

      const item = await GetTodayUsage(userid);
      return res.status(200).json({ success: true, data: item });
    } catch (error: any) {
      return res.status(400).json({ success: false, message: error.message });
    }
  },

  async triggerAlert(req: Request, res: Response) {
    try {
      const userid = getUserId(req);
      if (!userid) {
        return res.status(401).json({ success: false, message: 'Authentication required' });
      }

      const data = req.body as CreateDisciplineAlertDTO;
      const item = await TriggerAlert(userid, data);
      return res.status(201).json({ success: true, data: item });
    } catch (error: any) {
      return res.status(400).json({ success: false, message: error.message });
    }
  },

  async calculateScore(req: Request, res: Response) {
    try {
      const userid = getUserId(req);
      if (!userid) {
        return res.status(401).json({ success: false, message: 'Authentication required' });
      }

      const item = await CalculateDisciplineScore(userid);
      return res.status(200).json({ success: true, data: item });
    } catch (error: any) {
      return res.status(400).json({ success: false, message: error.message });
    }
  },
};
