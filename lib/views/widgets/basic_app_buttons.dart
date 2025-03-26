
import 'package:en_time/components/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BasicAppButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final double ? height;
  const BasicAppButton({
    required this.onPressed,
    required this.title,
    this.height,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.primaryG),
        borderRadius: BorderRadius.circular(30)
      ),

      child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, // Nền trong suốt để lộ gradient
            shadowColor: Colors.transparent,
            minimumSize: Size.fromHeight(height ?? 80),
          ),
          child: Text(
              title,
            style: TextStyle(color: Colors.white, fontSize: 20),
          )
      ),
    );
  }
}