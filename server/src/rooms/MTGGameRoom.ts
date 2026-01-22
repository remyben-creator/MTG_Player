import { Room, Client } from '@colyseus/core';
import { GameState, Player, Card } from '../schema/GameState';

export class MTGGameRoom extends Room<GameState> {
  maxClients = 4; // Support up to 4 players (Commander!)

  onCreate(options: any) {
    this.setState(new GameState());
    this.state.gameStatus = "waiting";

    console.log(`[MTGGameRoom] Room created`);

    // Set up message handlers for state changes
    this.setupMessageHandlers();

    // Update patch rate for smooth real-time sync
    this.setPatchRate(50); // 20 updates per second
  }

  onJoin(client: Client, options: any) {
    console.log(`[MTGGameRoom] ${client.sessionId} joined as ${options.playerName}`);

    // Create player
    const player = new Player();
    player.sessionId = client.sessionId;
    player.name = options.playerName || `Player ${this.clients.length}`;
    player.life = options.startingLife || 40; // Default to Commander life total
    player.isConnected = true;

    this.state.players.set(client.sessionId, player);

    // Notify all clients
    this.broadcast("playerJoined", {
      sessionId: client.sessionId,
      playerName: player.name,
      playerCount: this.state.players.size
    });

    // If we have 2+ players, mark game as active
    if (this.state.players.size >= 2 && this.state.gameStatus === "waiting") {
      this.state.gameStatus = "active";
      this.broadcast("gameStarted", {
        playerCount: this.state.players.size
      });
    }
  }

  onLeave(client: Client, consented: boolean) {
    console.log(`[MTGGameRoom] ${client.sessionId} left`);

    const player = this.state.players.get(client.sessionId);
    if (!player) return;

    if (!consented && this.state.gameStatus === "active") {
      // Allow reconnection for 60 seconds
      player.isConnected = false;
      this.broadcast("playerDisconnected", { sessionId: client.sessionId });

      this.allowReconnection(client, 60).then(() => {
        console.log(`[MTGGameRoom] ${client.sessionId} reconnected`);
        player.isConnected = true;
        this.broadcast("playerReconnected", { sessionId: client.sessionId });
      }).catch(() => {
        console.log(`[MTGGameRoom] ${client.sessionId} disconnected permanently`);
        this.state.players.delete(client.sessionId);
        this.broadcast("playerLeft", { sessionId: client.sessionId });
      });
    } else {
      this.state.players.delete(client.sessionId);
      this.broadcast("playerLeft", { sessionId: client.sessionId });
    }
  }

  private setupMessageHandlers() {
    // Move card between zones
    this.onMessage("moveCard", (client, message) => {
      const { cardId, fromZone, toZone, x, y } = message;
      const player = this.state.players.get(client.sessionId);
      if (!player) return;

      // Get card from source zone
      let card: Card | undefined;
      const fromZoneMap = this.getZone(player, fromZone);
      if (fromZoneMap) {
        card = fromZoneMap.get(cardId);
        fromZoneMap.delete(cardId);
      }

      // If card exists, move it to destination zone
      if (card) {
        const toZoneMap = this.getZone(player, toZone);
        if (toZoneMap) {
          if (toZone === "battlefield") {
            card.x = x || 0;
            card.y = y || 0;
          }
          toZoneMap.set(cardId, card);
        }
      }

      this.state.timestamp = Date.now();
    });

    // Add card to zone (drawing from library, creating tokens, etc.)
    this.onMessage("addCard", (client, message) => {
      const { zone, cardData } = message;
      const player = this.state.players.get(client.sessionId);
      if (!player) return;

      const card = new Card();
      card.id = cardData.id;
      card.name = cardData.name;
      card.imageUrl = cardData.imageUrl || "";
      card.owner = client.sessionId;
      card.x = cardData.x || 0;
      card.y = cardData.y || 0;

      const zoneMap = this.getZone(player, zone);
      if (zoneMap) {
        zoneMap.set(card.id, card);
      }

      this.state.timestamp = Date.now();
    });

    // Tap/untap card
    this.onMessage("tapCard", (client, message) => {
      const player = this.state.players.get(client.sessionId);
      if (!player) return;

      const card = player.battlefield.get(message.cardId);
      if (card) {
        card.tapped = message.tapped !== undefined ? message.tapped : !card.tapped;
        this.state.timestamp = Date.now();
      }
    });

    // Move card on battlefield
    this.onMessage("moveCardPosition", (client, message) => {
      const { cardId, x, y } = message;
      const player = this.state.players.get(client.sessionId);
      if (!player) return;

      const card = player.battlefield.get(cardId);
      if (card) {
        card.x = x;
        card.y = y;
        this.state.timestamp = Date.now();
      }
    });

    // Change card counters
    this.onMessage("setCounters", (client, message) => {
      const { cardId, counters } = message;
      const player = this.state.players.get(client.sessionId);
      if (!player) return;

      const card = player.battlefield.get(cardId);
      if (card) {
        card.counters = counters;
        this.state.timestamp = Date.now();
      }
    });

    // Flip card
    this.onMessage("flipCard", (client, message) => {
      const player = this.state.players.get(client.sessionId);
      if (!player) return;

      const card = player.battlefield.get(message.cardId);
      if (card) {
        card.flipped = !card.flipped;
        this.state.timestamp = Date.now();
      }
    });

    // Change life total
    this.onMessage("setLife", (client, message) => {
      const player = this.state.players.get(client.sessionId);
      if (player) {
        player.life = message.life;
        this.state.timestamp = Date.now();
      }
    });

    // Change poison counters
    this.onMessage("setPoison", (client, message) => {
      const player = this.state.players.get(client.sessionId);
      if (player) {
        player.poison = message.poison;
        this.state.timestamp = Date.now();
      }
    });

    // Shuffle library
    this.onMessage("shuffle", (client, message) => {
      const player = this.state.players.get(client.sessionId);
      if (player) {
        // Just notify others, actual shuffling happens client-side
        this.broadcast("playerShuffled", {
          sessionId: client.sessionId,
          playerName: player.name
        }, { except: client });
      }
    });

    // Chat message
    this.onMessage("chat", (client, message) => {
      const player = this.state.players.get(client.sessionId);
      this.broadcast("chat", {
        sender: client.sessionId,
        senderName: player?.name || "Unknown",
        text: message.text,
        timestamp: Date.now()
      });
    });

    // Draw card (decrements library count)
    this.onMessage("drawCard", (client, message) => {
      const player = this.state.players.get(client.sessionId);
      if (player && player.librarySize > 0) {
        player.librarySize--;
        this.state.timestamp = Date.now();
      }
    });
  }

  private getZone(player: Player, zoneName: string): MapSchema<Card> | undefined {
    switch (zoneName) {
      case "hand": return player.hand;
      case "battlefield": return player.battlefield;
      case "graveyard": return player.graveyard;
      case "exile": return player.exile;
      case "library": return player.library;
      case "commandZone": return player.commandZone;
      default: return undefined;
    }
  }

  onDispose() {
    console.log(`[MTGGameRoom] Room disposed`);
  }
}
