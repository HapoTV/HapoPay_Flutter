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
    try {
      final response = await _dio.get('/rewards/$studentId/');
      return RewardModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // If the backend is not yet reachable (dev mode), return demo data
      // so the UI is always exercised.  Remove this fallback when backend
      // is stable and you want real error propagation.
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.response?.statusCode == 404) {
        return RewardModel.demo();
      }
      rethrow;
    }
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
    try {
      final response = await _dio.post(
        '/rewards/$studentId/claim/',
        data: {'achievement_id': achievementId},
      );
      return RewardModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // Fallback: optimistically mark achievement as claimed in demo data.
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.response?.statusCode == 404) {
        final demo = RewardModel.demo();
        final updatedAchievements = demo.achievements.map((a) {
          if (a.id == achievementId && a.earned) {
            return a.copyWith(claimed: true);
          }
          return a;
        }).toList();
        return demo.copyWith(achievements: updatedAchievements);
      }
      rethrow;
    }
  }
}

@riverpod
RewardsRepository rewardsRepository(Ref ref) {
  return RewardsRepository(ref.watch(dioProvider));
}
