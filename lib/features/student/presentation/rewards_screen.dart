/// rewards_screen.dart
/// Full-page Student Rewards UI — tiers, progress, achievements, streaks.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reward_model.dart';
import '../providers/rewards_provider.dart';

// ---------------------------------------------------------------------------
// Tier colour palette
// ---------------------------------------------------------------------------

const _tierColors = {
  RewardTier.bronze: Color(0xFFCD7F32),
  RewardTier.silver: Color(0xFFC0C0C0),
  RewardTier.gold: Color(0xFFFFD700),
  RewardTier.platinum: Color(0xFF00E5FF),
};

const _tierGradients = {
  RewardTier.bronze: [Color(0xFF8B4513), Color(0xFFCD7F32)],
  RewardTier.silver: [Color(0xFF708090), Color(0xFFC0C0C0)],
  RewardTier.gold: [Color(0xFFB8860B), Color(0xFFFFD700)],
  RewardTier.platinum: [Color(0xFF006064), Color(0xFF00E5FF)],
};

// ---------------------------------------------------------------------------
// Icon mapping from string keys stored in AchievementModel
// ---------------------------------------------------------------------------

IconData _iconFromString(String name) {
  const map = {
    'payment': Icons.payment,
    'savings': Icons.savings,
    'qr_code_scanner': Icons.qr_code_scanner,
    'local_fire_department': Icons.local_fire_department,
    'account_balance_wallet': Icons.account_balance_wallet,
    'share': Icons.share,
    'emoji_events': Icons.emoji_events,
    'star': Icons.star,
    'school': Icons.school,
    'shopping_cart': Icons.shopping_cart,
  };
  return map[name] ?? Icons.emoji_events;
}

// ===========================================================================
// Screen
// ===========================================================================

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _heroController;
  late final Animation<double> _heroFade;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _heroFade = CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutCubic,
    );
    _heroController.forward();
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rewardsAsync = ref.watch(rewardsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Rewards',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => ref.read(rewardsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: rewardsAsync.when(
        loading: () => const _LoadingSkeleton(),
        error: (e, _) => _ErrorBody(
          onRetry: () {
            ref.read(rewardsProvider.notifier).refresh();
          },
        ),
        data: (reward) => RefreshIndicator(
          color: _tierColors[reward.tier] ?? Colors.amber,
          onRefresh: () => ref.read(rewardsProvider.notifier).refresh(),
          child: FadeTransition(
            opacity: _heroFade,
            child: _RewardsBody(reward: reward),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Main body — rendered once we have data
// ===========================================================================

class _RewardsBody extends ConsumerWidget {
  final RewardModel reward;

  const _RewardsBody({required this.reward});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // 1. Hero card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _HeroCard(reward: reward),
          ),
        ),

        // 2. Tier ladder
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            child: _TierLadder(currentTier: reward.tier),
          ),
        ),

        // 3. Stats row
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: _StatsRow(reward: reward),
          ),
        ),

        // 4. Section header
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 32, 20, 16),
            child: _SectionHeader(
              title: 'Achievements',
              subtitle: 'Complete goals to earn points',
            ),
          ),
        ),

        // 5. Achievement grid
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _AchievementCard(
                achievement: reward.achievements[i],
                onClaim: () {
                  ref
                      .read(rewardsProvider.notifier)
                      .claimAchievement(reward.achievements[i].id);
                },
              ),
              childCount: reward.achievements.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.82,
            ),
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// Hero card — points + tier + progress arc
// ===========================================================================

class _HeroCard extends StatelessWidget {
  final RewardModel reward;

  const _HeroCard({required this.reward});

