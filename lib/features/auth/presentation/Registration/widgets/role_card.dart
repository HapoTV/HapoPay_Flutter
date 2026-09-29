import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hapopay/core/theme/tokens.dart';
import 'package:hapopay/features/auth/domain/entities/app_user.dart';

class RoleCard extends StatelessWidget {
  final UserRole role;
  final String label;
  final String subtitle;
  final String emoji;
  final bool isSelected;
  final Color selectedBorderColor;
  final Color selectedBgColor;
  final VoidCallback onTap;
  final bool isDark;

  const RoleCard({
    super.key,
    required this.role,
    required this.label,
    required this.subtitle,
    required this.emoji,
    required this.isSelected,
    required this.selectedBorderColor,
    required this.selectedBgColor,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppTokens.darkCard : AppTokens.lightCard;
    final borderColor = isDark ? AppTokens.darkBorder : AppTokens.lightBorder;
    final foregroundColor = isDark
        ? AppTokens.darkForeground
        : AppTokens.lightForeground;
    final mutedForeground = isDark
        ? AppTokens.darkMutedForeground
        : AppTokens.lightMutedForeground;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? selectedBgColor : cardColor,
          borderRadius: AppTokens.borderRadiusLg,
          border: Border.all(
            color: isSelected ? selectedBorderColor : borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: foregroundColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
