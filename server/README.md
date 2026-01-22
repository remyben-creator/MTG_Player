# MTG Player - Colyseus Server

Digital tabletop simulator server for Magic: The Gathering. Supports up to 4 players with real-time state synchronization.

## What This Server Does

This is NOT a rules engine. It's a digital tabletop that syncs game state between players:
- Card positions and states (tapped, counters, flipped)
- Player zones (hand, battlefield, graveyard, exile, library, command zone)
- Life totals and poison counters
- Players can do whatever they want - just like playing with physical cards

## Quick Start

### Install Dependencies
```bash
npm install
```

### Run Development Server
```bash
npm run dev
```

The server will start on `ws://localhost:2567`

### Build for Production
```bash
npm run build
npm run serve
```

## Testing Locally

1. **Start the server:**
   ```bash
   npm run dev
   ```

2. **Find your local IP:**
   - Windows: `ipconfig` (look for IPv4 Address)
   - Mac/Linux: `ifconfig` or `ip addr`

3. **Use with ZeroTier:**
   - Install ZeroTier and create/join a network
   - Your ZeroTier IP will be something like `192.168.191.x`
   - Friends connect to: `ws://YOUR_ZEROTIER_IP:2567`

## API Endpoints

- `GET /health` - Server health check
- `GET /rooms` - List available game rooms
- `ws://localhost:2567` - WebSocket endpoint

## Room Messages (Client → Server)

All messages are sent to the `mtg_game` room:

**Card Actions:**
- `moveCard` - Move card between zones
  ```json
  { "cardId": "123", "fromZone": "hand", "toZone": "battlefield", "x": 100, "y": 200 }
  ```
- `addCard` - Add new card to zone
  ```json
  { "zone": "hand", "cardData": { "id": "123", "name": "Lightning Bolt", "imageUrl": "..." } }
  ```
- `tapCard` - Tap/untap a card
  ```json
  { "cardId": "123", "tapped": true }
  ```
- `moveCardPosition` - Move card on battlefield
  ```json
  { "cardId": "123", "x": 150, "y": 250 }
  ```
- `setCounters` - Set counters on card
  ```json
  { "cardId": "123", "counters": 3 }
  ```
- `flipCard` - Flip card face down
  ```json
  { "cardId": "123" }
  ```

**Player Actions:**
- `setLife` - Change life total
  ```json
  { "life": 35 }
  ```
- `setPoison` - Change poison counters
  ```json
  { "poison": 2 }
  ```
- `drawCard` - Draw a card (decrements library count)
  ```json
  {}
  ```
- `shuffle` - Notify others you shuffled
  ```json
  {}
  ```

**Communication:**
- `chat` - Send chat message
  ```json
  { "text": "Good game!" }
  ```

## Broadcasts (Server → All Clients)

- `playerJoined` - New player joined
- `playerLeft` - Player left
- `playerDisconnected` - Player lost connection
- `playerReconnected` - Player reconnected
- `gameStarted` - Game started (2+ players)
- `chat` - Chat message
- `playerShuffled` - Player shuffled their library

## State Schema

See `src/schema/GameState.ts` for the full state structure. The state automatically syncs to all clients via Colyseus delta compression.

## Configuration

- **Max Players:** 4 (set in `MTGGameRoom.ts`)
- **Reconnection Timeout:** 60 seconds
- **Patch Rate:** 50ms (20 updates/sec)
- **Default Life Total:** 40 (Commander)

## Port Configuration

Default port is `2567`. Change via environment variable:
```bash
PORT=3000 npm run dev
```

---

## Production Deployment Plans (ZeroTier + Auto-Start)

### Vision: User-Friendly Peer-to-Peer Gaming

The goal is to create a production-ready experience where users never need to touch the terminal. The server will automatically start when a user clicks "Host Game" in the Flutter app.

### Recommended Architecture

**1. Desktop Users Can HOST (Windows/Mac/Linux)**
- Click "Host Game" → Flutter app auto-starts bundled server executable
- Server runs locally on host's machine
- Host's ZeroTier IP is automatically detected and used
- No terminal, no manual server startup

**2. All Users Can JOIN (Desktop + Mobile)**
- Click "Join Game" → enter Room ID
- App connects to host via ZeroTier network
- Works on all platforms (Windows, Mac, Linux, iOS, Android)

**3. Everyone Uses ZeroTier Network**
- **One-time setup for all users:**
  1. Install ZeroTier app (GUI-based, no terminal)
  2. Join the "MTG Player Network" (enter Network ID in ZeroTier GUI)
  3. Get authorized by network admin (or auto-approve enabled)
- **After setup:** No terminal, no configuration needed
- **Every session:** Just open the app and play

