import { AssignDailyChallenge } from "./AssignDailyChallenge.js";
import { GamificationRepository } from "../../interfaces/repositories/GamificationRepository.js";

const DEFAULT_CHALLENGE_TEMPLATES = [
    {
        title: "Triple Focus",
        description: "Complete 3 focused study sessions today.",
        xpreward: 75,
    },
    {
        title: "Task Master",
        description: "Finish 5 tasks from your list.",
        xpreward: 50,
    },
    {
        title: "Note Taker",
        description: "Create 2 useful notes today.",
        xpreward: 30,
    },
    {
        title: "Early Bird",
        description: "Start your first focus session before 9 AM.",
        xpreward: 100,
    },
];

export const GetActiveDailyChallenges = async (userid: string) => {
    try {
        const templates = await GamificationRepository.getAllChallengeTemplates();
        if (templates.length < DEFAULT_CHALLENGE_TEMPLATES.length) {
            const existingTitles = new Set(templates.map((template) => template.title.toLowerCase()));
            const templatesToCreate = DEFAULT_CHALLENGE_TEMPLATES.filter((template) => !existingTitles.has(template.title.toLowerCase()));

            if (templatesToCreate.length > 0) {
                await GamificationRepository.createDailyChallengeTemplates(templatesToCreate);
            }
        }

        const refreshedTemplates = await GamificationRepository.getAllChallengeTemplates();
        const activeChallenges = await GamificationRepository.getActiveChallengesByUser(userid);
        const minimumDailyChallenges = 4;

        if (activeChallenges.length < minimumDailyChallenges) {
            const assignedTemplateIds = new Set(activeChallenges.map((challenge) => challenge.templateid));
            let missing = minimumDailyChallenges - activeChallenges.length;

            for (const template of refreshedTemplates) {
                if (missing <= 0) {
                    break;
                }

                if (assignedTemplateIds.has(template.templateid)) {
                    continue;
                }

                const result = await AssignDailyChallenge(userid, template.templateid);
                if (result.success) {
                    assignedTemplateIds.add(template.templateid);
                    missing -= 1;
                }
            }
        }

        const dailyChallenges = await GamificationRepository.getActiveChallengesByUser(userid);
        return {
            success: true,
            message: "Daily challenges retrieved successfully",
            data: dailyChallenges,
        };
    } catch (error) {

        return {
            success: false,
            message: error instanceof Error ? error.message : "Failed to retrieve daily challenges",
        };
    }
};