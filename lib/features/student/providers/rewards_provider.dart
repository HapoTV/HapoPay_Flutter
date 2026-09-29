/// rewards_provider.dart
/// Riverpod AsyncNotifier that owns the rewards state for the current student.
/// Exposes refresh() and claimAchievement() for UI actions.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../models/reward_model.dart';
import '../models/rewards_catalog.dart';
import '../repository/rewards_repository.dart';

part 'rewards_provider.g.dart';

@riverpod
class Rewards extends _$Rewards {
  @override
  Future<RewardModel> build() async {
    return _fetch();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  /// Claim an earned achievement.
  /// Optimistically bumps points, then reconciles with the server response.
  /// On failure the previous [AsyncData] is restored.
  Future<void> claimAchievement(String achievementId) async {
    final previous = state;
    final current = previous.asData?.value;
    if (current == null) return;

    state = AsyncData(RewardsCatalog.applyClaim(current, achievementId));

    try {
      final studentId = _studentId();
      if (studentId == null) {
        throw StateError('Sign in to claim rewards');
      }
      final updated = await ref
          .read(rewardsRepositoryProvider)
          .claimAchievement(studentId, achievementId);
      if (!ref.mounted) return;
      state = AsyncData(updated);
    } catch (e) {
      if (!ref.mounted) rethrow;
      state = previous;
      rethrow;
    }
  }

  Future<RewardModel> _fetch() async {
    final studentId = _studentId();
    if (studentId == null) {
      return RewardModel.demo(studentId: 'student_123');
    }
    return ref.read(rewardsRepositoryProvider).fetchRewards(studentId);
  }

  String? _studentId() {
    ref.watch(authProvider);
    final id = ref.read(authProvider).user?.id;
    if (id == null || id.isEmpty) return null;
    return id;
  }
}

@riverpod
int earnedAchievementsCount(Ref ref) {
  return ref.watch(rewardsProvider).value?.earnedAchievementsCount ?? 0;
}
