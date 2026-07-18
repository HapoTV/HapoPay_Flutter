import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/action_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/rewards_provider.dart';
import '../providers/student_account_provider.dart';
import '../models/reward_model.dart';

// ---------------------------------------------------------------------------
// Tier colour palette (shared with rewards_screen.dart)
// ---------------------------------------------------------------------------
const _tierColors = {
  RewardTier.bronze: Color(0xFFCD7F32),
  RewardTier.silver: Color(0xFFC0C0C0),
  RewardTier.gold: Color(0xFFFFD700),
  RewardTier.platinum: Color(0xFF00E5FF),
};

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider.select((s) => s.user));
    final accountAsync = ref.watch(studentAccountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hey, ${user?.fullName ?? 'Student'}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ready to make a payment?',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 32),

            // ── Balance card ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6200EE), Color(0xFFBB86FC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text(
                    'Available Balance',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  accountAsync.when(
                    loading: () => const SizedBox(
                      height: 86,
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                    error: (err, _) => SizedBox(
                      height: 86,
                      child: Center(
                        child: Text(
                          'Error loading balance',
                          style: TextStyle(color: Colors.red[100], fontSize: 14),
                        ),
                      ),
                    ),
                    data: (account) => Column(
                      children: [
                        Text(
                          '\$${account.balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _BalanceInfo(
                              label: 'Today',
                              value: '\$${account.todaySpent.toStringAsFixed(2)}',
                            ),
                            Container(width: 1, height: 40, color: Colors.white24),
                            _BalanceInfo(
                              label: 'Limit',
                              value: '\$${account.dailyLimit.toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Action cards ──────────────────────────────────────────────
            ActionCard(
              title: 'Pay with QR',
              subtitle: 'Scan a merchant code',
              icon: Icons.qr_code_scanner,
              onTap: () => context.push('/student/pay-qr'),
            ),
            const SizedBox(height: 16),
            ActionCard(
              title: 'My QR Code',
              subtitle: 'Show code to receive money',
              icon: Icons.qr_code,
              onTap: () => context.push('/student/my-qr'),
            ),
            const SizedBox(height: 16),

            // ── Live Rewards summary card ─────────────────────────────────
            _RewardsSummaryCard(onTap: () => context.push('/student/rewards')),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Live Rewards Summary Card
// ===========================================================================

class _RewardsSummaryCard extends ConsumerWidget {
  final VoidCallback onTap;

  const _RewardsSummaryCard({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardsAsync = ref.watch(rewardsProvider);

    return rewardsAsync.when(
      // While loading, show a shimmering placeholder that matches the card shape
      loading: () => _buildShell(context, onTap: onTap, child: _shimmerRow()),
      error: (_, __) => _buildShell(
        context,
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.emoji_events_outlined,
                color: Colors.amber,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rewards',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Tap to view your achievements',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
      data: (reward) {
        final tierColor = _tierColors[reward.tier] ?? Colors.amber;
        final progress = reward.tierProgressFraction;
        final nextPts = reward.nextMilestonePoints;
        final earned = reward.earnedAchievementsCount;
        final total = reward.achievements.length;

        return _buildShell(
          context,
          onTap: onTap,
          borderColor: tierColor.withValues(alpha: 0.35),
          glowColor: tierColor.withValues(alpha: 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: icon + title + tier badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: tierColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: tierColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rewards',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$earned / $total achievements unlocked',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tier badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: tierColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: tierColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '${reward.tier.badge} ${reward.tier.label}',
                      style: TextStyle(
                        color: tierColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Points + progress bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${reward.totalPoints} pts',
                    style: TextStyle(
                      color: tierColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    nextPts != null
                        ? '${nextPts - reward.totalPoints} pts to next tier'
                        : '🏆 Max tier!',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (_, val, __) => LinearProgressIndicator(
                    value: val,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation(tierColor),
                    minHeight: 6,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShell(
    BuildContext context, {
    required VoidCallback onTap,
    required Widget child,
    Color? borderColor,
    Color? glowColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? Colors.white12),
        boxShadow: glowColor != null
            ? [BoxShadow(color: glowColor, blurRadius: 12, spreadRadius: 1)]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(padding: const EdgeInsets.all(18), child: child),
        ),
      ),
    );
  }

  Widget _shimmerRow() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 14,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 10,
                width: 140,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// Shared helper widget
// ===========================================================================

class _BalanceInfo extends StatelessWidget {
  final String label;
  final String value;

  const _BalanceInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
