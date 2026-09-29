import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/reward_model.dart';
import '../presentation/screens/models/achievement_item.dart';
import 'rewards_provider.dart';

class RewardsScreenState {
  final int totalPoints;
  final List<AchievementItem> achievements;
  final List<String> streakDays;
  final List<bool> completedDays;

  const RewardsScreenState({
    this.totalPoints = 0,
    this.streakDays = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
    this.completedDays = const [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
    ],
    this.achievements = const [],
  });

  factory RewardsScreenState.fromReward(RewardModel reward) {
    final streak = reward.streakDays.clamp(0, 7);
    return RewardsScreenState(
      totalPoints: reward.totalPoints,
      streakDays: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
      completedDays: List<bool>.generate(7, (index) => index < streak),
      achievements: [
        for (final achievement in reward.achievements)
          AchievementItem(
            id: achievement.id,
            title: achievement.name,
            desc: achievement.description,
            emoji: _emojiFor(achievement.icon),
            pts: achievement.points,
            isClaimed: achievement.claimed,
            isLocked: !achievement.earned,
          ),
      ],
    );
  }

  static String _emojiFor(String icon) {
    return switch (icon) {
      'payment' => '🎯',
      'qr_code_scanner' => '📱',
      'school' => '🏫',
      'savings' => '💰',
      'local_fire_department' => '🔥',
      'emoji_events' => '🏆',
      'shopping_cart' => '🛒',
      'account_balance_wallet' => '💳',
      _ => '⭐',
    };
  }
}

class RewardsScreenNotifier extends Notifier<RewardsScreenState> {
  @override
  RewardsScreenState build() {
    final reward = ref.watch(rewardsProvider).asData?.value;
    if (reward == null) {
      return RewardsScreenState.fromReward(RewardModel.demo(studentId: 'student_123'));
    }
    return RewardsScreenState.fromReward(reward);
  }

  /// Claims the achievement at [index] through `POST /rewards/{id}/claim/`.
  /// Returns the points awarded, or `0` when the claim is rejected.
  Future<int> claimAchievement(int index) async {
    if (index < 0 || index >= state.achievements.length) return 0;
    final item = state.achievements[index];
    if (item.isClaimed || item.isLocked) return 0;

    try {
      await ref.read(rewardsProvider.notifier).claimAchievement(item.id);
      return item.pts;
    } catch (_) {
      return 0;
    }
  }
}

final rewardsScreenProvider =
    NotifierProvider<RewardsScreenNotifier, RewardsScreenState>(
      RewardsScreenNotifier.new,
    );
