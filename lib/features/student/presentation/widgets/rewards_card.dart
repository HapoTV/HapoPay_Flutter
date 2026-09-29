import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hapopay/core/theme/tokens.dart';
import 'package:hapopay/features/student/models/reward_model.dart';
import 'package:hapopay/features/student/presentation/themes/reward_theme.dart';
import 'package:hapopay/features/student/providers/rewards_provider.dart';

class RewardsBannerCard extends ConsumerWidget {
  final Color cardColor;
  final Color borderColor;
  final VoidCallback onTap;

  const RewardsBannerCard({
    super.key,
    required this.cardColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardsAsync = ref.watch(rewardsProvider);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: AppTokens.borderRadiusXl,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppTokens.borderRadiusXl,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: rewardsAsync.when(
              loading: () => const Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Loading rewards...'),
                ],
              ),
              error: (_, _) => _buildRow(
                context,
                tierBadge: '⭐ Keeper',
                tierColor: AppTokens.primary,
                points: 680,
                desc: 'Tap to view tier roadmap & achievements',
              ),
              data: (reward) => _buildRow(
                context,
                tierBadge: '${reward.tier.badge} ${reward.tier.label}',
                tierColor: rewardTierColors[reward.tier] ?? AppTokens.primary,
                points: reward.totalPoints,
                desc:
                    '${reward.earnedAchievementsCount} of ${reward.achievements.length} achievements unlocked',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required String tierBadge,
    required Color tierColor,
    required int points,
    required String desc,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foregroundColor = isDark
        ? AppTokens.darkForeground
        : AppTokens.lightForeground;
    final mutedForeground = isDark
        ? AppTokens.darkMutedForeground
        : AppTokens.lightMutedForeground;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: tierColor.withValues(alpha: 0.12),
            borderRadius: AppTokens.borderRadiusMd,
          ),
          child: Center(
            child: Icon(Icons.emoji_events_rounded, color: tierColor, size: 24),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Rewards & Streaks',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: foregroundColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: tierColor.withValues(alpha: 0.15),
                      borderRadius: AppTokens.borderRadiusFull,
                    ),
                    child: Text(
                      tierBadge,
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: tierColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: GoogleFonts.outfit(fontSize: 12, color: mutedForeground),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right_rounded, color: mutedForeground, size: 20),
      ],
    );
  }
}
