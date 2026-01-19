import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'deck_screens/decks_home_screen.dart';
import 'server_screens/host_screen.dart';
import 'server_screens/join_screen.dart';
import '../widgets/common/buttons/standard_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
            child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      // Border/stroke effect
                      Text(
                        'REMY\'S MTG PLAYER',
                        style: TextStyle(
                          fontSize: 96,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 8
                            ..color = const Color(0xFF2e1907),
                        ),
                      ),
                      // Main text
                      Text(
                        'REMY\'S MTG PLAYER',
                        style: TextStyle(
                          fontSize: 96,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFCD853F),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StandardButton(
                        text: 'Host',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const HostScreen()),
                          );
                        },
                      ),
                      const SizedBox(width: 20),
                      StandardButton(
                        text: 'Join',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const JoinScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StandardButton(
                        text: 'Decks',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DecksScreen()),
                          );
                        },
                      ),
                      const SizedBox(width: 20),
                      StandardButton(
                        text: 'Profile',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }
}
