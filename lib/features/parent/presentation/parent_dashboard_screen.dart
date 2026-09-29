import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hapopay/core/constants/constants.dart';
import 'package:hapopay/features/parent/presentation/widget/donut_chart.dart';
import 'package:hapopay/features/parent/presentation/widget/family_action_pill.dart';

import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/hapo_pay_logo.dart';
import '../../../shared/widgets/theme_toggle.dart';

import '../providers/parent_dashboard_provider.dart';

class ParentDashboardScreen extends ConsumerWidget {
  final bool isEmbeddedInShell;

  const ParentDashboardScreen({super.key, this.isEmbeddedInShell = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(parentDashboardProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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

    final child = dashboardState.selectedChild;
    final children = dashboardState.children;
    final spendCategories = dashboardState.spendCategories;
    final recentTxns = dashboardState.recentTxns;
    final showAlert = dashboardState.showAlert;
    final selectedChildIndex = dashboardState.selectedChildIndex;

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
                        'Parent Portal',
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
                // Switch to Student mode pill
                GestureDetector(
                  //onTap: () => context.go('/student'),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTokens.primary,
                      borderRadius: AppTokens.borderRadiusFull,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('👤', style: TextStyle(fontSize: 12)),
                        const Spacing.horizontal(4),
                        Text(
                          'Parent',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
            // Alert Banner
            if (showAlert) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppTokens.warning.withValues(alpha: 0.12),
                  borderRadius: AppTokens.borderRadiusLg,
                  border: Border.all(
                    color: AppTokens.warning.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.notifications_active_outlined,
                      color: AppTokens.warning,
                      size: 18,
                    ),
                    const Spacing.horizontal(8),
                    Expanded(
                      child: Text(
                        dashboardState.alertMessage,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTokens.warning,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => ref
                          .read(parentDashboardProvider.notifier)
                          .dismissAlert(),
                      child: Text(
                        'Dismiss',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTokens.warning,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacing.vertical(16),
            ],

            // Total Family Balance Hero Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTokens.heroGradient,
                borderRadius: AppTokens.borderRadius3xl,
                boxShadow: [
                  BoxShadow(
                    color: AppTokens.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative top-right circle overlay
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Family Balance',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const Spacing.vertical(4),
                      Text(
                        '\$${dashboardState.familyBalance.toStringAsFixed(2)}',
                        style: GoogleFonts.dmMono(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacing.vertical(4),
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_upward_rounded,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 14,
                          ),
                          const Spacing.horizontal(4),
                          Text(
                            '\$${dashboardState.addedThisWeek.toInt()} added this week',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                      const Spacing.vertical(18),
                      // Action pills
                      Row(
                        children: [
                          FamilyActionPill(
                            icon: Icons.add_rounded,
                            label: 'Add Funds',
                            onTap: () => context.push('/parent/limits'),
                          ),
                          const Spacing.horizontal(8),
                          FamilyActionPill(
                            icon: Icons.swap_horiz_rounded,
                            label: 'Transfer',
                            onTap: () => context.push('/parent/limits'),
                          ),
                          const Spacing.horizontal(8),
                          FamilyActionPill(
                            icon: Icons.bar_chart_rounded,
                            label: 'Report',
                            onTap: () => context.push('/parent/ledger'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacing.vertical(22),

            // Children Selector Carousel
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Children',
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
                        content: Text(
                          'Invite child with family code HAPOFAM-7341',
                        ),
                      ),
                    );
                  },
                  child: Text(
                    '+ Add child',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTokens.primary,
                    ),
                  ),
                ),
              ],
            ),
            const Spacing.vertical(10),
            Row(
              children: List.generate(children.length, (i) {
                final c = children[i];
                final isSelected = selectedChildIndex == i;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: i > 0 ? 6.0 : 0,
                      right: i < children.length - 1 ? 6.0 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () => ref
                          .read(parentDashboardProvider.notifier)
                          .selectChild(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? c.color.withValues(alpha: 0.12)
                              : cardColor,
                          borderRadius: AppTokens.borderRadiusXl,
                          border: Border.all(
                            color: isSelected ? c.color : borderColor,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  c.avatar,
                                  style: const TextStyle(fontSize: 22),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.name,
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: foregroundColor,
                                      ),
                                    ),
                                    Text(
                                      'Age ${c.age}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        color: mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Spacing.vertical(8),
                            Text(
                              '\$${c.balance.toStringAsFixed(2)}',
                              style: GoogleFonts.dmMono(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: c.color,
                              ),
                            ),
                            const Spacing.vertical(6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: (c.spent / c.limit).clamp(0.0, 1.0),
                                backgroundColor: isDark
                                    ? AppTokens.darkMuted
                                    : AppTokens.lightMuted,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  c.color,
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

            const Spacing.vertical(22),

            // Spending Controls Card
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
                        "${child.name}'s Controls",
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: foregroundColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTokens.accent.withValues(alpha: 0.15),
                          borderRadius: AppTokens.borderRadiusFull,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.shield_outlined,
                              color: AppTokens.accent,
                              size: 12,
                            ),
                            const Spacing.horizontal(4),
                            Text(
                              'Protected',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTokens.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacing.vertical(14),

                  // Weekly Limit
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Weekly Limit',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: mutedForeground,
                        ),
                      ),
                      Text(
                        '\$${child.limit.toInt()}',
                        style: GoogleFonts.dmMono(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: foregroundColor,
                        ),
                      ),
                    ],
                  ),
                  const Spacing.vertical(6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (child.spent / child.limit).clamp(0.0, 1.0),
                      backgroundColor: isDark
                          ? AppTokens.darkMuted
                          : AppTokens.lightMuted,
                      valueColor: AlwaysStoppedAnimation<Color>(child.color),
                      minHeight: 6,
                    ),
                  ),
                  const Spacing.vertical(4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Spent: \$${child.spent.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: mutedForeground,
                        ),
                      ),
                      Text(
                        'Left: \$${(child.limit - child.spent).toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: mutedForeground,
                        ),
                      ),
                    ],
                  ),

                  const Spacing.vertical(16),

                  // Category restrictions
                  Text(
                    'Allowed Categories',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: mutedForeground,
                    ),
                  ),
                  const Spacing.vertical(8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final cat in [
                        '🍔 Food',
                        '📚 Education',
                        '🚌 Transport',
                        '🏥 Health',
                      ])
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTokens.primary.withValues(alpha: 0.12),
                            borderRadius: AppTokens.borderRadiusFull,
                          ),
                          child: Text(
                            cat,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTokens.primary,
                            ),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTokens.darkMuted
                              : AppTokens.lightMuted,
                          borderRadius: AppTokens.borderRadiusFull,
                        ),
                        child: Text(
                          '🎮 Games ✕',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: mutedForeground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacing.vertical(22),

            // Spending Breakdown Donut Chart
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
                  Text(
                    'Spending Breakdown',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: foregroundColor,
                    ),
                  ),
                  const Spacing.vertical(16),
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CustomPaint(
                          painter: DonutChartPainter(
                            categories: spendCategories,
                          ),
                        ),
                      ),
                      const Spacing.horizontal(20),
                      Expanded(
                        child: Column(
                          children: spendCategories.map((c) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 3.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: c.color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const Spacing.horizontal(8),
                                      Text(
                                        c.label,
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: foregroundColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${c.pct.toInt()}%',
                                    style: GoogleFonts.dmMono(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacing.vertical(22),

            // Recent Activity List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: foregroundColor,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/parent/ledger'),
                  child: Text(
                    'View all',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTokens.primary,
                    ),
                  ),
                ),
              ],
            ),
            const Spacing.vertical(10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentTxns.length,
              separatorBuilder: (_, _) => const Spacing.vertical(8),
              itemBuilder: (context, index) {
                final t = recentTxns[index];
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: !t.approved
                        ? AppTokens.warning.withValues(alpha: 0.08)
                        : cardColor,
                    borderRadius: AppTokens.borderRadiusLg,
                    border: Border.all(
                      color: !t.approved
                          ? AppTokens.warning.withValues(alpha: 0.3)
                          : borderColor,
                      width: 1,
                    ),
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
                              '${t.childName} · ${t.time}',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${t.amount > 0 ? '+' : ''}\$${t.amount.abs().toStringAsFixed(2)}',
                            style: GoogleFonts.dmMono(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: t.amount > 0
                                  ? AppTokens.accent
                                  : (!t.approved
                                        ? AppTokens.warning
                                        : foregroundColor),
                            ),
                          ),
                          if (!t.approved)
                            Text(
                              'Flagged',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTokens.warning,
                              ),
                            ),
                        ],
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
