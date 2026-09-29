import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hapopay/core/theme/tokens.dart';

class StepCircle extends StatelessWidget {
  final int stepNumber;
  final int currentStep;
  final bool isDark;

  const StepCircle({
    super.key,
    required this.stepNumber,
    required this.currentStep,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = currentStep > stepNumber;
    final isActive = currentStep == stepNumber;

    Color bgColor;
    Color fgColor;

    if (isCompleted) {
      bgColor = AppTokens.accent;
      fgColor = Colors.white;
    } else if (isActive) {
      bgColor = AppTokens.primary;
      fgColor = Colors.white;
    } else {
      bgColor = isDark ? AppTokens.darkMuted : AppTokens.lightMuted;
      fgColor = isDark
          ? AppTokens.darkMutedForeground
          : AppTokens.lightMutedForeground;
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
            : Text(
                '$stepNumber',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: fgColor,
                ),
              ),
      ),
    );
  }
}
