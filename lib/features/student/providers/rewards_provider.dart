/// rewards_provider.dart
/// Riverpod AsyncNotifier that owns the rewards state for the current student.
/// Exposes refresh() and claimAchievement() for UI actions.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/reward_model.dart';
import '../models/rewards_catalog.dart';

part 'rewards_provider.g.dart';

// ---------------------------------------------------------------------------
// Rewards AsyncNotifier
// ---------------------------------------------------------------------------

@riverpod
class Rewards extends _$Rewards {
  @override
  Future<RewardModel> build() async {
    // -------------------------------------------------------------------------
    // API Call (Commented out for UI testing)
    // -------------------------------------------------------------------------
    // final user = ref.watch(authProvider).user;
    // final studentId = user?.id;
    // if (studentId == null || studentId.isEmpty) {
    //   return RewardModel.demo(studentId: 'student_123');
    // }
    // return ref.read(rewardsRepositoryProvider).fetchRewards(studentId);

    return RewardModel.demo(studentId: 'student_123');
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    // state = await AsyncValue.guard(() => _fetch());
    state = AsyncData(RewardModel.demo(studentId: 'student_123'));
  }

  /// Claim an earned achievement.
  /// Optimistically bumps points/tier for UI testing.
  Future<void> claimAchievement(String achievementId) async {
    final previous = state;
    final current = previous.asData?.value;
    if (current == null) return;

    state = AsyncData(RewardsCatalog.applyClaim(current, achievementId));

    // -------------------------------------------------------------------------
    // API Call (Commented out for UI testing)
    // -------------------------------------------------------------------------
    // try {
    //   final user = ref.read(authProvider).user;
    //   final studentId = user?.id;
    //   if (studentId == null || studentId.isEmpty) {
    //     throw StateError('Sign in to claim rewards');
    //   }
    //   final updated = await ref
    //       .read(rewardsRepositoryProvider)
    //       .claimAchievement(studentId, achievementId);
    //   if (!ref.mounted) return;
    //   state = AsyncData(updated);
    // } catch (e) {
    //   if (!ref.mounted) rethrow;
    //   state = previous;
    //   rethrow;
    // }
  }
}

@riverpod
int earnedAchievementsCount(Ref ref) {
  return ref.watch(rewardsProvider).value?.earnedAchievementsCount ?? 0;
}
