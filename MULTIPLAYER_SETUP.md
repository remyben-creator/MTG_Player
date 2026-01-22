# MTG Player - Multiplayer Setup Guide

This guide will help you set up and test the multiplayer functionality of MTG Player using ZeroTier for free, hassle-free networking.

## Overview

The MTG Player multiplayer system uses:
- **Colyseus** - Real-time multiplayer framework
- **ZeroTier** - Free virtual LAN (no port forwarding needed!)
- **Node.js Server** - Game state synchronization server

## What You'll Build

A proof-of-concept digital MTG tabletop where:
- Up to 4 players can join a game
- Players can freely move cards between zones (hand, battlefield, graveyard, etc.)
- Everyone sees real-time updates
- No rules enforcement - just like playing with physical cards!

---

## Part 1: Setting Up ZeroTier (5 minutes)

ZeroTier creates a virtual LAN so your friends can connect to your local server without port forwarding.

### Step 1: Install ZeroTier

**Host (You):**
1. Download ZeroTier from https://www.zerotier.com/download/
2. Install and run it

**Friends (Players joining):**
1. Same as above - everyone needs ZeroTier installed

### Step 2: Create a Network

**Host only:**
1. Go to https://my.zerotier.com/
2. Sign up for a free account
3. Click "Create A Network"
4. Copy the **Network ID** (looks like `a84ac5c10a1234ab`)
5. Give the network a name (e.g., "MTG Game Night")

### Step 3: Join the Network

**Everyone (host and all players):**

**Windows:**
1. Right-click the ZeroTier icon in system tray
2. Select "Join Network"
3. Enter the Network ID
4. Click "Join"

**Mac:**
1. Click ZeroTier menu bar icon
2. Select "Join Network"
3. Enter Network ID

**Linux:**
```bash
sudo zerotier-cli join <NETWORK_ID>
```

### Step 4: Authorize Players

**Host:**
1. Go back to https://my.zerotier.com/
2. Click on your network
3. Scroll to "Members" section
4. Check the box next to each member to authorize them

### Step 5: Find Your ZeroTier IP

**Host needs to find their ZeroTier IP to share with players:**

**Windows:**
```bash
ipconfig
```
Look for "ZeroTier One" adapter, find the IPv4 address (usually `192.168.191.x`)

**Mac/Linux:**
```bash
ifconfig | grep zt
# or
ip addr | grep zt
```

**Or use ZeroTier UI:**
- Right-click ZeroTier icon → Click your network name → Your IP is shown

**Example:** Your ZeroTier IP might be `192.168.191.42`

---

## Part 2: Setting Up the Server (5 minutes)

### Step 1: Install Node.js

If you don't have Node.js installed:
1. Download from https://nodejs.org/ (get the LTS version)
2. Install with default options
3. Verify installation:
   ```bash
   node --version
   npm --version
   ```

### Step 2: Install Server Dependencies

Navigate to the server directory and install dependencies:

```bash
cd server
npm install
```

### Step 3: Start the Server

**Development mode (with auto-restart):**
```bash
npm run dev
```

**OR regular mode:**
```bash
npm start
```

You should see:
```
🎮 MTG Player Server listening on port 2567
📡 WebSocket endpoint: ws://localhost:2567
🌐 HTTP endpoint: http://localhost:2567
```

### Step 4: Test Server Health

Open your browser and go to:
```
http://localhost:2567/health
```

You should see: `{"status":"ok","rooms":0}`

**Keep this terminal window open!** The server needs to stay running.

---

## Part 3: Testing the Flutter App

### Step 1: Install Flutter Dependencies

In the project root directory:

```bash
flutter pub get
```

### Step 2: Run the App (Host)

```bash
flutter run
```

**In the app:**
1. Click "HOST GAME"
2. **Important:** Change the Server URL from `ws://localhost:2567` to `ws://<YOUR_ZEROTIER_IP>:2567`
   - Example: `ws://192.168.191.42:2567`
3. Enter your player name
4. Click "CREATE ROOM"
5. **Copy the Room ID** and share it with your friends!

