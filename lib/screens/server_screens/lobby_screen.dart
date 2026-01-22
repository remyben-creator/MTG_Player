import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/colyseus_service.dart';

class LobbyScreen extends StatefulWidget {
  final String roomId;
  final bool isHost;

  const LobbyScreen({
    super.key,
    required this.roomId,
    required this.isHost,
  });

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final _colyseusService = ColyseusService();
  int _playerCount = 1;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    // Listen for players joining
    _colyseusService.onPlayerJoined.listen((data) {
      setState(() {
        _playerCount = data['playerCount'] ?? _playerCount;
      });
    });

    // Listen for players leaving
    _colyseusService.onPlayerLeft.listen((data) {
      setState(() {
        _playerCount--;
      });
    });

    // Listen for state changes (game start will be handled via state)
    _colyseusService.onStateChange.listen((state) {
      // TODO: Navigate to game screen when game starts
      print('State changed: $state');
    });
  }

  void _copyRoomId() {
    Clipboard.setData(ClipboardData(text: widget.roomId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Room ID copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _leaveRoom() async {
    await _colyseusService.leaveRoom();
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _leaveRoom();
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            // MTG-themed background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF5c320e),
                    const Color(0xFF45260a),
                    const Color(0xFF2e1907),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  // AppBar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Color(0xFFCD853F)),
                          onPressed: _leaveRoom,
                        ),
                        Expanded(
                          child: Center(
                            child: Stack(
                              children: [
                                Text(
                                  'LOBBY',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    fontSize: 24,
                                    foreground: Paint()
                                      ..style = PaintingStyle.stroke
                                      ..strokeWidth = 4
                                      ..color = const Color(0xFF2e1907),
                                  ),
                                ),
                                const Text(
                                  'LOBBY',
                                  style: TextStyle(
                                    color: Color(0xFFCD853F),
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Room ID card
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2e1907).withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFCD853F), width: 2),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'ROOM ID',
                                    style: TextStyle(
                                      color: Color(0xFFCD853F),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SelectableText(
                                    widget.roomId,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: _copyRoomId,
                                    icon: const Icon(Icons.copy, size: 18),
                                    label: const Text('COPY'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFcf711f),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Player count
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2e1907).withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.people,
                                    color: Color(0xFFCD853F),
                                    size: 48,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '$_playerCount / 4 Players',
                                    style: const TextStyle(
                                      color: Color(0xFFCD853F),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _playerCount < 2
                                        ? 'Waiting for players to join...'
                                        : 'Ready to start!',
                                    style: TextStyle(
                                      color: const Color(0xFFCD853F).withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Instructions
                            if (widget.isHost) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFcf711f).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFcf711f)),
                                ),
                                child: const Text(
                                  'Share the Room ID with your friends so they can join!',
                                  style: TextStyle(
                                    color: Color(0xFFCD853F),
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
