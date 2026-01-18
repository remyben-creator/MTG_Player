import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CustomBackButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.arrow_back,
        color: Color(0xFFCD853F),
      ),
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
    );
  }
}
