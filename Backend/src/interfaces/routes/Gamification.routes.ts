import { Router } from "express";
import { GamificationController } from "../controllers/GamificationController.js";

const router = Router();

// XP
router.get("/xp-history", GamificationController.getXPHistory);


// Achievements
router.get("/achievements", GamificationController.getUserAchievements);


// Badges
router.get("/badges", GamificationController.getUserBadges);


// Leaderboard
router.post("/leaderboard/update", GamificationController.updateLeaderboard);
router.get("/leaderboard/:id/top/:n", GamificationController.getLeaderboardTopN);

// Daily Challenges
router.get("/daily-challenges/active", GamificationController.getActiveDailyChallenges);
router.post("/challenge/complete/:id", GamificationController.completeChallenge);

export default router;