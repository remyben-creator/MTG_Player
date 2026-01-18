import 'package:flutter/material.dart';

class StandardButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const StandardButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFCD853F),
        border: Border.all(
          color: const Color(0xFF2e1907),
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2e1907),
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
