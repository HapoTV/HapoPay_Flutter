// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rewards_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Rewards)
final rewardsProvider = RewardsProvider._();

final class RewardsProvider
    extends $AsyncNotifierProvider<Rewards, RewardModel> {
  RewardsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'rewardsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$rewardsHash();

  @$internal
  @override
  Rewards create() => Rewards();
}

String _$rewardsHash() => r'442aaea883925ee036722c6a8bb1ab154ddc8b4f';

abstract class _$Rewards extends $AsyncNotifier<RewardModel> {
  FutureOr<RewardModel> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<RewardModel>, RewardModel>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<RewardModel>, RewardModel>,
        AsyncValue<RewardModel>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(earnedAchievementsCount)
final earnedAchievementsCountProvider = EarnedAchievementsCountProvider._();

final class EarnedAchievementsCountProvider
    extends $FunctionalProvider<int, int, int> with $Provider<int> {
  EarnedAchievementsCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'earnedAchievementsCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$earnedAchievementsCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return earnedAchievementsCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$earnedAchievementsCountHash() =>
    r'c20b9bce66b493cad05a754971acf2c191271044';
