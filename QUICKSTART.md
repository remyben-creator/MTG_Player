# MTG Player - Quick Start

Get multiplayer working in 3 steps!

## Step 1: Start the Server (2 min)

```bash
cd server
npm install
npm run dev
```

Server runs on `ws://localhost:2567`

## Step 2: Setup ZeroTier (3 min)

1. Install ZeroTier: https://www.zerotier.com/download/
2. Create network at: https://my.zerotier.com/
3. Join network on all devices
4. Authorize members in dashboard
5. Find your ZeroTier IP:
   - Windows: `ipconfig` (look for ZeroTier adapter)
   - Mac/Linux: `ifconfig | grep zt`
   - Example: `192.168.191.42`

## Step 3: Run the App (1 min)

```bash
flutter pub get
flutter run
```

### Host:
1. Click "HOST GAME"
2. Server URL: `ws://<YOUR_ZEROTIER_IP>:2567`
3. CREATE ROOM
4. Share Room ID with friends

### Players:
1. Click "JOIN GAME"
2. Server URL: `ws://<HOST_ZEROTIER_IP>:2567`
3. Enter Room ID
4. JOIN ROOM

Done! 🎉

## File Structure

```
mtg_player/
├── server/                  # Colyseus game server
│   ├── src/
│   │   ├── index.ts        # Server entry point
│   │   ├── rooms/
│   │   │   └── MTGGameRoom.ts  # Game room logic
│   │   └── schema/
│   │       └── GameState.ts    # Game state schema
│   └── package.json
├── lib/
│   ├── services/
│   │   └── colyseus_service.dart   # Flutter Colyseus client
│   └── screens/
│       └── server_screens/
│           ├── host_screen.dart    # Host game UI
│           ├── join_screen.dart    # Join game UI
│           └── lobby_screen.dart   # Lobby UI
├── MULTIPLAYER_SETUP.md    # Detailed setup guide
├── QUICKSTART.md           # This file
└── COLYSEUS_CONTEXT.md     # Colyseus reference
```

## What's Working

- ✅ Server creation and room management
- ✅ Host/Join game UI
- ✅ Lobby with room ID sharing
- ✅ Player join/leave tracking
- ✅ Real-time state synchronization
- ✅ ZeroTier networking support

## What's Next

- ⏳ Implement game board with card display
- ⏳ Add drag-and-drop for cards
- ⏳ Add zones (hand, battlefield, graveyard, etc.)
- ⏳ Add life counters
- ⏳ Add chat

## Need Help?

See `MULTIPLAYER_SETUP.md` for detailed troubleshooting.
