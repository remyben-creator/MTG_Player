# Colyseus Context Reference

# Colyseus

Colyseus is an authoritative multiplayer framework for Node.js that provides WebSocket-based communication for realtime and turn-based games. It handles server-authoritative state synchronization, automatic client updates via delta compression, and matchmaking clients into game sessions. The framework focuses on simplicity and ease of use on both server and client sides.

The core architecture consists of a Server that manages multiple Room instances, each representing an isolated game session. Rooms handle their own state, lifecycle events, and client connections. The framework supports horizontal and vertical scaling through Redis-based presence, multiple transport layers (WebSocket, uWebSockets, TCP), and pluggable persistence drivers. State synchronization uses the Schema serialization system by default, automatically broadcasting changes to connected clients at a configurable patch rate.

## Server Creation and Room Definition

Create a Colyseus server instance and define room types that clients can join through matchmaking.

```typescript
import { Server } from 'colyseus';
import { WebSocketTransport } from '@colyseus/ws-transport';
import { Room } from '@colyseus/core';

// Create server with WebSocket transport
const gameServer = new Server({
  transport: new WebSocketTransport({
    pingInterval: 3000,
    pingMaxRetries: 2,
  }),
  greet: true,
  gracefullyShutdown: true,
});

// Define a room type
gameServer.define('battle', BattleRoom, {
  maxPlayers: 4,
  mapSize: 'large'
});

// Listen on port
gameServer.listen(2567)
  .then(() => console.log('Server started on port 2567'))
  .catch((err) => console.error('Server error:', err));
```

## Room Lifecycle Implementation

Implement a game room with state management and lifecycle hooks for handling client connections and game logic.

```typescript
import { Room, Client } from '@colyseus/core';
import { Schema, type, MapSchema } from '@colyseus/schema';

class Player extends Schema {
  @type("number") x: number = 0;
  @type("number") y: number = 0;
  @type("string") name: string;
}

class GameState extends Schema {
  @type({ map: Player }) players = new MapSchema<Player>();
  @type("number") countdown: number = 60;
}

export class BattleRoom extends Room<GameState> {
  maxClients = 4;

  onCreate(options: any) {
    this.setState(new GameState());

    // Set simulation interval (game loop)
    this.setSimulationInterval((deltaTime) => {
      this.state.countdown -= deltaTime / 1000;
      if (this.state.countdown <= 0) {
        this.broadcast("gameOver", { winner: "team1" });
      }
    }, 100); // 10 ticks per second

    // Set patch rate for state sync
    this.setPatchRate(50); // 20 updates per second
  }

  onJoin(client: Client, options: any) {
    const player = new Player();
    player.name = options.name || `Player ${client.sessionId}`;
    player.x = Math.random() * 100;
    player.y = Math.random() * 100;

    this.state.players.set(client.sessionId, player);
    console.log(`${player.name} joined`);
  }

  onLeave(client: Client, consented: boolean) {
    this.state.players.delete(client.sessionId);
    console.log(`Client ${client.sessionId} left (consented: ${consented})`);
  }

  onDispose() {
    console.log('Room disposed');
  }
}
```

## Message Handling

Handle custom messages between clients and server with type-safe message handlers.

```typescript
export class BattleRoom extends Room<GameState> {
  onCreate(options: any) {
    this.setState(new GameState());

    // Register message handlers
    this.onMessage("move", (client, message) => {
      const player = this.state.players.get(client.sessionId);
      if (player) {
        player.x = message.x;
        player.y = message.y;
      }
    });

    this.onMessage("chat", (client, message) => {
      // Broadcast to all except sender
      this.broadcast("chat", {
        sender: client.sessionId,
        text: message.text,
        timestamp: Date.now()
      }, { except: client });
    });

    // Wildcard handler for all messages
    this.onMessage("*", (client, type, message) => {
      console.log(`Received message type: ${type}`, message);
    });
  }
}
```

## Authentication and Authorization

Implement authentication logic to validate clients before they join rooms.

```typescript
import { Room, Client } from '@colyseus/core';
import http from 'http';

export class SecureRoom extends Room {
  // Static onAuth runs before room join (recommended)
  static async onAuth(token: string, req: http.IncomingMessage): Promise<any> {
    try {
      // Validate JWT token
      const userData = await verifyToken(token);

      if (!userData || !userData.userId) {
        throw new Error("Invalid token");
      }

      // Return auth data to be available in client.auth
      return {
        userId: userData.userId,
        username: userData.username,
        role: userData.role
      };

    } catch (err) {
      throw new Error("Authentication failed");
    }
  }

  onCreate(options: any) {
    this.setState(new State());
  }

  onJoin(client: Client, options: any, auth: any) {
    // Access authenticated user data
    console.log(`User ${auth.username} (${auth.userId}) joined`);

    // Store auth data with client
    client.auth = auth;
  }

  onMessage("adminCommand", (client, message) => {
    if (client.auth.role !== 'admin') {
      client.error(403, "Insufficient permissions");
      return;
    }
    // Execute admin command
  });
}

async function verifyToken(token: string) {
  // Token verification logic
  return { userId: "123", username: "player1", role: "user" };
}
```

