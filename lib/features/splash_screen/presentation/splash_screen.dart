import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hapopay/core/constants/constants.dart';
import 'package:logger/logger.dart';

import '../../../core/theme/tokens.dart';
import '../../../shared/widgets/hapo_pay_logo.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback? onFinished;

  const SplashScreen({super.key, this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _floatController;
  late final AnimationController _pulseController;

  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _floatAnim;

  Timer? _timer;
  bool _hasNavigated = false;
  final logger = Logger();

  @override
  void initState() {
    super.initState();

    // 1. Entry Fade & Scale Animation (0 -> 1)
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );
    _entryController.forward();

    // 2. Floating bobbing animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // 3. Bottom pulsing dots sync animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // 4. Auto-navigation timer (3 seconds)
    _timer = Timer(const Duration(milliseconds: 3200), _navigateToNext);
  }

  void _navigateToNext() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _timer?.cancel();
    //logger.i('SplashScreen had been navigated, navigating to next screen.');

    if (widget.onFinished != null) {
      widget.onFinished!();
    } else {
      context.go('/login');
      logger.i('SplashScreen has been completed, navigating to next screen.');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _entryController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    return GestureDetector(
      onTap: _navigateToNext, // Tap anywhere to skip
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Stack(
          alignment: Alignment.center,
          children: [
            // Background ambient radial gradient glow
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.0, -0.2),
                      radius: 0.85,
                      colors: [
                        AppTokens.primary.withValues(
                          alpha: isDark ? 0.18 : 0.10,
                        ),
                        AppTokens.accent.withValues(
                          alpha: isDark ? 0.10 : 0.05,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Main floating logo & typography with Fade + Scale + Float
            Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: AnimatedBuilder(
                    animation: _floatAnim,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatAnim.value),
                        child: child,
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const HapoPayLogo(height: 72),
                        const Spacing.vertical(14),
                        Text(
                          'Smart spending for families',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Pulsing Dots Indicator inside SafeArea
            Positioned(
              bottom: 40,
              child: SafeArea(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) {
                        // Calculate staggered phase for each dot
                        final phase =
                            (_pulseController.value - (index * 0.25)) % 1.0;
                        final scale =
                            0.7 + (0.5 * (1.0 - (phase - 0.5).abs() * 2));
                        final opacity =
                            0.35 + (0.65 * (1.0 - (phase - 0.5).abs() * 2));

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          width: 8 * scale,
                          height: 8 * scale,
                          decoration: BoxDecoration(
                            color: AppTokens.primary.withValues(alpha: opacity),
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
