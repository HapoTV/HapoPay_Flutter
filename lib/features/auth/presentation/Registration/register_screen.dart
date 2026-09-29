import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hapopay/core/constants/constants.dart';
import 'package:hapopay/features/auth/presentation/Registration/widgets/role_card.dart';
import 'package:hapopay/features/auth/presentation/Registration/widgets/rule_row.dart';
import 'package:hapopay/features/auth/presentation/Registration/widgets/step_circle.dart';
import 'package:hapopay/features/auth/presentation/Registration/widgets/summary_card.dart';
import 'package:hapopay/shared/providers/app_shell_provider.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../../shared/widgets/hapo_pay_logo.dart';
import '../../../../shared/widgets/theme_toggle.dart';
import '../providers/auth_providers.dart';
import '../providers/register_state_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _familyCodeController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _familyCodeController.dispose();
    super.dispose();
  }

  int _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;
    if (password.length < 6) return 1;
    final hasNumber = RegExp(r'\d').hasMatch(password);
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    if (password.length >= 8 && hasNumber && hasLetter && hasSpecial) return 3;
    if (password.length >= 6 && (hasNumber || hasLetter)) return 2;
    return 1;
  }

  void _onNextStep() {
    final state = ref.read(registerStateProvider);
    if (state.currentStep < 3) {
      ref
          .read(registerStateProvider.notifier)
          .validateAndAdvance(
            fullName: _fullNameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
          );
    } else {
      _onRegister();
    }
  }

  Future<void> _onRegister() async {
    // -------------------------------------------------------------------------
    // API Registration (Commented out for UI review & testing)
    // -------------------------------------------------------------------------
    // final success = await ref.read(registerStateProvider.notifier).register(
    //       fullName: _fullNameController.text,
    //       email: _emailController.text,
    //       password: _passwordController.text,
    //     );
    //
    // if (!mounted) return;
    //
    // if (success) {
    //   final authState = ref.read(authProvider);
    //   if (authState.isAuthenticated) {
    //     context.go(authState.user?.isParent == true ? '/parent' : '/student');
    //   }
    // }

    // Direct UI testing navigation based on selected role:
    final selectedRole = ref.read(registerStateProvider).selectedRole;
    ref.read(appRoleProvider.notifier).setRole(selectedRole);
    context.go(selectedRole == UserRole.parent ? '/parent' : '/student');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final registerState = ref.watch(registerStateProvider);
    final currentStep = registerState.currentStep;
    final selectedRole = registerState.selectedRole;
    final isLoading = registerState.isLoading;
    final inviteCode = registerState.inviteCode;

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

    final pw = _passwordController.text;
    final pwStrength = _calculatePasswordStrength(pw);
    final strengthLabels = ['', 'Weak', 'Good', 'Strong'];
    final strengthColors = [
      Colors.transparent,
      AppTokens.warning,
      AppTokens.gold,
      AppTokens.accent,
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Top ambient radial gradient glow (Mint accent)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.2, -0.8),
                    radius: 1.0,
                    colors: [
                      AppTokens.accent.withValues(alpha: isDark ? 0.18 : 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Row: Back button (if step > 1) & Theme Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (currentStep > 1)
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: foregroundColor,
                            size: 22,
                          ),
                          onPressed: () => ref
                              .read(registerStateProvider.notifier)
                              .previousStep(),
                        )
                      else
                        const Spacing.horizontal(48),
                      ThemeToggle(),
                    ],
                  ),

                  const Spacing.vertical(8),

                  // Header
                  Center(
                    child: Column(
                      children: [
                        //Logo
                        const HapoPayLogo(size: 56),
                        const Spacing.vertical(12),
                        Text(
                          'Create account',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: foregroundColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Spacing.vertical(2),
                        Text(
                          'Join HapoPay in seconds',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacing.vertical(24),

                  // 3-Step Indicator Bar
                  Row(
                    children: [
                      for (int s = 1; s <= 3; s++) ...[
                        StepCircle(
                          stepNumber: s,
                          currentStep: currentStep,
                          isDark: isDark,
                        ),
                        if (s < 3)
                          Expanded(
                            child: Container(
                              height: 3,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                color: currentStep > s
                                    ? AppTokens.accent
                                    : (isDark
                                          ? AppTokens.darkMuted
                                          : AppTokens.lightMuted),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),

                  const Spacing.vertical(28),

                  // Step 1: Role & Profile Info
                  if (currentStep == 1) ...[
                    Text(
                      'Who are you?',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: foregroundColor,
                      ),
                    ),
                    const Spacing.vertical(12),

                    // Role Cards (Parent / Student)
                    Row(
                      children: [
                        Expanded(
                          child: RoleCard(
                            role: UserRole.parent,
                            label: 'Parent',
                            subtitle: 'Manage & monitor',
                            emoji: '👨‍👩‍👧',
                            isSelected: selectedRole == UserRole.parent,
                            selectedBorderColor: AppTokens.primary,
                            selectedBgColor: AppTokens.primary.withValues(
                              alpha: 0.12,
                            ),
                            onTap: () => ref
                                .read(registerStateProvider.notifier)
                                .setRole(UserRole.parent),
                            isDark: isDark,
                          ),
                        ),
                        const Spacing.horizontal(12),
                        Expanded(
                          child: RoleCard(
                            role: UserRole.student,
                            label: 'Student',
                            subtitle: 'Spend & earn',
                            emoji: '🎒',
                            isSelected: selectedRole == UserRole.student,
                            selectedBorderColor: AppTokens.accent,
                            selectedBgColor: AppTokens.accent.withValues(
                              alpha: 0.12,
                            ),
                            onTap: () => ref
                                .read(registerStateProvider.notifier)
                                .setRole(UserRole.student),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),

                    const Spacing.vertical(20),
                    //Names label
                    Text(
                      'FULL NAME',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: mutedForeground,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacing.vertical(6),
                    //Full name textfield
                    TextField(
                      controller: _fullNameController,
                      textInputAction: TextInputAction.next,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: foregroundColor,
                      ),
                      decoration: InputDecoration(
                        hintText: selectedRole == UserRole.parent
                            ? 'e.g. Ama Mensah'
                            : 'e.g. Amara Mensah',
                        prefixIcon: Icon(
                          Icons.person_outline_rounded,
                          color: mutedForeground,
                          size: 20,
                        ),
                      ),
                    ),

                    const Spacing.vertical(16),
                    //Email label
                    Text(
                      'EMAIL',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: mutedForeground,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacing.vertical(6),
                    //Email textfield
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: foregroundColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'you@example.com',
                        prefixIcon: Icon(
                          Icons.mail_outline_rounded,
                          color: mutedForeground,
                          size: 20,
                        ),
                      ),
                    ),
                  ],

                  // Step 2: Password & Verification
                  if (currentStep == 2) ...[
                    Text(
                      'Set a password',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: foregroundColor,
                      ),
                    ),
                    const Spacing.vertical(16),
                    //Password label
                    Text(
                      'PASSWORD',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: mutedForeground,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacing.vertical(6),
                    //Password textfield
                    TextField(
                      controller: _passwordController,
                      obscureText: registerState.obscurePassword,
                      textInputAction: TextInputAction.next,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: foregroundColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Min. 6 characters',
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          color: mutedForeground,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            registerState.obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: mutedForeground,
                            size: 20,
                          ),
                          onPressed: () => ref
                              .read(registerStateProvider.notifier)
                              .togglePasswordVisibility(),
                        ),
                      ),
                    ),

                    // Password Strength Meter
                    if (pw.isNotEmpty) ...[
                      const Spacing.vertical(10),
                      Row(
                        children: [
                          for (int i = 1; i <= 3; i++) ...[
                            Expanded(
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: pwStrength >= i
                                      ? strengthColors[pwStrength]
                                      : (isDark
                                            ? AppTokens.darkMuted
                                            : AppTokens.lightMuted),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            if (i < 3) const Spacing.horizontal(6),
                          ],
                          const Spacing.vertical(10),
                          Text(
                            strengthLabels[pwStrength],
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: strengthColors[pwStrength],
                            ),
                          ),
                        ],
                      ),
                    ],

                    const Spacing.vertical(16),
                    //Password Confirm label
                    Text(
                      'CONFIRM PASSWORD',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: mutedForeground,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacing.vertical(6),
                    //Confirm password textfield
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: registerState.obscureConfirm,
                      textInputAction: TextInputAction.done,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: foregroundColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Re-enter password',
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          color: mutedForeground,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            registerState.obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: mutedForeground,
                            size: 20,
                          ),
                          onPressed: () => ref
                              .read(registerStateProvider.notifier)
                              .toggleConfirmVisibility(),
                        ),
                      ),
                    ),

                    // Password Match badge
                    if (_confirmPasswordController.text.isNotEmpty &&
                        _confirmPasswordController.text == pw) ...[
                      const Spacing.vertical(8),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppTokens.accent,
                            size: 16,
                          ),
                          const Spacing.horizontal(6),
                          Text(
                            'Passwords match',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTokens.accent,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const Spacing.vertical(16),

                    // Password Checklist Rules
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: secondaryBg,
                        borderRadius: AppTokens.borderRadiusLg,
                      ),
                      child: Column(
                        children: [
                          RuleRow(
                            label: 'At least 6 characters',
                            isMet: pw.length >= 6,
                            isDark: isDark,
                          ),
                          const Spacing.vertical(8),
                          RuleRow(
                            label: 'Contains a number',
                            isMet: RegExp(r'\d').hasMatch(pw),
                            isDark: isDark,
                          ),
                          const Spacing.vertical(8),
                          RuleRow(
                            label: 'Contains a letter',
                            isMet: RegExp(r'[a-zA-Z]').hasMatch(pw),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Step 3: Family Setup & Summary
                  if (currentStep == 3) ...[
                    Text(
                      selectedRole == UserRole.student
                          ? 'Join a family'
                          : 'Set up your family',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: foregroundColor,
                      ),
                    ),
                    const Spacing.vertical(14),

                    if (selectedRole == UserRole.student) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTokens.accent.withValues(alpha: 0.1),
                          borderRadius: AppTokens.borderRadiusLg,
                          border: Border.all(
                            color: AppTokens.accent.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('💡', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Ask your parent for the family invite code to link your accounts.',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: foregroundColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacing.vertical(16),
                      //Invite code label
                      Text(
                        'FAMILY INVITE CODE',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: mutedForeground,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacing.vertical(6),
                      //Invite code textfield
                      TextField(
                        controller: _familyCodeController,
                        textCapitalization: TextCapitalization.characters,
                        style: GoogleFonts.dmMono(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: foregroundColor,
                          letterSpacing: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. HAPOFAM-4829',
                          prefixIcon: Icon(
                            Icons.vpn_key_outlined,
                            color: mutedForeground,
                            size: 20,
                          ),
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: AppTokens.borderRadiusLg,
                          border: Border.all(color: borderColor, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your family invite code',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: mutedForeground,
                              ),
                            ),
                            const Spacing.vertical(4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  inviteCode,
                                  style: GoogleFonts.dmMono(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppTokens.primary,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.copy),
                                  iconSize: 18,
                                  color: mutedForeground,
                                  tooltip: "Copy to clipboard",
                                  onPressed: () async {
                                    await Clipboard.setData(
                                      ClipboardData(text: inviteCode),
                                    );
                                    if (!context.mounted) return;
                                    // 4. Success feedback to user
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Text copied to clipboard!',
                                        ),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const Spacing.vertical(4),
                            Text(
                              'Share this with your children to link their accounts',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const Spacing.vertical(18),

                    // Account Summary Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: secondaryBg,
                        borderRadius: AppTokens.borderRadiusLg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ACCOUNT SUMMARY',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: mutedForeground,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacing.vertical(12),
                          SummaryRow(
                            label: 'Name',
                            value: _fullNameController.text,
                            foregroundColor: foregroundColor,
                            mutedColor: mutedForeground,
                          ),
                          const Spacing.vertical(8),
                          SummaryRow(
                            label: 'Email',
                            value: _emailController.text,
                            foregroundColor: foregroundColor,
                            mutedColor: mutedForeground,
                          ),
                          const Spacing.vertical(8),
                          SummaryRow(
                            label: 'Role',
                            value: selectedRole == UserRole.parent
                                ? '👤 Parent'
                                : '🎒 Student',
                            foregroundColor: foregroundColor,
                            mutedColor: mutedForeground,
                          ),
                        ],
                      ),
                    ),

                    const Spacing.vertical(14),

                    // Terms disclaimer
                    Center(
                      child: Text(
                        "By signing up you agree to HapoPay's Terms & Privacy Policy",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: mutedForeground,
                        ),
                      ),
                    ),
                  ],

                  // Error Message Banner
                  if (registerState.errorMessage != null) ...[
                    const Spacing.vertical(16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppTokens.warning.withValues(alpha: 0.12),
                        borderRadius: AppTokens.borderRadiusMd,
                        border: Border.all(
                          color: AppTokens.warning.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppTokens.warning,
                            size: 18,
                          ),
                          const Spacing.horizontal(8),
                          Expanded(
                            child: Text(
                              registerState.errorMessage!,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppTokens.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Spacing.vertical(24),

                  // CTA Button
                  AppPrimaryButton(
                    label: currentStep == 3 ? 'Create Account' : 'Continue  →',
                    isLoading: isLoading,
                    onPressed: _onNextStep,
                  ),

                  const Spacing.vertical(24),

                  // Footer Link to Sign In
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: mutedForeground,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: Text(
                          'Sign in',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTokens.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacing.vertical(16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
