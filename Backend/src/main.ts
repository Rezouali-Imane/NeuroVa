import { config } from 'dotenv';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { createServer } from 'node:http'; 
import { Server } from 'socket.io'; 
import { JwtClient } from './infrastructure/jwt.client.js';
import { SendMessage } from './usecases/ai/SendMessage.js';
import { FilterContent } from './usecases/contentModeration/FilterContent.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

config({ path: path.resolve(__dirname, '../.env') });

const { default: app } = await import('./app.js');

const httpServer = createServer(app);


const io = new Server(httpServer, {
  cors: { origin: "*", methods: ["GET", "POST"] }
});


const studyNamespace = io.of("/studyroom"); 

app.set("io", studyNamespace);

studyNamespace.on("connection", (socket) => {
  console.log(`User connected to Study Namespace: ${socket.id}`);

  socket.on("join_room", (roomid: string) => {
    socket.join(roomid);
    console.log(`User ${socket.id} joined room ${roomid}`);
  });

  socket.on("disconnect", () => {
    console.log("User disconnected");
  });
});

const aiCallNamespace = io.of('/aicall');

aiCallNamespace.use((socket, next) => {
  try {
    const tokenFromAuth = typeof socket.handshake.auth?.['token'] === 'string'
      ? socket.handshake.auth['token']
      : undefined;
    const authHeader = socket.handshake.headers.authorization;
    const tokenFromHeader = typeof authHeader === 'string' && authHeader.startsWith('Bearer ')
      ? authHeader.slice(7)
      : undefined;

    const token = tokenFromAuth || tokenFromHeader;
    if (!token) {
      return next(new Error('Unauthorized'));
    }

    const decoded = JwtClient.verifyAccessToken(token);
    socket.data['user'] = decoded;
    next();
  } catch {
    next(new Error('Unauthorized'));
  }
});

aiCallNamespace.on('connection', (socket) => {
  socket.on('voice_turn', async (payload: {
    requestId?: string;
    content?: string;
    directchat?: boolean;
    faithmode?: boolean;
  }) => {
    const requestId = payload?.requestId || `${Date.now()}`;

    try {
      const user = socket.data['user'] as { userid: string } | undefined;
      const userid = user?.userid;
      if (!userid) {
        socket.emit('voice_turn_error', {
          requestId,
          message: 'Unauthorized',
        });
        return;
      }

      const content = (payload?.content || '').trim();
      if (!content) {
        socket.emit('voice_turn_error', {
          requestId,
          message: 'Voice transcript is empty',
        });
        return;
      }

      const incomingDecision = await FilterContent(userid, content);
      if (incomingDecision.decision === 'BLOCK') {
        socket.emit('moderation_block', {
          requestId,
          direction: 'incoming',
          reason: incomingDecision.reason,
        });
        return;
      }

      const result = await SendMessage({
        userid,
        content,
        directchat: Boolean(payload?.directchat ?? true),
        faithmode: Boolean(payload?.faithmode ?? false),
      });

      const outgoingDecision = await FilterContent(userid, result.reply);
      if (outgoingDecision.decision === 'BLOCK') {
        socket.emit('assistant_reply', {
          requestId,
          reply:
            'I cannot help with that request. I can help with safe academic topics, study plans, and productivity tasks.',
          actions: [],
          language: result.language,
          moderation: {
            blocked: true,
            direction: 'outgoing',
            reason: outgoingDecision.reason,
          },
        });
        return;
      }

      socket.emit('assistant_reply', {
        requestId,
        reply: result.reply,
        actions: result.actions,
        language: result.language,
      });
    } catch (error: any) {
      socket.emit('voice_turn_error', {
        requestId,
        message: error?.message || 'Voice turn failed',
      });
    }
  });
});

const PORT = process.env.PORT || 3000;


httpServer.listen(PORT, () => {
  console.log(`🚀 Neurova Server running on port ${PORT}`);
});