## Matchmaking API

Use the matchMaker API to create, join, and query rooms programmatically.

```typescript
import { matchMaker } from '@colyseus/core';

// Create a new room
const room = await matchMaker.createRoom('battle', {
  mapSize: 'large',
  mode: 'ranked'
});
console.log(`Room created: ${room.roomId}`);

// Join or create a room
const reservation = await matchMaker.joinOrCreate('battle', {
  skillLevel: 'intermediate'
});
console.log(`Reserved seat: ${reservation.sessionId}`);

// Find available rooms
const availableRooms = await matchMaker.query({
  name: 'battle',
  private: false,
  locked: false
});
console.log(`Found ${availableRooms.length} available rooms`);

// Join a specific room by ID
try {
  const seat = await matchMaker.joinById('room123', {
    password: 'secret'
  });
  console.log(`Joined room: ${seat.room.roomId}`);
} catch (err) {
  console.error('Failed to join room:', err.message);
}

// Reserve a seat with custom filtering
const filtered = await matchMaker.join('battle', {}, {
  filter: (room) => room.metadata?.region === 'us-west'
});
```

## Client Reconnection

Handle client disconnections gracefully and allow reconnection to preserve game state.

```typescript
import { Room, Client } from '@colyseus/core';

export class PersistentRoom extends Room {
  onCreate(options: any) {
    this.setState(new State());

    // Set custom seat reservation time
    this.setSeatReservationTime(30); // 30 seconds
  }

  async onLeave(client: Client, consented: boolean) {
    console.log(`Client ${client.sessionId} leaving (consented: ${consented})`);

    // Allow reconnection for 30 seconds
    try {
      if (!consented) {
        // Wait for reconnection
        const reconnected = await this.allowReconnection(client, 30);
        console.log(`Client ${reconnected.sessionId} reconnected!`);

        // Restore client-specific data
        reconnected.userData = client.userData;

      } else {
        // Clean up player data
        this.state.players.delete(client.sessionId);
      }

    } catch (err) {
      // Reconnection timeout, remove player
      console.log(`Reconnection timeout for ${client.sessionId}`);
      this.state.players.delete(client.sessionId);
    }
  }

  onJoin(client: Client, options: any) {
    // Check if this is a reconnection
    const existingPlayer = this.state.players.get(client.sessionId);

    if (existingPlayer) {
      console.log(`Player ${client.sessionId} reconnected`);
    } else {
      // New player
      const player = new Player();
      this.state.players.set(client.sessionId, player);
    }
  }
}
```

## Room Locking and Privacy

Control room visibility and access to manage matchmaking behavior.

```typescript
export class CustomRoom extends Room {
  maxClients = 10;

  onCreate(options: any) {
    this.setState(new State());

    // Set room as private (won't appear in listings)
    if (options.private) {
      this.setPrivate(true);
    }

    // Set custom metadata for filtering
    this.setMetadata({
      gameMode: options.mode,
      difficulty: 'hard',
      region: 'eu-west'
    });
  }

  onJoin(client: Client, options: any) {
    this.state.playerCount++;

    // Lock room when specific condition is met
    if (this.state.playerCount >= 4) {
      this.lock();
      console.log('Room locked at 4 players');
    }
  }

  onLeave(client: Client, consented: boolean) {
    this.state.playerCount--;

    // Unlock if room was auto-locked (not explicitly locked)
    if (this.locked && this.state.playerCount < 4) {
      this.unlock();
      console.log('Room unlocked');
    }
  }

  onMessage("lockRoom", (client, message) => {
    // Explicit lock by host
    this.lock();
    this.broadcast("roomLocked", { by: client.sessionId });
  });
}
```

## Broadcasting and Client Communication

Send messages to clients individually or broadcast to multiple clients with filtering options.

```typescript
export class ChatRoom extends Room {
  onCreate(options: any) {
    this.setState(new State());

    this.onMessage("whisper", (client, message) => {
      const targetClient = this.clients.find(c => c.sessionId === message.targetId);

      if (targetClient) {
        // Send to specific client
        targetClient.send("whisper", {
          from: client.sessionId,
          text: message.text
        });
      }
    });

    this.onMessage("teamChat", (client, message) => {
      const player = this.state.players.get(client.sessionId);

      // Broadcast to team members only
      this.clients.forEach(c => {
        const p = this.state.players.get(c.sessionId);
        if (p.team === player.team) {
          c.send("teamChat", {
            from: client.sessionId,
            text: message.text
          });
        }
      });
    });

    this.onMessage("globalAnnouncement", (client, message) => {
      // Broadcast to all except sender
      this.broadcast("announcement", {
        text: message.text,
        priority: "high"
      }, { except: client });

      // Send with afterNextPatch option
      this.broadcast("update", { data: "sync" }, {
        afterNextPatch: true
      });
    });
  }
}
```

## Clock and Timers

Use the built-in Clock for game loop timing and delayed/interval callbacks.

