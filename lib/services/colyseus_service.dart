import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

/// Simple Colyseus client implementation using WebSockets
class ColyseusService {
  static final ColyseusService _instance = ColyseusService._internal();
  factory ColyseusService() => _instance;
  ColyseusService._internal();

  String? _serverUrl;
  WebSocketChannel? _channel;
  String? _roomId;
  String? _sessionId;

  // Stream controllers for game events
  final _onStateChangeController = StreamController<Map<String, dynamic>>.broadcast();
  final _onPlayerJoinedController = StreamController<Map<String, dynamic>>.broadcast();
  final _onPlayerLeftController = StreamController<Map<String, dynamic>>.broadcast();
  final _onChatController = StreamController<Map<String, dynamic>>.broadcast();
  final _onConnectionErrorController = StreamController<String>.broadcast();

  // Public streams
  Stream<Map<String, dynamic>> get onStateChange => _onStateChangeController.stream;
  Stream<Map<String, dynamic>> get onPlayerJoined => _onPlayerJoinedController.stream;
  Stream<Map<String, dynamic>> get onPlayerLeft => _onPlayerLeftController.stream;
  Stream<Map<String, dynamic>> get onChat => _onChatController.stream;
  Stream<String> get onConnectionError => _onConnectionErrorController.stream;

  // Getters
  bool get isConnected => _channel != null;
  String? get sessionId => _sessionId;
  String? get roomId => _roomId;

  /// Initialize with server URL
  void initialize(String serverUrl) {
    _serverUrl = serverUrl;
    print('[ColyseusService] Initialized with server: $serverUrl');
  }

