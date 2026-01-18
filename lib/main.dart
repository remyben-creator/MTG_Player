import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remy\'s MTG Player',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: const Color(0xFFcf711f), // Bright Orange
          secondary: const Color(0xFF8a4c14), // Brown Orange
          surface: const Color(0xFFb8651b),
          background: const Color(0xFFa15818),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFa15818),
      ),
      home: const HomeScreen(),
    );
  }
}
