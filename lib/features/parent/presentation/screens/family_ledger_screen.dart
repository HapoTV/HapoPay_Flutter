import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hapopay/core/constants/constants.dart';

import '../../../../core/theme/tokens.dart';

import '../../providers/family_ledger_provider.dart';

class FamilyLedgerScreen extends ConsumerWidget {
  final bool isEmbeddedInShell;

  const FamilyLedgerScreen({super.key, this.isEmbeddedInShell = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledgerState = ref.watch(familyLedgerProvider);
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

    final filterChild = ledgerState.filterChild;
    final filterStatus = ledgerState.filterStatus;
    final totalIn = ledgerState.totalIn;
    final totalOut = ledgerState.totalOut;
    final grouped = ledgerState.groupedByDate;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: isEmbeddedInShell
          ? null
          : AppBar(
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: foregroundColor,
                  size: 20,
                ),
                onPressed: () => context.pop(),
              ),
              title: Text(
                'Transactions & Activity',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: foregroundColor,
                ),
              ),
              centerTitle: true,
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Summary Cards (Money In / Money Out)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTokens.accent.withValues(alpha: 0.1),
                      borderRadius: AppTokens.borderRadiusXl,
                      border: Border.all(
                        color: AppTokens.accent.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.arrow_upward_rounded,
                              color: AppTokens.accent,
                              size: 16,
                            ),
                            const Spacing.horizontal(4),
                            Text(
                              'Money In',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: mutedForeground,
                              ),
                            ),
                          ],
                        ),
                        const Spacing.vertical(6),
                        Text(
                          '+\$${totalIn.toStringAsFixed(2)}',
                          style: GoogleFonts.dmMono(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTokens.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacing.horizontal(12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTokens.warning.withValues(alpha: 0.1),
                      borderRadius: AppTokens.borderRadiusXl,
                      border: Border.all(
                        color: AppTokens.warning.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.arrow_downward_rounded,
                              color: AppTokens.warning,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Money Out',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: mutedForeground,
                              ),
                            ),
                          ],
                        ),
                        const Spacing.vertical(6),
                        Text(
                          '-\$${totalOut.toStringAsFixed(2)}',
                          style: GoogleFonts.dmMono(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTokens.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const Spacing.vertical(18),

            // Filter Chips (By Child & By Status)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Child Filter row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['all', 'Amara', 'Kwame'].map((childName) {
                      final isSelected = filterChild == childName;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () => ref
                              .read(familyLedgerProvider.notifier)
                              .setFilterChild(childName),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTokens.primary : cardColor,
                              borderRadius: AppTokens.borderRadiusFull,
                              border: Border.all(
                                color: isSelected
                                    ? AppTokens.primary
                                    : borderColor,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              childName == 'all' ? 'All Children' : childName,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : mutedForeground,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const Spacing.vertical(8),

                // Status Filter row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['all', 'approved', 'flagged'].map((status) {
                      final isSelected = filterStatus == status;
                      final isFlagged = status == 'flagged';
                      final activeColor = isFlagged
                          ? AppTokens.warning
                          : AppTokens.primary;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () => ref
                              .read(familyLedgerProvider.notifier)
                              .setFilterStatus(status),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? activeColor : cardColor,
                              borderRadius: AppTokens.borderRadiusFull,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : borderColor,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              status == 'all'
                                  ? 'All Status'
                                  : status[0].toUpperCase() +
                                        status.substring(1),
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : mutedForeground,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            const Spacing.vertical(20),

            // Grouped Transactions
            if (grouped.isEmpty) ...[
              const Spacing.vertical(48),
              Center(
                child: Column(
                  children: [
                    Text('🔍', style: const TextStyle(fontSize: 32)),
                    const Spacing.vertical(10),
                    Text(
                      'No matching transactions found',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              for (final entry in grouped.entries) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Text(
                    entry.key.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: mutedForeground,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: entry.value.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final t = entry.value[i];
                    final isFlagged = t.status == 'flagged';

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isFlagged
                            ? AppTokens.warning.withValues(alpha: 0.08)
                            : cardColor,
                        borderRadius: AppTokens.borderRadiusLg,
                        border: Border.all(
                          color: isFlagged
                              ? AppTokens.warning.withValues(alpha: 0.35)
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
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        t.merchant,
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: foregroundColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isFlagged) ...[
                                      const Spacing.horizontal(6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTokens.warning.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          'Flagged',
                                          style: GoogleFonts.outfit(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AppTokens.warning,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const Spacing.vertical(2),
                                Text(
                                  '${t.child} · ${t.time}',
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
                                  : (isFlagged
                                        ? AppTokens.warning
                                        : foregroundColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Spacing.vertical(8),
              ],
            ],

            const Spacing.vertical(24),
          ],
        ),
      ),
    );
  }
}
