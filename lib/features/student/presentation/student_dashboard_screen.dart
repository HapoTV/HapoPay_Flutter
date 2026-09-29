import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hapopay/core/constants/constants.dart';
import 'package:hapopay/features/student/presentation/models/goal_item_model.dart';
import 'package:hapopay/features/student/presentation/models/student_transaction_model.dart';
import 'package:hapopay/features/student/presentation/widgets/mini_stats_card.dart';
import 'package:hapopay/features/student/presentation/widgets/payqr_card.dart';
import 'package:hapopay/features/student/presentation/widgets/quick_pay_button.dart';
import 'package:hapopay/features/student/presentation/widgets/rewards_card.dart';

import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/hapo_pay_logo.dart';
import '../../../shared/widgets/theme_toggle.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/student_account_provider.dart';

class StudentDashboardScreen extends ConsumerWidget {
  final bool isEmbeddedInShell;

  const StudentDashboardScreen({super.key, this.isEmbeddedInShell = false});

  static const List<GoalItem> _goals = [
    GoalItem(name: 'New Headphones', target: 80, saved: 45, emoji: '🎧'),
    GoalItem(name: 'Art Supplies', target: 35, saved: 35, emoji: '🎨'),
  ];

  static const List<StudentTxnItem> _recentTxns = [
    StudentTxnItem(
      merchant: 'School Canteen',
      amount: -4.50,
      time: 'Today, 12:30',
      cat: '🍔',
    ),
    StudentTxnItem(
      merchant: 'Bus Pass Top-up',
      amount: -15.00,
      time: 'Today, 7:45',
      cat: '🚌',
    ),
    StudentTxnItem(
      merchant: 'Weekly Allowance',
      amount: 50.00,
      time: 'Yesterday',
      cat: '💸',
    ),
    StudentTxnItem(
      merchant: 'Stationery World',
      amount: -12.00,
      time: 'Mon',
      cat: '📚',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider.select((s) => s.user));
    final accountAsync = ref.watch(studentAccountProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark
        ? AppTokens.darkBackground
        : AppTokens.lightBackground;
    final foregroundColor = isDark
        ? AppTokens.darkForeground
        : AppTokens.lightForeground;
    final mutedForeground = isDark
        ? AppTokens.darkMutedForeground
        : AppTokens.lightMutedForeground;
    final cardColor = isDark ? AppTokens.darkCard : AppTokens.lightCard;
    final borderColor = isDark ? AppTokens.darkBorder : AppTokens.lightBorder;
    final secondaryBg = isDark
        ? AppTokens.darkSecondary
        : AppTokens.lightSecondary;

    final displayName = user?.fullName.split(' ').first ?? 'Amara';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: isEmbeddedInShell
          ? null
          : AppBar(
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  const HapoPayLogo(size: 34),
                  const Spacing.horizontal(10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Student Hub',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: mutedForeground,
                        ),
                      ),
                      Text(
                        'HapoPay',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: foregroundColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                // Switch to Parent mode pill
                GestureDetector(
                  // onTap: () {
                  //   ref.read(appRoleProvider.notifier).setRole(UserRole.parent);
                  //   context.go('/parent');
                  // },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTokens.accent,
                      borderRadius: AppTokens.borderRadiusFull,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🎒', style: TextStyle(fontSize: 12)),
                        const Spacing.horizontal(4),
                        Text(
                          'Student',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTokens.darkBackground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ThemeToggle(),
                ),
              ],
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Balance Hero Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: isDark
                    ? AppTokens.darkHeroGradient
                    : const LinearGradient(
                        colors: [Color(0xFF6C3AFF), Color(0xFF00B88A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: AppTokens.borderRadius3xl,
                border: Border.all(
                  color: AppTokens.primary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTokens.primary.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hey $displayName 👋',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const Spacing.vertical(4),
                          accountAsync.when(
                            loading: () => const SizedBox(
                              height: 40,
                              width: 120,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            error: (_, _) => Text(
                              '\$124.50',
                              style: GoogleFonts.dmMono(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            data: (account) => Text(
                              '\$${account.balance.toStringAsFixed(2)}',
                              style: GoogleFonts.dmMono(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Spacing.vertical(2),
                          Text(
                            'Available balance',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      // 7 Day Streak Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTokens.accent.withValues(alpha: 0.2),
                          borderRadius: AppTokens.borderRadiusFull,
                          border: Border.all(
                            color: AppTokens.accent.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 13)),
                            const Spacing.horizontal(4),
                            Text(
                              '7 day streak',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTokens.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Spacing.vertical(18),

                  // Mini Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: MiniStatCard(
                          icon: Icons.arrow_downward_rounded,
                          iconColor: AppTokens.warning,
                          label: 'Spent',
                          value: accountAsync.maybeWhen(
                            data: (acc) =>
                                '\$${acc.todaySpent.toStringAsFixed(2)}',
                            orElse: () => '\$75.50',
                          ),
                        ),
                      ),
                      const Spacing.horizontal(8),
                      const Expanded(
                        child: MiniStatCard(
                          icon: Icons.arrow_upward_rounded,
                          iconColor: AppTokens.accent,
                          label: 'Saved',
                          value: '\$49.00',
                        ),
                      ),
                      const Spacing.horizontal(8),
                      Expanded(
                        child: MiniStatCard(
                          label: 'Limit left',
                          value: accountAsync.maybeWhen(
                            data: (acc) =>
                                '\$${(acc.dailyLimit - acc.todaySpent).clamp(0.0, double.infinity).toStringAsFixed(0)}',
                            orElse: () => '\$124',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacing.vertical(20),

            // Quick Category Spend Actions
            Row(
              children: [
                QuickSpendBtn(
                  emoji: '🍔',
                  label: 'Food',
                  cardColor: cardColor,
                  borderColor: borderColor,
                  foregroundColor: foregroundColor,
                  mutedColor: mutedForeground,
                  onTap: () => context.push('/student/pay-qr'),
                ),
                const Spacing.horizontal(8),
                QuickSpendBtn(
                  emoji: '🚌',
                  label: 'Transit',
                  cardColor: cardColor,
                  borderColor: borderColor,
                  foregroundColor: foregroundColor,
                  mutedColor: mutedForeground,
                  onTap: () => context.push('/student/pay-qr'),
                ),
                const Spacing.horizontal(8),
                QuickSpendBtn(
                  emoji: '📚',
                  label: 'School',
                  cardColor: cardColor,
                  borderColor: borderColor,
                  foregroundColor: foregroundColor,
                  mutedColor: mutedForeground,
                  onTap: () => context.push('/student/pay-qr'),
                ),
                const Spacing.horizontal(8),
                QuickSpendBtn(
                  emoji: '🛍️',
                  label: 'Shop',
                  cardColor: cardColor,
                  borderColor: borderColor,
                  foregroundColor: foregroundColor,
                  mutedColor: mutedForeground,
                  onTap: () => context.push('/student/pay-qr'),
                ),
              ],
            ),

            const Spacing.vertical(22),

            // Quick Action Cards (Pay QR / My QR)
            Row(
              children: [
                Expanded(
                  child: PayQrHeroCard(
                    title: 'Pay with QR',
                    subtitle: 'Scan terminal code',
                    icon: Icons.qr_code_scanner_rounded,
                    gradient: AppTokens.primaryGradient,
                    onTap: () => context.push('/student/pay-qr'),
                  ),
                ),
                const Spacing.horizontal(12),
                Expanded(
                  child: PayQrHeroCard(
                    title: 'My QR Code',
                    subtitle: 'Receive money',
                    icon: Icons.qr_code_rounded,
                    gradient: AppTokens.accentGradient,
                    onTap: () => context.push('/student/my-qr'),
                  ),
                ),
              ],
            ),

            const Spacing.vertical(22),

            // Live Rewards Card
            RewardsBannerCard(
              cardColor: cardColor,
              borderColor: borderColor,
              onTap: () => context.push('/student/rewards'),
            ),

            const Spacing.vertical(22),

            // Savings Goals Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: AppTokens.borderRadiusXl,
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Savings Goals',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: foregroundColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Goal creation modal coming up!'),
                            ),
                          );
                        },
                        child: Text(
                          '+ New goal',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTokens.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacing.vertical(14),
                  for (final g in _goals) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    g.emoji,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const Spacing.horizontal(8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        g.name,
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: foregroundColor,
                                        ),
                                      ),
                                      Text(
                                        '\$${g.saved.toInt()} / \$${g.target.toInt()}',
                                        style: GoogleFonts.dmMono(
                                          fontSize: 12,
                                          color: mutedForeground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (g.saved >= g.target)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTokens.accent.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: AppTokens.borderRadiusFull,
                                  ),
                                  child: Text(
                                    'Complete! 🎉',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppTokens.accent,
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  '${((g.saved / g.target) * 100).toInt()}%',
                                  style: GoogleFonts.dmMono(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: mutedForeground,
                                  ),
                                ),
                            ],
                          ),
                          const Spacing.vertical(6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (g.saved / g.target).clamp(0.0, 1.0),
                              backgroundColor: isDark
                                  ? AppTokens.darkMuted
                                  : AppTokens.lightMuted,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                g.saved >= g.target
                                    ? AppTokens.accent
                                    : AppTokens.primary,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Spacing.vertical(22),

            // Recent Transactions List
            Text(
              'Recent Transactions',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: foregroundColor,
              ),
            ),
            const Spacing.vertical(10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentTxns.length,
              separatorBuilder: (_, _) => const Spacing.vertical(8),
              itemBuilder: (context, index) {
                final t = _recentTxns[index];
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: AppTokens.borderRadiusLg,
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: secondaryBg,
                          borderRadius: AppTokens.borderRadiusMd,
                        ),
                        child: Center(
                          child: Text(
                            t.cat,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const Spacing.horizontal(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.merchant,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: foregroundColor,
                              ),
                            ),
                            Text(
                              t.time,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${t.amount > 0 ? '+' : ''}\$${t.amount.abs().toStringAsFixed(2)}',
                        style: GoogleFonts.dmMono(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: t.amount > 0
                              ? AppTokens.accent
                              : foregroundColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const Spacing.vertical(24),
          ],
        ),
      ),
    );
  }
}
