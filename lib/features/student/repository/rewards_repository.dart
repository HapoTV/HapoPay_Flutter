/// rewards_repository.dart
/// Handles all HTTP communication with the /api/rewards/ endpoint.
/// Wired through the app-wide Dio instance so auth headers, base URL,
/// and logging interceptors are applied automatically.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';
import '../models/reward_model.dart';

part 'rewards_repository.g.dart';

class RewardsRepository {
  final Dio _dio;

  RewardsRepository(this._dio);

  // -------------------------------------------------------------------------
  // Fetch full reward state for a student.
  // GET /api/rewards/{studentId}/
  // -------------------------------------------------------------------------
  Future<RewardModel> fetchRewards(String studentId) async {
    final response = await _dio.get('/rewards/$studentId/');
    return RewardModel.fromJson(response.data as Map<String, dynamic>);
  }

  // -------------------------------------------------------------------------
  // Claim an earned-but-unclaimed achievement.
  // POST /api/rewards/{studentId}/claim/
  // Returns the updated RewardModel.
  // -------------------------------------------------------------------------
  Future<RewardModel> claimAchievement(
    String studentId,
    String achievementId,
  ) async {
    final response = await _dio.post(
      '/rewards/$studentId/claim/',
      data: {'achievement_id': achievementId},
    );
    return RewardModel.fromJson(response.data as Map<String, dynamic>);
  }
}

@riverpod
RewardsRepository rewardsRepository(Ref ref) {
  return RewardsRepository(ref.watch(dioProvider));
}
