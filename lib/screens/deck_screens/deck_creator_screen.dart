import 'package:flutter/material.dart';
import '../../widgets/common/buttons/back_button.dart';
import '../../widgets/common/buttons/standard_button.dart';

class CreateDeckScreen extends StatelessWidget {
  const CreateDeckScreen({super.key});

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
          // Content
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  leading: const CustomBackButton(),
                  title: Stack(
                    children: [
                      Text(
                        'CREATE DECK',
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
                        'CREATE DECK',
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
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF2e1907).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFCD853F),
                                width: 2,
                              ),
                            ),
                            child: TextField(
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              style: const TextStyle(
                                color: Color(0xFFCD853F),
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter deck contents...',
                                hintStyle: TextStyle(
                                  color: const Color(0xFFCD853F).withOpacity(0.5),
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        StandardButton(
                          text: 'Create Deck',
                          onPressed: () {},
                        ),
                      ],
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
