import { Schema, type, MapSchema, ArraySchema } from '@colyseus/schema';

/**
 * Represents a card on the battlefield or in any zone
 */
export class Card extends Schema {
  @type("string") id: string = "";
  @type("string") name: string = "";
  @type("string") imageUrl: string = "";
  @type("boolean") tapped: boolean = false;
  @type("number") x: number = 0; // Position on battlefield
  @type("number") y: number = 0;
  @type("number") counters: number = 0; // Generic counters
  @type("boolean") flipped: boolean = false;
  @type("string") owner: string = ""; // Player session ID who owns this card
}

/**
 * Represents a player's zones and state
 */
export class Player extends Schema {
  @type("string") sessionId: string = "";
  @type("string") name: string = "";
  @type("number") life: number = 40; // Default to 40 for Commander
  @type("number") poison: number = 0;

  // Card zones
  @type({ map: Card }) hand = new MapSchema<Card>();
  @type({ map: Card }) battlefield = new MapSchema<Card>();
  @type({ map: Card }) graveyard = new MapSchema<Card>();
  @type({ map: Card }) exile = new MapSchema<Card>();
  @type({ map: Card }) library = new MapSchema<Card>();
  @type({ map: Card }) commandZone = new MapSchema<Card>(); // For commanders

  @type("number") librarySize: number = 0; // Track library size without revealing
  @type("boolean") isConnected: boolean = true;
}

/**
 * Main game state - just player zones and card states
 */
export class GameState extends Schema {
  @type({ map: Player }) players = new MapSchema<Player>();
  @type("string") gameStatus: string = "waiting"; // waiting, active, finished
  @type("number") timestamp: number = 0; // For ordering events
}