### Step 3: Run the App (Other Players)

**Your friends on their devices:**

1. Make sure they're connected to the same ZeroTier network
2. Run the app
3. Click "JOIN GAME"
4. Enter Server URL: `ws://<HOST_ZEROTIER_IP>:2567`
   - This is YOUR ZeroTier IP that you shared with them
5. Enter the Room ID you gave them
6. Enter their player name
7. Click "JOIN ROOM"

---

## Part 4: Troubleshooting

### "Failed to connect to server"

**Check ZeroTier connection:**
```bash
# Host: ping a player's ZeroTier IP
ping 192.168.191.43

# Player: ping host's ZeroTier IP
ping 192.168.191.42
```

If ping doesn't work:
- Make sure everyone is authorized in the ZeroTier network dashboard
- Restart ZeroTier
- Make sure you're using ZeroTier IPs, not regular local IPs

### "Failed to create/join room"

- Make sure the server is still running
- Check the server terminal for error messages
- Try restarting the server (`Ctrl+C` then `npm run dev`)

### Server won't start

**Port already in use:**
```bash
# Windows
netstat -ano | findstr :2567
taskkill /PID <PID> /F

# Mac/Linux
lsof -ti:2567 | xargs kill
```

**Missing dependencies:**
```bash
cd server
rm -rf node_modules package-lock.json
npm install
```

### Flutter build errors

```bash
flutter clean
flutter pub get
flutter run
```

---

## Testing Checklist

Once connected, test these features:

- [ ] Can you see the lobby screen with room ID?
- [ ] Do other players appear when they join?
- [ ] Does the player count update?
- [ ] Can you copy the room ID?
- [ ] Does everyone stay connected?

---

## Network Comparison

### What You're Using (ZeroTier):
- ✅ Free
- ✅ No port forwarding
- ✅ Works on any network (home, mobile data, university, etc.)
- ✅ Secure (encrypted)
- ✅ Easy setup (5 minutes)
- ⚠️  Everyone needs to install ZeroTier

### Port Forwarding (Not using):
- ❌ Complex setup
- ❌ Doesn't work on mobile data
- ❌ Requires router access
- ❌ Security risks

### Cloud Server (Future option):
- ✅ No VPN needed
- ✅ Works everywhere
- ✅ Professional solution
- ❌ Costs $5-10/month
- **Migration Path:** Your Colyseus code will work the same way!

---

## Next Steps

Now that you have the proof-of-concept working:

1. **Test with your friend:** Have them join your game over ZeroTier
2. **If it works:** You've validated the architecture!
3. **Future development:**
   - Add the actual game board with card rendering
   - Implement drag-and-drop for cards
   - Add chat functionality
   - Add life counters and zones
   - Eventually migrate to a cheap cloud server ($5/month) if you want

---

## Quick Reference

### Host Checklist:
1. ZeroTier installed and network created
2. Server running (`npm run dev` in `server/` directory)
3. Note your ZeroTier IP
4. Share Network ID with friends
5. Share your ZeroTier IP with friends
6. Create room and share Room ID

### Player Checklist:
1. ZeroTier installed
2. Joined host's ZeroTier network
3. Got host's ZeroTier IP
4. Got Room ID from host
5. Enter server URL: `ws://<HOST_IP>:2567`
6. Enter Room ID and join!

---

## Support

Having issues? Check:
- Server terminal for error messages
- ZeroTier is running and you're authorized
- Everyone is using the ZeroTier IP addresses
- Firewall isn't blocking ZeroTier or Node.js

## Architecture Diagram

```
[Player 1 Device]     [Player 2 Device]     [Player 3 Device]
       |                    |                    |
       |                    |                    |
       +--------------------+--------------------+
                            |
                    [ZeroTier Network]
                     (Virtual LAN)
                            |
                            |
                   [Your Computer]
                   - Node.js Server (Port 2567)
                   - Colyseus (Game State)
                            |
                   Syncs game state to
                   all connected players
```

Good luck and have fun! 🎮✨
