import type { Request, Response } from "express";
import type { AuthRequest } from "../../infrastructure/middleware/authMiddleware.js";

import { GetXPHistory } from "../../usecases/Gamification/GetXPHistory.js";
import { GetUserBadges } from "../../usecases/Gamification/GetUserBadges.js";
import { GetUserAchivements } from "../../usecases/Gamification/GetUserAchivements.js";
import { UpdateLeaderboard } from "../../usecases/Gamification/UpdateLeaderboard.js";
import { GetLeaderboardTopN } from "../../usecases/Gamification/GetLeaderboardTopN.js";
import { CompleteChallenge } from "../../usecases/Gamification/CompleteChalenge.js";
import { GetActiveDailyChallenges } from "../../usecases/Gamification/GetActiveDailyChallenges.js";

export const GamificationController = {
  async getXPHistory(req: Request, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const result = await GetXPHistory(userid);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },

  async getUserAchievements(req: Request, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const result = await GetUserAchivements(userid);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },

  async getUserBadges(req: Request, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const result = await GetUserBadges(userid);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },

  async updateLeaderboard(req: Request, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const { leaderboardid, xppoints } = req.body;
      const result = await UpdateLeaderboard({ leaderboardid, userid, xppoints });
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },

  async getLeaderboardTopN(req: Request, res: Response) {
    try {
      const leaderboardid = req.params.id as string;
      const limit = parseInt(req.params.n as string) || 10;
      const result = await GetLeaderboardTopN({ leaderboardid, limit });
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },

  async completeChallenge(req: Request, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const challengeid = req.params.id as string;
      const result = await CompleteChallenge(userid, { challengeid });
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },

  async getActiveDailyChallenges(req: Request, res: Response) {
    try {
      const { userid } = (req as AuthRequest).user!;
      const result = await GetActiveDailyChallenges(userid);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(400).json({ success: false, error: error.message });
    }
  },
};
