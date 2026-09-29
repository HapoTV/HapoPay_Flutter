import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';
import '../models/child_model.dart';
import '../models/parent_model.dart';
import '../models/spend_model.dart';
import '../presentation/screens/models/transaction_record_model.dart';
import 'parent_fixtures.dart';

/// Shared parent API fixtures so the mock server, Dio interceptor, and
/// offline fallback render the same family.
class ParentCatalog {
  ParentCatalog._();

  static const Map<String, Color> colors = {
    'primary': AppTokens.primary,
    'accent': AppTokens.accent,
    'warning': AppTokens.warning,
    'gold': AppTokens.gold,
  };

  static Map<String, dynamic> dashboardJson() => ParentFixtures.dashboardJson();

  static Map<String, dynamic> ledgerJson() => ParentFixtures.ledgerJson();

  static ({
    double familyBalance,
    double addedThisWeek,
    bool showAlert,
    String alertMessage,
    List<ChildProfile> children,
    List<SpendCategory> spendCategories,
    List<ParentTxn> recentTxns,
  })
  dashboardFromJson(Map<String, dynamic> json) {
    return (
      familyBalance: (json['family_balance'] as num? ?? 0).toDouble(),
      addedThisWeek: (json['added_this_week'] as num? ?? 0).toDouble(),
      showAlert: json['show_alert'] as bool? ?? false,
      alertMessage: json['alert_message'] as String? ?? '',
      children: (json['children'] as List<dynamic>? ?? [])
          .map((raw) => _child(raw as Map<String, dynamic>))
          .toList(),
      spendCategories: (json['spend_categories'] as List<dynamic>? ?? [])
          .map((raw) => _category(raw as Map<String, dynamic>))
          .toList(),
      recentTxns: (json['recent_transactions'] as List<dynamic>? ?? [])
          .map((raw) => _parentTxn(raw as Map<String, dynamic>))
          .toList(),
    );
  }

  static List<TxnRecord> ledgerFromJson(Map<String, dynamic> json) {
    return (json['transactions'] as List<dynamic>? ?? [])
        .map((raw) {
          final map = raw as Map<String, dynamic>;
          return TxnRecord(
            child: map['child'] as String? ?? '',
            merchant: map['merchant'] as String? ?? '',
            amount: (map['amount'] as num? ?? 0).toDouble(),
            date: map['date'] as String? ?? '',
            time: map['time'] as String? ?? '',
            cat: map['cat'] as String? ?? '',
            status: map['status'] as String? ?? 'approved',
          );
        })
        .toList();
  }

  static ChildProfile _child(Map<String, dynamic> json) {
    return ChildProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      avatar: json['avatar'] as String? ?? '',
      balance: (json['balance'] as num? ?? 0).toDouble(),
      limit: (json['limit'] as num? ?? 0).toDouble(),
      spent: (json['spent'] as num? ?? 0).toDouble(),
      color: colors[json['color'] as String?] ?? AppTokens.primary,
    );
  }

  static SpendCategory _category(Map<String, dynamic> json) {
    return SpendCategory(
      label: json['label'] as String? ?? '',
      pct: (json['pct'] as num? ?? 0).toDouble(),
      color: colors[json['color'] as String?] ?? AppTokens.primary,
    );
  }

  static ParentTxn _parentTxn(Map<String, dynamic> json) {
    return ParentTxn(
      childName: json['child_name'] as String? ?? '',
      merchant: json['merchant'] as String? ?? '',
      amount: (json['amount'] as num? ?? 0).toDouble(),
      time: json['time'] as String? ?? '',
      cat: json['cat'] as String? ?? '',
      approved: json['approved'] as bool? ?? true,
    );
  }
}
