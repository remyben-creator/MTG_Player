import { Server } from 'colyseus';
import { WebSocketTransport } from '@colyseus/ws-transport';
import { createServer } from 'http';
import express from 'express';
import cors from 'cors';
import { MTGGameRoom } from './rooms/MTGGameRoom';

const port = Number(process.env.PORT || 2567);
const app = express();

// Enable CORS for Flutter clients
app.use(cors());
app.use(express.json());

const httpServer = createServer(app);

const gameServer = new Server({
  transport: new WebSocketTransport({
    server: httpServer,
    pingInterval: 3000,
    pingMaxRetries: 2,
  }),
  gracefullyShutdown: true,
});

// Define game room
gameServer.define('mtg_game', MTGGameRoom);

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', rooms: gameServer.rooms.size });
});

// Get available rooms
app.get('/rooms', async (req, res) => {
  try {
    const rooms = await gameServer.matchMaker.query({});
    res.json(rooms);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch rooms' });
  }
});

gameServer.listen(port).then(() => {
  console.log(`🎮 MTG Player Server listening on port ${port}`);
  console.log(`📡 WebSocket endpoint: ws://localhost:${port}`);
  console.log(`🌐 HTTP endpoint: http://localhost:${port}`);
});
