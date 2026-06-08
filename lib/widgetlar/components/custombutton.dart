import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String metin;
  final VoidCallback onPressed;
  final Color? renk;

  const CustomButton({
    super.key,
    required this.metin,
    required this.onPressed,
    this.renk,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: renk ?? Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        metin,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
