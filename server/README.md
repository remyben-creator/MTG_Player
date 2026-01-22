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
