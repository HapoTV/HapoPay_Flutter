import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hapopay/core/constants/constants.dart';
import 'package:hapopay/features/settings/presentation/widgets/settings_preview.dart';
import 'package:hapopay/features/settings/presentation/widgets/settings_section.dart';
import 'package:hapopay/features/settings/presentation/widgets/settings_toggle.dart';
import 'package:hapopay/features/settings/presentation/widgets/text_link.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/theme/theme_mode_provider.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/hapo_pay_logo.dart';
import '../../auth/providers/auth_provider.dart';

import '../providers/user_settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  final bool isEmbeddedInShell;

  const SettingsScreen({super.key, this.isEmbeddedInShell = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final userSettings = ref.watch(userSettingsProvider);
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    final user = ref.watch(authProvider.select((s) => s.user));

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

    final familyName = user?.fullName.isNotEmpty == true
        ? '${user!.fullName.split(" ").last} Family'
        : 'Mensah Family';

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
                'Settings',
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
            // Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: AppTokens.borderRadiusXl,
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTokens.primary.withValues(alpha: 0.2),
                          AppTokens.accent.withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: AppTokens.borderRadiusLg,
                    ),
                    child: const Center(
                      child: Text(
                        '👨‍👩‍👧‍👦',
                        style: TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                  const Spacing.horizontal(14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          familyName,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: foregroundColor,
                          ),
                        ),
                        const Spacing.vertical(2),
                        Text(
                          '2 children · Premium plan',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTokens.heroGradient,
                      borderRadius: AppTokens.borderRadiusFull,
                    ),
                    child: Text(
                      'PRO',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacing.vertical(20),

            // Appearance Section
            SettingsSectionContainer(
              title: 'APPEARANCE',
              cardColor: cardColor,
              borderColor: borderColor,
              mutedForeground: mutedForeground,
              children: [
                // Dark Mode Switch Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isDark
                              ? Icons.nightlight_round
                              : Icons.wb_sunny_rounded,
                          color: isDark ? AppTokens.primary : AppTokens.gold,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isDark ? 'Dark Mode' : 'Light Mode',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: foregroundColor,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: isDark,
                      activeThumbColor: AppTokens.primary,
                      onChanged: (val) {
                        ref
                            .read(themeModeProvider.notifier)
                            .setThemeMode(
                              val ? ThemeMode.dark : ThemeMode.light,
                            );
                      },
                    ),
                  ],
                ),

                const Spacing.vertical(12),

                // Theme Mode Preview Selectors
                Row(
                  children: [
                    Expanded(
                      child: ThemePreviewBox(
                        label: 'Dark',
                        isSelected: isDark,
                        previewBgColor: const Color(0xFF080B12),
                        accentBarColor: AppTokens.primaryLight,
                        onTap: () {
                          ref
                              .read(themeModeProvider.notifier)
                              .setThemeMode(ThemeMode.dark);
                        },
                      ),
                    ),
                    const Spacing.vertical(10),
                    Expanded(
                      child: ThemePreviewBox(
                        label: 'Light',
                        isSelected: !isDark,
                        previewBgColor: const Color(0xFFF1F5F9),
                        accentBarColor: AppTokens.primaryDark,
                        onTap: () {
                          ref
                              .read(themeModeProvider.notifier)
                              .setThemeMode(ThemeMode.light);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Spacing.vertical(20),

            // Notifications Section
            SettingsSectionContainer(
              title: 'NOTIFICATIONS',
              cardColor: cardColor,
              borderColor: borderColor,
              mutedForeground: mutedForeground,
              children: [
                SettingToggleRow(
                  icon: Icons.notifications_none_rounded,
                  label: 'Transaction alerts',
                  desc: 'Get notified on every purchase',
                  value: userSettings.txnAlerts,
                  onChanged: (v) =>
                      ref.read(userSettingsProvider.notifier).setTxnAlerts(v),
                  foregroundColor: foregroundColor,
                  mutedForeground: mutedForeground,
                ),
                Divider(color: borderColor, height: 20),
                SettingToggleRow(
                  icon: Icons.shield_outlined,
                  label: 'Flagged purchases',
                  desc: 'Immediate alerts for blocked items',
                  value: userSettings.flaggedPurchases,
                  onChanged: (v) => ref
                      .read(userSettingsProvider.notifier)
                      .setFlaggedPurchases(v),
                  foregroundColor: foregroundColor,
                  mutedForeground: mutedForeground,
                ),
                Divider(color: borderColor, height: 20),
                SettingToggleRow(
                  icon: Icons.alarm_rounded,
                  label: 'Allowance reminders',
                  desc: 'Weekly top-up reminder',
                  value: userSettings.allowanceReminders,
                  onChanged: (v) => ref
                      .read(userSettingsProvider.notifier)
                      .setAllowanceReminders(v),
                  foregroundColor: foregroundColor,
                  mutedForeground: mutedForeground,
                ),
              ],
            ),

            const Spacing.vertical(20),

            // Security Section
            SettingsSectionContainer(
              title: 'SECURITY',
              cardColor: cardColor,
              borderColor: borderColor,
              mutedForeground: mutedForeground,
              children: [
                SettingToggleRow(
                  icon: Icons.fingerprint_rounded,
                  label: 'Biometric unlock',
                  desc: 'Touch ID or Face ID required',
                  value: userSettings.biometricUnlock,
                  onChanged: (v) => ref
                      .read(userSettingsProvider.notifier)
                      .setBiometricUnlock(v),
                  foregroundColor: foregroundColor,
                  mutedForeground: mutedForeground,
                ),
                Divider(color: borderColor, height: 20),
                SettingToggleRow(
                  icon: Icons.pin_outlined,
                  label: 'Parent PIN',
                  desc: '4-digit PIN for parent access',
                  value: userSettings.parentPin,
                  onChanged: (v) =>
                      ref.read(userSettingsProvider.notifier).setParentPin(v),
                  foregroundColor: foregroundColor,
                  mutedForeground: mutedForeground,
                ),
                Divider(color: borderColor, height: 20),
                SettingToggleRow(
                  icon: Icons.lock_outline_rounded,
                  label: 'Spending alerts',
                  desc: 'Notify on unusual patterns',
                  value: userSettings.spendingAlerts,
                  onChanged: (v) => ref
                      .read(userSettingsProvider.notifier)
                      .setSpendingAlerts(v),
                  foregroundColor: foregroundColor,
                  mutedForeground: mutedForeground,
                ),
              ],
            ),

            const Spacing.vertical(20),

            // About Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: AppTokens.borderRadiusXl,
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Column(
                children: [
                  const HapoPayLogo(size: 48),
                  const Spacing.vertical(10),
                  Text(
                    'HapoPay',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: foregroundColor,
                    ),
                  ),
                  const Spacing.vertical(2),
                  FutureBuilder<PackageInfo>(
                    future: appVersionCheck(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Text(
                          'Loading version…',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: mutedForeground,
                          ),
                        );
                      }

                      final packageInfo = snapshot.data!;

                      return Text(
                        '${packageInfo.version} (${packageInfo.buildNumber}) · Built with love 💜',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: mutedForeground,
                        ),
                      );
                    },
                  ),
                  const Spacing.vertical(14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Wire url_launcher when Privacy/Terms are hosted —
                      // see docs/legal/PRIVACY_POLICY_CHECKLIST.md
                      TextLink(label: 'Privacy Policy', onTap: () {}),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('·', style: TextStyle(color: borderColor)),
                      ),
                      TextLink(label: 'Terms of Service', onTap: () {}),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('·', style: TextStyle(color: borderColor)),
                      ),
                      TextLink(label: 'Support', onTap: () {}),
                    ],
                  ),
                ],
              ),
            ),

            const Spacing.vertical(22),

            // Logout CTA Button
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppTokens.warning.withValues(alpha: 0.1),
                borderRadius: AppTokens.borderRadiusLg,
                border: Border.all(
                  color: AppTokens.warning.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  borderRadius: AppTokens.borderRadiusLg,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        color: AppTokens.warning,
                        size: 20,
                      ),
                      const Spacing.horizontal(8),
                      Text(
                        'Sign Out',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTokens.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Spacing.vertical(32),
          ],
        ),
      ),
    );
  }
}
