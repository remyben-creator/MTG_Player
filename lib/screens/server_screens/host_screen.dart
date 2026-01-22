import 'package:flutter/material.dart';
import '../../widgets/common/buttons/back_button.dart';
import '../../services/colyseus_service.dart';
import '../../routes/app_routes.dart';
import '../../routes/route_arguments.dart';

class HostScreen extends StatefulWidget {
  const HostScreen({super.key});

  @override
  State<HostScreen> createState() => _HostScreenState();
}

class _HostScreenState extends State<HostScreen> {
  final _playerNameController = TextEditingController(text: 'Host Player');
  final _serverUrlController = TextEditingController(text: 'ws://localhost:2567');
  final _colyseusService = ColyseusService();
  bool _isCreating = false;
  String? _errorMessage;

  @override
  void dispose() {
    _playerNameController.dispose();
    _serverUrlController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    if (_playerNameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a player name';
      });
      return;
    }

    setState(() {
      _isCreating = true;
      _errorMessage = null;
    });

    try {
      // Initialize Colyseus with server URL
      _colyseusService.initialize(_serverUrlController.text.trim());

      // Create room
      await _colyseusService.createRoom(
        playerName: _playerNameController.text.trim(),
        startingLife: 40,
      );

      // Navigate to lobby screen
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.lobby,
          arguments: LobbyArguments(
            roomId: _colyseusService.roomId!,
            isHost: true,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create room: $e';
        _isCreating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Base background
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
          // Organic blob patterns
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFcf711f).withOpacity(0.3),
                    const Color(0xFFcf711f).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 100,
            right: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8a4c14).withOpacity(0.4),
                    const Color(0xFF8a4c14).withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -200,
            left: -50,
            child: Container(
              width: 450,
              height: 450,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFb8651b).withOpacity(0.35),
                    const Color(0xFFb8651b).withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFa15818).withOpacity(0.3),
                    const Color(0xFFa15818).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  leading: const CustomBackButton(),
                  title: Stack(
                    children: [
                      Text(
                        'HOST GAME',
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
                        'HOST GAME',
                        style: TextStyle(
                          color: Color(0xFFCD853F),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Server URL input
                          TextField(
                            controller: _serverUrlController,
                            style: const TextStyle(color: Color(0xFFCD853F)),
                            decoration: InputDecoration(
                              labelText: 'Server URL',
                              labelStyle: const TextStyle(color: Color(0xFFCD853F)),
                              hintText: 'ws://localhost:2567',
                              hintStyle: TextStyle(color: const Color(0xFFCD853F).withOpacity(0.5)),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Color(0xFFCD853F)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Color(0xFFcf711f), width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Player name input
                          TextField(
                            controller: _playerNameController,
                            style: const TextStyle(color: Color(0xFFCD853F)),
                            decoration: InputDecoration(
                              labelText: 'Your Name',
                              labelStyle: const TextStyle(color: Color(0xFFCD853F)),
                              hintText: 'Enter your player name',
                              hintStyle: TextStyle(color: const Color(0xFFCD853F).withOpacity(0.5)),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Color(0xFFCD853F)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Color(0xFFcf711f), width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Create Room button
                          ElevatedButton(
                            onPressed: _isCreating ? null : _createRoom,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFcf711f),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isCreating
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'CREATE ROOM',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
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
    );
  }
}
