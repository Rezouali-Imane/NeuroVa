import { config } from 'dotenv';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { createServer } from 'node:http'; 
import { Server } from 'socket.io'; 

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

const PORT = process.env.PORT || 3000;


httpServer.listen(PORT, () => {
  console.log(`🚀 Neurova Server running on port ${PORT}`);
});