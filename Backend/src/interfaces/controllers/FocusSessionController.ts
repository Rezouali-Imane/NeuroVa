import type { Request, Response } from 'express';
import { CreateSession } from "../../usecases/sessions/CreateSession.js";
import { StartSession } from "../../usecases/sessions/StartSession.js";
import { EndSession } from "../../usecases/sessions/EndSession.js";
import { GetSessions } from "../../usecases/sessions/GetSession.js";
import { GetSessionById } from "../../usecases/sessions/GetSessionById.js";
import { DeleteSession } from "../../usecases/sessions/DeleteSession.js";

import { CreateTimer } from "../../usecases/sessions/CreateTimer.js";
import { UpdateTimer } from "../../usecases/sessions/UpdateTimer.js";
import { GetTimer } from "../../usecases/sessions/GetTimer.js";

import { CreateFocusAudio } from "../../usecases/sessions/CreateAudioSettings.js";
import { CreateAmbientSound } from "../../usecases/sessions/CreateAmbientSound.js";
import { UpdateAmbientSound } from "../../usecases/sessions/UpdateAmbientSound.js";
import { 
    UpdateAudioSettings, 
    RemoveAmbientSound 
} from "../../usecases/sessions/UpdateAudioSettings.js";

export const FocusSessionController = {
    async create(req: Request, res: Response) {
        try{
            const session = await CreateSession(req.body);
            await CreateTimer(session.sessionid);
            await CreateFocusAudio({ sessionid: session.sessionid });
            res.status(201).json({ success: true, data: session });
        } catch (error: any){
            res.status(400).json({ success: false, message: error.message });
        }
    },

    async delete(req: Request, res: Response) {
        try {
            const sessionid = req.params['sessionid'] as string;
            await DeleteSession(sessionid);
            res.status(200).json({ success: true, message: "Session deleted" });
        } catch (error: any) {
            res.status(400).json({ success: false, message: error.message });
        }
    },

    async getAll(req: Request, res: Response) {
        try {
            const userid = req.params['userid'] as string;
            const sessions = await GetSessions(userid);
            res.status(200).json({ success: true, data: sessions });
        } catch (error: any) {
            res.status(400).json({ success: false, message: error.message });
        }
    },

    async getById(req: Request, res: Response) {
        try {
            const sessionid = req.params['sessionid'] as string;
            const session = await GetSessionById(sessionid);
            res.status(200).json({ success: true, data: session });
        } catch (error: any) {
            res.status(404).json({ success: false, message: error.message });
        }
    },

    async start(req: Request, res: Response) {
        try {
            const sessionid = req.params['sessionid'] as string;
            const session = await StartSession(sessionid);
            res.status(200).json({ success: true, data: session });
        } catch (error: any) {
            res.status(400).json({ success: false, message: error.message });
        }
    },

    async end(req: Request, res: Response) {
        try {
            const sessionid = req.params['sessionid'] as string;
            const session = await EndSession(sessionid);
            res.status(200).json({ success: true, data: session });
        } catch (error: any) {
            res.status(400).json({ success: false, message: error.message });
        }
    },

async updateTimer(req: Request, res: Response) {
        try {
            const sessionid = req.params['sessionid'] as string;
            const timer = await UpdateTimer(sessionid, req.body);
            res.status(200).json({ success: true, data: timer });
        } catch (error: any) {
            res.status(400).json({ success: false, message: error.message });
        }
    },
    async getTimer(req: Request, res: Response) {
        try {
            const sessionid = req.params['sessionid'] as string;
            const timer = await GetTimer(sessionid);
            res.status(200).json({ success: true, data: timer });
        } catch (error: any) {
            const status = error.message === "Timer not found for this session" ? 404 : 400;
            res.status(status).json({ success: false, message: error.message });
        }
    },
    async updateAudioSettings(req: Request, res: Response) {
        try {
            const sessionid = req.params['sessionid'] as string;
            // On passe directement req.body qui contient { volumelevel, mixambientsounds }
            const result = await UpdateAudioSettings(sessionid, req.body);
            res.status(200).json(result);
        } catch (error: any) {
            res.status(400).json({ success: false, message: error.message });
        }
    },
    async handleAmbientSound(req: Request, res: Response) {
        try {
            const sessionid = req.params['sessionid'] as string;
            const result = req.body.soundid
                ? await UpdateAmbientSound(sessionid, req.body)
                : await CreateAmbientSound(sessionid, req.body);
            res.status(200).json(result);
        } catch (error: any) {
            res.status(400).json({ success: false, message: error.message });
        }
    },

    async deleteAmbientSound(req: Request, res: Response) {
        try {
            // Ici on utilise l'ID du son directement depuis les paramètres
            const soundid = req.params['soundid'] as string;
            const result = await RemoveAmbientSound(soundid);
            res.status(200).json(result);
        } catch (error: any) {
            res.status(400).json({ success: false, message: error.message });
        }
    }


}