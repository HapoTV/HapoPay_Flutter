// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rewards_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$earnedAchievementsCountHash() =>
    r'c20b9bce66b493cad05a754971acf2c191271044';

/// See also [earnedAchievementsCount].
@ProviderFor(earnedAchievementsCount)
final earnedAchievementsCountProvider = AutoDisposeProvider<int>.internal(
  earnedAchievementsCount,
  name: r'earnedAchievementsCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$earnedAchievementsCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EarnedAchievementsCountRef = AutoDisposeProviderRef<int>;
String _$rewardsHash() => r'48c1db478a708a857992a784db65c86a3ce3cb41';

/// See also [Rewards].
@ProviderFor(Rewards)
final rewardsProvider =
    AutoDisposeAsyncNotifierProvider<Rewards, RewardModel>.internal(
      Rewards.new,
      name: r'rewardsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$rewardsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Rewards = AutoDisposeAsyncNotifier<RewardModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
