import { Router } from "express";
import { GamificationController } from "../controllers/GamificationController.js";

const router = Router();

// XP
router.get("/xp-history", GamificationController.getXPHistory);
router.post("/xp/award", GamificationController.awardXP);


// Achievements
router.get("/achievements", GamificationController.getUserAchievements);
router.post("/achievements/check-and-award", GamificationController.checkAndAwardAchievement);


// Badges
router.get("/badges", GamificationController.getUserBadges);
router.post("/badges/award", GamificationController.awardBadge);


// Leaderboard
router.post("/leaderboard/update", GamificationController.updateLeaderboard);
router.get("/leaderboard/:id/top/:n", GamificationController.getLeaderboardTopN);

// Daily Challenges
router.get("/daily-challenges/active", GamificationController.getActiveDailyChallenges);
router.post("/daily-challenges/assign", GamificationController.assignDailyChallenge);
router.post("/daily-challenges/complete/:id", GamificationController.completeChallenge);
router.post("/streak/calculate", GamificationController.calculateStreak);
router.post("/focus-score/calculate", GamificationController.calculateFocusScore);

export default router;