```typescript
import { Room } from '@colyseus/core';

export class TimedRoom extends Room {
  onCreate(options: any) {
    this.setState(new State());

    // Set simulation interval (game tick)
    this.setSimulationInterval((deltaTime) => {
      // deltaTime is in milliseconds since last tick
      this.updateGameLogic(deltaTime);
    }, 16.6); // ~60 FPS

    // Delayed callback
    this.clock.setTimeout(() => {
      this.broadcast("roundStart", { round: 1 });
    }, 5000); // 5 seconds

    // Repeating interval
    const intervalId = this.clock.setInterval(() => {
      this.broadcast("tick", { time: this.clock.elapsedTime });
    }, 1000); // every second

    // Clear interval after 10 seconds
    this.clock.setTimeout(() => {
      this.clock.clear(intervalId);
    }, 10000);
  }

  updateGameLogic(deltaTime: number) {
    // Update physics, AI, etc.
    this.state.players.forEach((player) => {
      player.energy += deltaTime * 0.1;
    });
  }

  onDispose() {
    // Clock is automatically cleared on dispose
    this.clock.clear();
  }
}
```

## Error Handling and Exception Management

Define custom exception handlers to catch and manage errors across room lifecycle methods.

```typescript
import { Room, RoomException } from '@colyseus/core';

export class SafeRoom extends Room {
  onCreate(options: any) {
    this.setState(new State());

    this.onMessage("riskyOperation", (client, message) => {
      // This will be caught by onUncaughtException
      throw new Error("Something went wrong");
    });
  }

  // Catch all exceptions from lifecycle methods
  onUncaughtException(error: RoomException, methodName: string) {
    console.error(`Exception in ${methodName}:`, error.message);
    console.error('Stack:', error.stack);

    // Get additional context
    if (error.client) {
      console.error(`Client: ${error.client.sessionId}`);
    }

    // Handle specific error types
    if (methodName === 'onJoin') {
      // Notify monitoring service
      this.notifyErrorService('Join failed', error);
    } else if (methodName === 'onMessage') {
      // Send error to client
      error.client?.error(500, "Server error processing message");
    }

    // Don't crash the room, just log
    return;
  }

  notifyErrorService(message: string, error: Error) {
    // Send to error tracking service
  }
}
```

## Redis Presence and Scaling

Configure Redis-based presence for horizontal scaling across multiple server processes.

```typescript
import { Server } from 'colyseus';
import { RedisPresence } from '@colyseus/redis-presence';
import { RedisDriver } from '@colyseus/redis-driver';
import { WebSocketTransport } from '@colyseus/ws-transport';

const gameServer = new Server({
  // Redis presence for multi-process coordination
  presence: new RedisPresence({
    host: 'localhost',
    port: 6379,
    password: 'redis_password',
    db: 0
  }),

  // Redis driver for room persistence
  driver: new RedisDriver({
    host: 'localhost',
    port: 6379,
  }),

  transport: new WebSocketTransport(),

  // Custom process selection for load balancing
  selectProcessIdToCreateRoom: async (roomName, clientOptions) => {
    // Custom logic to select which process handles room creation
    const processes = await getProcessStats();
    return processes.sort((a, b) => a.roomCount - b.roomCount)[0].processId;
  }
});

async function getProcessStats() {
  // Return array of { processId, roomCount }
  return [
    { processId: 'proc1', roomCount: 5 },
    { processId: 'proc2', roomCount: 3 }
  ];
}
```

## REST API Matchmaking Endpoints

Access matchmaking functionality via HTTP REST endpoints for external integrations.

```bash
# Get list of available rooms
curl http://localhost:2567/matchmake/

# Create a new room
curl -X POST http://localhost:2567/matchmake/create/battle \
  -H "Content-Type: application/json" \
  -d '{"mapSize": "large", "mode": "ranked"}'

# Join or create room
curl -X POST http://localhost:2567/matchmake/joinOrCreate/battle \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"skillLevel": "intermediate"}'

# Join specific room by ID
curl -X POST http://localhost:2567/matchmake/joinById/room123 \
  -H "Content-Type: application/json" \
  -d '{"password": "secret"}'

# Response format:
# {
#   "sessionId": "abc123",
#   "room": {
#     "roomId": "room123",
#     "processId": "proc1",
#     "name": "battle",
#     "clients": 2,
#     "maxClients": 4,
#     "metadata": { "gameMode": "ranked" }
#   }
# }
```

## Summary

Colyseus provides a complete solution for building multiplayer game servers with minimal boilerplate. The framework handles the complex aspects of networking, state synchronization, and connection management, allowing developers to focus on game logic. The Room-based architecture naturally isolates game sessions, while the Schema system provides efficient binary serialization with automatic delta compression for bandwidth optimization.

Common use cases include real-time action games, turn-based strategy games, collaborative applications, and live chat systems. The framework integrates seamlessly with existing Node.js applications through its transport-agnostic design, supporting WebSocket, uWebSockets, and TCP transports. Redis-based presence enables horizontal scaling across multiple server instances, while the matchmaking system provides flexible room creation and discovery. Authentication can be implemented using the companion @colyseus/auth package with JWT and OAuth support, or custom authentication logic in the Room's onAuth method.
