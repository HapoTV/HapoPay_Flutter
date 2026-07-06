/// rewards_provider.dart
/// Riverpod AsyncNotifier that owns the rewards state for the current student.
/// Exposes refresh() and claimAchievement() for UI actions.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/reward_model.dart';
import '../repository/rewards_repository.dart';

part 'rewards_provider.g.dart';

// ---------------------------------------------------------------------------
// Rewards AsyncNotifier
// ---------------------------------------------------------------------------

@riverpod
class Rewards extends _$Rewards {
  @override
  Future<RewardModel> build() async {
    // Derive student ID from authenticated user; fall back to 'demo' so the
    // UI always renders during development.
    final user = ref.watch(authProvider.select((s) => s.user));
    final studentId = user?.id ?? 'demo';
    return ref.read(rewardsRepositoryProvider).fetchRewards(studentId);
  }

  // -------------------------------------------------------------------------
  // Force a fresh fetch (e.g. after a payment transaction closes).
  // -------------------------------------------------------------------------
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch());
  }

  // -------------------------------------------------------------------------
  // Claim an earned achievement.
  // Uses optimistic local update before awaiting the server response.
  // -------------------------------------------------------------------------
  Future<void> claimAchievement(String achievementId) async {
    final previous = state;

    // Optimistic update: mark the achievement as claimed locally.
    state = previous.whenData((reward) {
      final updated = reward.achievements.map((a) {
        if (a.id == achievementId && a.earned && !a.claimed) {
          return a.copyWith(claimed: true);
        }
        return a;
      }).toList();
      return reward.copyWith(achievements: updated);
    });

    // Confirm with backend; on error roll back.
    try {
      final user = ref.read(authProvider.select((s) => s.user));
      final studentId = user?.id ?? 'demo';
      final updated = await ref
          .read(rewardsRepositoryProvider)
          .claimAchievement(studentId, achievementId);
      state = AsyncData(updated);
    } catch (e, st) {
      state = previous; // roll back optimistic update
      state = AsyncError(e, st);
    }
  }

  Future<RewardModel> _fetch() async {
    final user = ref.read(authProvider.select((s) => s.user));
    final studentId = user?.id ?? 'demo';
    return ref.read(rewardsRepositoryProvider).fetchRewards(studentId);
  }
}

// ---------------------------------------------------------------------------
// Convenience selector: earned achievements count (used by dashboard card)
// ---------------------------------------------------------------------------

@riverpod
int earnedAchievementsCount(Ref ref) {
  return ref
          .watch(rewardsProvider)
          .valueOrNull
          ?.earnedAchievementsCount ??
      0;
}
