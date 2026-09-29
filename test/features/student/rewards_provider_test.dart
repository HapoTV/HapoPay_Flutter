import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hapopay/features/auth/presentation/providers/auth_providers.dart';
import 'package:hapopay/features/student/models/reward_model.dart';
import 'package:hapopay/features/student/models/rewards_catalog.dart';
import 'package:hapopay/features/student/providers/rewards_provider.dart';
import 'package:hapopay/features/student/repository/rewards_repository.dart';

class _FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() {
    return const AuthState(
      status: AuthStatus.authenticated,
      user: AppUser(
        id: 'student_123',
        email: 'student@hapopay.com',
        fullName: 'Demo Student',
        role: UserRole.student,
      ),
    );
  }
}

class _FakeRewardsRepository extends RewardsRepository {
  _FakeRewardsRepository(this._data) : super(Dio());

  RewardModel _data;
  Exception? claimError;
  int claimCalls = 0;

  @override
  Future<RewardModel> fetchRewards(String studentId) async => _data;

  @override
  Future<RewardModel> claimAchievement(
    String studentId,
    String achievementId,
  ) async {
    claimCalls++;
    if (claimError != null) throw claimError!;
    await Future<void>.delayed(Duration.zero);
    _data = RewardsCatalog.applyClaim(_data, achievementId);
    return _data;
  }
}

void main() {
  late _FakeRewardsRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = _FakeRewardsRepository(
      RewardsCatalog.seedReward(studentId: 'student_123'),
    );
    container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(_FakeAuthNotifier.new),
        rewardsRepositoryProvider.overrideWithValue(repo),
      ],
    );
    // Keep autoDispose rewardsProvider alive across async claim gaps.
    container.listen(rewardsProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  test('loads seed rewards for authenticated student', () async {
    final reward = await container.read(rewardsProvider.future);
    expect(reward.totalPoints, 220);
    expect(reward.tier, RewardTier.silver);
  });

  test(
    'claimAchievement optimistically bumps points then reconciles',
    () async {
      await container.read(rewardsProvider.future);
      final before = container.read(rewardsProvider).requireValue;

      final claimFuture = container
          .read(rewardsProvider.notifier)
          .claimAchievement('qr_rookie');

      // Optimistic state should already reflect claim before await completes.
      final optimistic = container.read(rewardsProvider).requireValue;
      expect(optimistic.totalPoints, before.totalPoints + 50);
      expect(
        optimistic.achievements.firstWhere((a) => a.id == 'qr_rookie').claimed,
        isTrue,
      );

      await claimFuture;
      final after = container.read(rewardsProvider).requireValue;
      expect(after.totalPoints, before.totalPoints + 50);
      expect(repo.claimCalls, 1);
    },
  );

  test(
    'claimAchievement rolls back AsyncData on failure (no AsyncError wipe)',
    () async {
      await container.read(rewardsProvider.future);
      final before = container.read(rewardsProvider).requireValue;
      repo.claimError = Exception('network down');

      await expectLater(
        container.read(rewardsProvider.notifier).claimAchievement('qr_rookie'),
        throwsA(isA<Exception>()),
      );

      final state = container.read(rewardsProvider);
      expect(state.hasError, isFalse);
      expect(state.requireValue.totalPoints, before.totalPoints);
      expect(
        state.requireValue.achievements
            .firstWhere((a) => a.id == 'qr_rookie')
            .claimed,
        isFalse,
      );
    },
  );
}