**4. Server Discovery & Room Management**
- **Option A:** Simple web API that maps Room IDs to host ZeroTier IPs
  - Lightweight cloud function (free tier on Railway/Vercel)
  - Maps `roomId` → `hostZeroTierIP`
  - Join screen queries this API when user enters Room ID
- **Option B:** Use ZeroTier's built-in network discovery
  - Query ZeroTier API for active members
  - Discover hosts advertising game rooms
  - Peer-to-peer service discovery

### Implementation Steps (TODO)

#### Phase 1: Package Server as Executable
```bash
# Install pkg for bundling Node.js apps
npm install -g pkg

# Build standalone executables
pkg package.json --targets node18-win-x64,node18-macos-x64,node18-linux-x64 --output dist/server

# Results:
# - dist/server-win.exe (Windows)
# - dist/server-macos (macOS)
# - dist/server-linux (Linux)
```

Bundle these executables with the Flutter app in `assets/server/`

#### Phase 2: Flutter Auto-Start Server
```dart
// In lib/screens/server_screens/host_screen.dart

import 'dart:io';

Future<void> _startServerAndHost() async {
  // 1. Determine platform-specific executable path
  String execPath;
  if (Platform.isWindows) execPath = 'assets/server/server-win.exe';
  else if (Platform.isMacOS) execPath = 'assets/server/server-macos';
  else if (Platform.isLinux) execPath = 'assets/server/server-linux';

  // 2. Start server as subprocess
  final process = await Process.start(execPath, []);

  // 3. Wait for server to be ready (2-3 seconds)
  await Future.delayed(Duration(seconds: 2));

  // 4. Auto-detect ZeroTier IP
  final zeroTierIP = await _getZeroTierIP();

  // 5. Initialize Colyseus with host's ZeroTier IP
  _colyseusService.initialize('ws://$zeroTierIP:2567');

  // 6. Create room
  await _colyseusService.createRoom(playerName: _playerName);

  // 7. Server is now running, room is created!
}

Future<String> _getZeroTierIP() async {
  final interfaces = await NetworkInterface.list();
  for (var interface in interfaces) {
    // ZeroTier interfaces typically start with 'zt'
    if (interface.name.toLowerCase().contains('zt')) {
      return interface.addresses.first.address;
    }
  }
  throw Exception('ZeroTier not connected');
}
```

#### Phase 3: Room Discovery Service (Optional)
```typescript
// Simple serverless function on Railway/Vercel (free tier)
// Maps Room IDs to Host IPs for easier joining

import { FastAPI } from 'fastapi';

const roomRegistry = new Map<string, string>();

app.post('/register-room', (req, res) => {
  const { roomId, hostIP } = req.body;
  roomRegistry.set(roomId, hostIP);
  res.json({ success: true });
});

app.get('/resolve-room/:roomId', (req, res) => {
  const hostIP = roomRegistry.get(req.params.roomId);
  if (hostIP) {
    res.json({ hostIP });
  } else {
    res.status(404).json({ error: 'Room not found' });
  }
});
```

Host registers room after creation, joiners query to get host IP.

### User Experience (Final Vision)

**For Hosts:**
1. Open MTG Player app
2. Click "Host Game"
3. App shows "Starting server..." (2-3 seconds)
4. Room created! Share Room ID with friends
5. Play!

**For Players:**
1. Open MTG Player app
2. Click "Join Game"
3. Enter Room ID
4. App automatically finds host and connects
5. Play!

**No terminal. No manual server setup. Just works.** ✨

### Benefits

✅ **Completely Free:** No cloud hosting costs, uses ZeroTier's free tier
✅ **No Terminal:** Users never see command line
✅ **Cross-Platform:** Works on Desktop (host/join) and Mobile (join)
✅ **Peer-to-Peer:** Low latency, direct connections
✅ **Simple Setup:** One-time ZeroTier install, then seamless
✅ **Easy Migration:** Can move to cloud server later with same code

### Platform Support

| Platform | Can Host | Can Join | Notes |
|----------|----------|----------|-------|
| Windows  | ✅       | ✅       | Full support |
| macOS    | ✅       | ✅       | Full support |
| Linux    | ✅       | ✅       | Full support |
| Android  | ⚠️       | ✅       | Join only (battery concerns for hosting) |
| iOS      | ❌       | ✅       | Join only (App Store restrictions on background servers) |

### Future Considerations

- **Alternative:** Rewrite server in pure Dart using `shelf` package
  - No need to bundle Node.js executables
  - Smaller app size
  - Could enable mobile hosting
  - More Flutter-native

- **Fallback:** Option to use cloud server if ZeroTier setup is too complex
  - Can deploy same server code to Railway ($5/month)
  - Users choose: "P2P Mode" or "Cloud Mode"
  - Gradual migration path

---

**Current Status:** Development/Testing Phase (terminal required)
**Next Steps:** Implement Phase 1-3 above for production-ready release