  @override
  Widget build(BuildContext context) {
    final gradientColors =
        _tierGradients[reward.tier] ?? [Colors.purple, Colors.purpleAccent];
    final progress = reward.tierProgressFraction;
    final nextPoints = reward.nextMilestonePoints;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tier badge row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      reward.tier.badge,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      reward.tier.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Streak badge
              if (reward.streakDays > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.orangeAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${reward.streakDays}-day streak',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Points display
          const Text(
            'Total Points',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${reward.totalPoints}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'pts',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 24),

          // Progress bar toward next tier
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    nextPoints != null
                        ? 'Next tier in ${nextPoints - reward.totalPoints} pts'
                        : '🏆 Max tier reached!',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _AnimatedProgressBar(
                value: progress,
                backgroundColor: Colors.white24,
                foregroundColor: Colors.white,
                height: 8,
                borderRadius: 4,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Tier ladder strip
// ===========================================================================

class _TierLadder extends StatelessWidget {
  final RewardTier currentTier;

  const _TierLadder({required this.currentTier});

  @override
  Widget build(BuildContext context) {
    const tiers = RewardTier.values;
    final currentIndex = tiers.indexOf(currentTier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Tier Progress',
          subtitle: 'Your journey to the top',
        ),
        const SizedBox(height: 16),
        Row(
          children: List.generate(tiers.length, (i) {
            final tier = tiers[i];
            final isActive = i == currentIndex;
            final isUnlocked = i <= currentIndex;
            final color = _tierColors[tier] ?? Colors.grey;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? color.withValues(alpha: 0.2)
                            : isUnlocked
                                ? color.withValues(alpha: 0.08)
                                : const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isActive
                              ? color
                              : isUnlocked
                                  ? color.withValues(alpha: 0.3)
                                  : Colors.white12,
                          width: isActive ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            tier.badge,
                            style: TextStyle(fontSize: isActive ? 22 : 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tier.label,
                            style: TextStyle(
                              color: isActive
                                  ? color
                                  : isUnlocked
                                      ? color.withValues(alpha: 0.7)
                                      : Colors.white30,
                              fontSize: 11,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (i < tiers.length - 1)
                    Icon(
                      Icons.chevron_right,
                      color: isUnlocked
                          ? color.withValues(alpha: 0.5)
                          : Colors.white12,
                      size: 18,
                    ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ===========================================================================
// Stats row — earned achievements + streak
// ===========================================================================

class _StatsRow extends StatelessWidget {
  final RewardModel reward;

  const _StatsRow({required this.reward});

  @override
  Widget build(BuildContext context) {
    final total = reward.achievements.length;
    final earned = reward.earnedAchievementsCount;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.emoji_events_rounded,
            iconColor: Colors.amber,
            label: 'Achievements',
            value: '$earned / $total',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department_rounded,
            iconColor: Colors.deepOrangeAccent,
            label: 'Day Streak',
            value: '${reward.streakDays}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.workspace_premium_rounded,
            iconColor: _tierColors[reward.tier] ?? Colors.white,
            label: 'Tier',
            value: reward.tier.label,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Achievement card
// ===========================================================================

class _AchievementCard extends StatelessWidget {
  final AchievementModel achievement;
  final VoidCallback onClaim;

  const _AchievementCard({required this.achievement, required this.onClaim});

  @override
  Widget build(BuildContext context) {
    final isEarned = achievement.earned;
    final isClaimed = achievement.claimed;
    final canClaim = isEarned && !isClaimed;
    final progress = achievement.progressFraction;

    // Glow colour for earned cards
    const glowColor = Color(0xFFFFD700);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isEarned ? const Color(0xFF2A2A1A) : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEarned ? glowColor.withValues(alpha: 0.4) : Colors.white10,
          width: isEarned ? 1.5 : 1,
        ),
        boxShadow: isEarned
            ? [
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.12),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + claim button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isEarned
                        ? glowColor.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _iconFromString(achievement.icon),
                    color: isEarned ? glowColor : Colors.white30,
                    size: 22,
                  ),
                ),
                if (canClaim)
                  GestureDetector(
                    onTap: onClaim,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Claim',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else if (isClaimed)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.greenAccent,
                    size: 20,
                  )
                else
                  const Icon(
                    Icons.lock_rounded,
                    color: Colors.white24,
                    size: 18,
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Name
            Text(
              achievement.name,
              style: TextStyle(
                color: isEarned ? Colors.white : Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // Description
            Text(
              achievement.description,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const Spacer(),

            // Progress bar (if applicable)
            if (achievement.hasProgress && !isEarned) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${achievement.progress} / ${achievement.goal}',
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                  Text(
                    '${((progress ?? 0) * 100).toInt()}%',
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _AnimatedProgressBar(
                value: progress ?? 0,
                backgroundColor: Colors.white12,
                foregroundColor: const Color(0xFFBB86FC),
                height: 5,
                borderRadius: 3,
              ),
            ],

            const SizedBox(height: 10),

            // Points pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isEarned
                    ? glowColor.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bolt,
                    size: 12,
                    color: isEarned ? glowColor : Colors.white30,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '+${achievement.points} pts',
                    style: TextStyle(
                      color: isEarned ? glowColor : Colors.white30,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Animated progress bar
// ===========================================================================

class _AnimatedProgressBar extends StatefulWidget {
  final double value; // 0.0 – 1.0
  final Color backgroundColor;
  final Color foregroundColor;
  final double height;
  final double borderRadius;

  const _AnimatedProgressBar({
    required this.value,
    required this.backgroundColor,
    required this.foregroundColor,
    this.height = 8,
    this.borderRadius = 4,
  });

  @override
  State<_AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<_AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _anim = Tween<double>(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _anim = Tween<double>(
        begin: _anim.value,
        end: widget.value,
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: LinearProgressIndicator(
          value: _anim.value,
          backgroundColor: widget.backgroundColor,
          valueColor: AlwaysStoppedAnimation(widget.foregroundColor),
          minHeight: widget.height,
        ),
      ),
    );
  }
}

// ===========================================================================
// Loading skeleton
// ===========================================================================

class _LoadingSkeleton extends StatefulWidget {
  const _LoadingSkeleton();

  @override
  State<_LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<_LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _box({double height = 20, double? width, double radius = 10}) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: _anim.value * 0.2),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _box(height: 180, radius: 28), // hero
          const SizedBox(height: 24),
          _box(height: 16, width: 140), // section header
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _box(height: 80, radius: 12)),
              const SizedBox(width: 8),
              Expanded(child: _box(height: 80, radius: 12)),
              const SizedBox(width: 8),
              Expanded(child: _box(height: 80, radius: 12)),
              const SizedBox(width: 8),
              Expanded(child: _box(height: 80, radius: 12)),
            ],
          ),
          const SizedBox(height: 24),
          _box(height: 16, width: 120),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _box(height: 70, radius: 12)),
              const SizedBox(width: 12),
              Expanded(child: _box(height: 70, radius: 12)),
              const SizedBox(width: 12),
              Expanded(child: _box(height: 70, radius: 12)),
            ],
          ),
          const SizedBox(height: 28),
          _box(height: 16, width: 150),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.82,
            children: List.generate(
              4,
              (_) => _box(height: double.infinity, radius: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Error body
// ===========================================================================

class _ErrorBody extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorBody({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: Colors.redAccent,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Could not load rewards',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBB86FC),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Section header
// ===========================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}
