import type { Request, Response } from "express";
import type { AuthRequest } from "../../infrastructure/middleware/authMiddleware.js";
import { GamificationService } from "../../usecases/Gamification/GamificationService.js";

export const GamificationController = {
  async getXPHistory(req: Request, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const result = await GamificationService.getXPHistory(userid);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },

  async getUserAchievements(req: Request, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const result = await GamificationService.getUserAchievements(userid);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },

  async getUserBadges(req: Request, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const result = await GamificationService.getUserBadges(userid);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },

  async updateLeaderboard(req: Request, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const { leaderboardid, xppoints } = req.body;
      const result = await GamificationService.updateLeaderboardEntry({ leaderboardid, userid, xppoints });
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },

  async getLeaderboardTopN(req: Request, res: Response) {
    try {
      const leaderboardid = req.params.id as string;
      const limit = parseInt(req.params.n as string) || 10;
      const result = await GamificationService.getLeaderboardTopN(limit, leaderboardid);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },

  async completeChallenge(req: Request, res: Response) {
    try {
      const challengeid = req.params.id as string;
      const result = await GamificationService.completeChallenge(challengeid);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },

  async getActiveDailyChallenges(req: Request, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const result = await GamificationService.getActiveDailyChallenges(userid);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },

  async awardXP(req: Request, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const { amount, source, description } = req.body;
      await GamificationService.awardXP(userid, amount, source, description);
      res.status(200).json({ success: true, message: "XP awarded" });
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },

  async checkAndAwardAchievement(req: Request, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const result = await GamificationService.checkAndAwardAchievements(userid);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },

  async awardBadge(req: Request, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const { badgeid } = req.body;
      const result = await GamificationService.awardBadge(userid, badgeid);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },

  async assignDailyChallenge(req: Request, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const result = await GamificationService.assignDailyChallenge(userid);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },

  async calculateStreak(req: Request, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const result = await GamificationService.calculateStreak(userid);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },

  async calculateFocusScore(req: Request, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const { sessionid, focusminutes, breakminutes, taskscompleted } = req.body;
      const result = await GamificationService.calculateFocusScore({
        userid,
        sessionid,
        focusminutes,
        breakminutes,
        taskscompleted,
      });
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },
};
