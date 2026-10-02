import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/tokens.dart';
import '../../features/auth/domain/entities/app_user.dart';
import '../../features/parent/presentation/screens/family_ledger_screen.dart';
import '../../features/parent/presentation/parent_dashboard_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/student/presentation/screens/rewards_screen.dart';
import '../../features/student/presentation/student_dashboard_screen.dart';
import '../../features/qrcode/presentation/pay_qr_screen.dart';
import 'app_bottom_nav.dart';
import 'hapo_pay_logo.dart';
import 'theme_toggle.dart';

import '../providers/app_shell_provider.dart';

class MainAppScaffold extends ConsumerWidget {
  final UserRole initialRole;
  final AppTab initialTab;

  const MainAppScaffold({
    super.key,
    this.initialRole = UserRole.parent,
    this.initialTab = AppTab.home,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRole = ref.watch(appRoleProvider);
    final currentTab = ref.watch(activeTabProvider);
    final isParent = currentRole == UserRole.parent;
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
    final borderColor = isDark ? AppTokens.darkBorder : AppTokens.lightBorder;

    return Scaffold(
      backgroundColor: backgroundColor,
      // Persistent Header across the shell
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            const HapoPayLogo(height: 28),
            const SizedBox(width: 10),
            Text(
              isParent ? 'Parent Portal' : 'Student Hub',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: mutedForeground,
              ),
            ),
          ],
        ),
        actions: [
          // Role pill indicator (Parent / Student)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isParent ? AppTokens.primary : AppTokens.accent,
              borderRadius: AppTokens.borderRadiusFull,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isParent ? '👤' : '🎒',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 4),
                Text(
                  isParent ? 'Parent' : 'Student',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isParent ? Colors.white : AppTokens.darkBackground,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ThemeToggle(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: borderColor, height: 1),
        ),
      ),
      body: _buildCurrentTabBody(isParent, currentTab),
      // Persistent Interactive Bottom Navigation Bar
      bottomNavigationBar: AppBottomNav(
        isParent: isParent,
        currentTab: currentTab,
        onTabSelected: (tab) {
          ref.read(activeTabProvider.notifier).setTab(tab);
        },
      ),
    );
  }

  Widget _buildCurrentTabBody(bool isParent, AppTab currentTab) {
    if (isParent) {
      switch (currentTab) {
        case AppTab.home:
          return const _EmbeddedParentDashboard();
        case AppTab.activity:
          return const _EmbeddedFamilyLedger();
        case AppTab.settings:
          return const _EmbeddedSettings();
        default:
          return const _EmbeddedParentDashboard();
      }
    } else {
      switch (currentTab) {
        case AppTab.home:
          return const _EmbeddedStudentDashboard();
        case AppTab.pay:
          return const _EmbeddedPayQr();
        case AppTab.rewards:
          return const _EmbeddedRewards();
        case AppTab.settings:
          return const _EmbeddedSettings();
        default:
          return const _EmbeddedStudentDashboard();
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Embedded versions without standalone AppBars for clean shell presentation
// ---------------------------------------------------------------------------

class _EmbeddedParentDashboard extends StatelessWidget {
  const _EmbeddedParentDashboard();

  @override
  Widget build(BuildContext context) {
    return const ParentDashboardScreen(isEmbeddedInShell: true);
  }
}

class _EmbeddedFamilyLedger extends StatelessWidget {
  const _EmbeddedFamilyLedger();

  @override
  Widget build(BuildContext context) {
    return const FamilyLedgerScreen(isEmbeddedInShell: true);
  }
}

class _EmbeddedStudentDashboard extends StatelessWidget {
  const _EmbeddedStudentDashboard();

  @override
  Widget build(BuildContext context) {
    return const StudentDashboardScreen(isEmbeddedInShell: true);
  }
}

class _EmbeddedPayQr extends StatelessWidget {
  const _EmbeddedPayQr();

  @override
  Widget build(BuildContext context) {
    return const PayQrScreen(isEmbeddedInShell: true);
  }
}

class _EmbeddedRewards extends StatelessWidget {
  const _EmbeddedRewards();

  @override
  Widget build(BuildContext context) {
    return const RewardsScreen(isEmbeddedInShell: true);
  }
}

class _EmbeddedSettings extends StatelessWidget {
  const _EmbeddedSettings();

  @override
  Widget build(BuildContext context) {
    return const SettingsScreen(isEmbeddedInShell: true);
  }
}