  /// Create a new game room (host)
  Future<void> createRoom({
    required String playerName,
    int startingLife = 40,
  }) async {
    if (_serverUrl == null) {
      throw Exception('Client not initialized. Call initialize() first.');
    }

    try {
      print('[ColyseusService] Creating room as $playerName');

      // Make HTTP request to create room
      final httpUrl = _serverUrl!.replaceFirst('ws://', 'http://').replaceFirst('wss://', 'https://');
      final response = await http.post(
        Uri.parse('$httpUrl/matchmake/create/mtg_game'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'playerName': playerName,
          'startingLife': startingLife,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create room: ${response.body}');
      }

      final data = jsonDecode(response.body);
      _roomId = data['room']['roomId'];
      _sessionId = data['sessionId'];

      print('[ColyseusService] Room created: $_roomId, Session: $_sessionId');

      // Connect to the room via WebSocket
      await _connectToRoom(_roomId!, _sessionId!);
    } catch (e) {
      print('[ColyseusService] Error creating room: $e');
      _onConnectionErrorController.add('Failed to create room: $e');
      rethrow;
    }
  }

  /// Join an existing game room
  Future<void> joinRoom({
    required String roomId,
    required String playerName,
    int startingLife = 40,
  }) async {
    if (_serverUrl == null) {
      throw Exception('Client not initialized. Call initialize() first.');
    }

    try {
      print('[ColyseusService] Joining room $roomId as $playerName');

      // Make HTTP request to join room
      final httpUrl = _serverUrl!.replaceFirst('ws://', 'http://').replaceFirst('wss://', 'https://');
      final response = await http.post(
        Uri.parse('$httpUrl/matchmake/joinById/$roomId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'playerName': playerName,
          'startingLife': startingLife,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to join room: ${response.body}');
      }

      final data = jsonDecode(response.body);
      _roomId = data['room']['roomId'];
      _sessionId = data['sessionId'];

      print('[ColyseusService] Joined room: $_roomId, Session: $_sessionId');

      // Connect to the room via WebSocket
      await _connectToRoom(_roomId!, _sessionId!);
    } catch (e) {
      print('[ColyseusService] Error joining room: $e');
      _onConnectionErrorController.add('Failed to join room: $e');
      rethrow;
    }
  }

  /// Connect to room via WebSocket
  Future<void> _connectToRoom(String roomId, String sessionId) async {
    try {
      final wsUrl = '$_serverUrl/$roomId?sessionId=$sessionId';
      print('[ColyseusService] Connecting to WebSocket: $wsUrl');

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Listen to messages
      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          print('[ColyseusService] WebSocket error: $error');
          _onConnectionErrorController.add('Connection error: $error');
        },
        onDone: () {
          print('[ColyseusService] WebSocket closed');
          _cleanup();
        },
      );

      print('[ColyseusService] WebSocket connected');
    } catch (e) {
      print('[ColyseusService] Error connecting to room: $e');
      throw Exception('Failed to connect to room: $e');
    }
  }

  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic rawMessage) {
    try {
      // Colyseus sends messages as JSON
      final message = jsonDecode(rawMessage);

      if (message is! List || message.isEmpty) return;

      final type = message[0];
      final data = message.length > 1 ? message[1] : null;

      switch (type) {
        case 'playerJoined':
          print('[ColyseusService] Player joined: $data');
          _onPlayerJoinedController.add(data as Map<String, dynamic>);
          break;

        case 'playerLeft':
          print('[ColyseusService] Player left: $data');
          _onPlayerLeftController.add(data as Map<String, dynamic>);
          break;

        case 'gameStarted':
          print('[ColyseusService] Game started: $data');
          break;

        case 'chat':
          _onChatController.add(data as Map<String, dynamic>);
          break;

        case 'stateChange':
          _onStateChangeController.add(data as Map<String, dynamic>);
          break;

        default:
          print('[ColyseusService] Unknown message type: $type');
      }
    } catch (e) {
      print('[ColyseusService] Error handling message: $e');
    }
  }

  // ===== Game Actions =====

  /// Send a message to the room
  void _sendMessage(String type, [Map<String, dynamic>? data]) {
    if (_channel == null) {
      print('[ColyseusService] Cannot send message: not connected');
      return;
    }

    final message = data != null ? [type, data] : [type];
    _channel!.sink.add(jsonEncode(message));
  }

  /// Move a card between zones
  void moveCard({
    required String cardId,
    required String fromZone,
    required String toZone,
    double? x,
    double? y,
  }) {
    _sendMessage('moveCard', {
      'cardId': cardId,
      'fromZone': fromZone,
      'toZone': toZone,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
    });
  }

  /// Add a new card to a zone
  void addCard({
    required String zone,
    required Map<String, dynamic> cardData,
  }) {
    _sendMessage('addCard', {
      'zone': zone,
      'cardData': cardData,
    });
  }

  /// Tap or untap a card
  void tapCard(String cardId, bool tapped) {
    _sendMessage('tapCard', {
      'cardId': cardId,
      'tapped': tapped,
    });
  }

  /// Move a card's position on the battlefield
  void moveCardPosition(String cardId, double x, double y) {
    _sendMessage('moveCardPosition', {
      'cardId': cardId,
      'x': x,
      'y': y,
    });
  }

  /// Set counters on a card
  void setCounters(String cardId, int counters) {
    _sendMessage('setCounters', {
      'cardId': cardId,
      'counters': counters,
    });
  }

  /// Flip a card
  void flipCard(String cardId) {
    _sendMessage('flipCard', {
      'cardId': cardId,
    });
  }

  /// Set life total
  void setLife(int life) {
    _sendMessage('setLife', {'life': life});
  }

  /// Set poison counters
  void setPoison(int poison) {
    _sendMessage('setPoison', {'poison': poison});
  }

  /// Draw a card
  void drawCard() {
    _sendMessage('drawCard');
  }

  /// Shuffle library
  void shuffle() {
    _sendMessage('shuffle');
  }

  /// Send chat message
  void sendChat(String text) {
    _sendMessage('chat', {'text': text});
  }

  /// Leave the current room
  Future<void> leaveRoom() async {
    if (_channel != null) {
      await _channel!.sink.close();
      _cleanup();
    }
  }

  /// Clean up resources
  void _cleanup() {
    _channel = null;
    _roomId = null;
    _sessionId = null;
  }

  /// Dispose of the service
  void dispose() {
    _cleanup();
    _onStateChangeController.close();
    _onPlayerJoinedController.close();
    _onPlayerLeftController.close();
    _onChatController.close();
    _onConnectionErrorController.close();
  }
}
