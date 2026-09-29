import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../data/parent_catalog.dart';
import '../models/child_model.dart';
import '../models/parent_model.dart';
import '../models/spend_model.dart';
import '../presentation/screens/models/transaction_record_model.dart';

class ParentDashboardData {
  const ParentDashboardData({
    required this.familyBalance,
    required this.addedThisWeek,
    required this.showAlert,
    required this.alertMessage,
    required this.children,
    required this.spendCategories,
    required this.recentTxns,
  });

  final double familyBalance;
  final double addedThisWeek;
  final bool showAlert;
  final String alertMessage;
  final List<ChildProfile> children;
  final List<SpendCategory> spendCategories;
  final List<ParentTxn> recentTxns;

  factory ParentDashboardData.fromJson(Map<String, dynamic> json) {
    final parsed = ParentCatalog.dashboardFromJson(json);
    return ParentDashboardData(
      familyBalance: parsed.familyBalance,
      addedThisWeek: parsed.addedThisWeek,
      showAlert: parsed.showAlert,
      alertMessage: parsed.alertMessage,
      children: parsed.children,
      spendCategories: parsed.spendCategories,
      recentTxns: parsed.recentTxns,
    );
  }
}

class ParentRepository {
  ParentRepository(this._dio);

  final Dio _dio;

  /// `GET /parent/dashboard/`
  Future<ParentDashboardData> fetchDashboard() async {
    final response = await _dio.get('/parent/dashboard/');
    return ParentDashboardData.fromJson(response.data as Map<String, dynamic>);
  }

  /// `GET /parent/ledger/`
  Future<List<TxnRecord>> fetchLedger() async {
    final response = await _dio.get('/parent/ledger/');
    return ParentCatalog.ledgerFromJson(response.data as Map<String, dynamic>);
  }
}

final parentRepositoryProvider = Provider<ParentRepository>((ref) {
  return ParentRepository(ref.watch(dioProvider));
});
