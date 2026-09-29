import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/tokens.dart';
import '../data/parent_catalog.dart';
import '../models/child_model.dart';
import '../models/parent_model.dart';
import '../models/spend_model.dart';
import '../repository/parent_repository.dart';

class ParentDashboardState {
  final double familyBalance;
  final double addedThisWeek;
  final int selectedChildIndex;
  final bool showAlert;
  final String alertMessage;
  final List<ChildProfile> children;
  final List<SpendCategory> spendCategories;
  final List<ParentTxn> recentTxns;

  const ParentDashboardState({
    this.familyBalance = 182.70,
    this.addedThisWeek = 50.00,
    this.selectedChildIndex = 0,
    this.showAlert = true,
    this.alertMessage = "Kwame's Game Shop purchase needs review",
    this.children = const [
      ChildProfile(
        name: 'Amara',
        age: 14,
        avatar: '🧕',
        balance: 124.50,
        limit: 200.0,
        spent: 75.50,
        color: AppTokens.primary,
      ),
      ChildProfile(
        name: 'Kwame',
        age: 11,
        avatar: '👦🏾',
        balance: 58.20,
        limit: 100.0,
        spent: 41.80,
        color: AppTokens.accent,
      ),
    ],
    this.spendCategories = const [
      SpendCategory(label: 'Food', pct: 42, color: AppTokens.primary),
      SpendCategory(label: 'Education', pct: 28, color: AppTokens.accent),
      SpendCategory(label: 'Transport', pct: 18, color: AppTokens.warning),
      SpendCategory(label: 'Entertainment', pct: 12, color: AppTokens.gold),
    ],
    this.recentTxns = const [
      ParentTxn(
        childName: 'Amara',
        merchant: 'School Canteen',
        amount: -4.50,
        time: 'Today, 12:30',
        cat: '🍔',
        approved: true,
      ),
      ParentTxn(
        childName: 'Kwame',
        merchant: 'Stationery World',
        amount: -12.00,
        time: 'Today, 10:15',
        cat: '📚',
        approved: true,
      ),
      ParentTxn(
        childName: 'Amara',
        merchant: 'Allowance',
        amount: 50.00,
        time: 'Yesterday',
        cat: '💸',
        approved: true,
      ),
      ParentTxn(
        childName: 'Kwame',
        merchant: 'Game Shop',
        amount: -18.00,
        time: 'Yesterday',
        cat: '🎮',
        approved: false,
      ),
      ParentTxn(
        childName: 'Amara',
        merchant: 'Bus Pass',
        amount: -15.00,
        time: 'Mon',
        cat: '🚌',
        approved: true,
      ),
    ],
  });

  ChildProfile get selectedChild =>
      children.isNotEmpty && selectedChildIndex < children.length
      ? children[selectedChildIndex]
      : children.first;

  ParentDashboardState copyWith({
    double? familyBalance,
    double? addedThisWeek,
    int? selectedChildIndex,
    bool? showAlert,
    String? alertMessage,
    List<ChildProfile>? children,
    List<SpendCategory>? spendCategories,
    List<ParentTxn>? recentTxns,
  }) {
    return ParentDashboardState(
      familyBalance: familyBalance ?? this.familyBalance,
      addedThisWeek: addedThisWeek ?? this.addedThisWeek,
      selectedChildIndex: selectedChildIndex ?? this.selectedChildIndex,
      showAlert: showAlert ?? this.showAlert,
      alertMessage: alertMessage ?? this.alertMessage,
      children: children ?? this.children,
      spendCategories: spendCategories ?? this.spendCategories,
      recentTxns: recentTxns ?? this.recentTxns,
    );
  }
}

class ParentDashboardNotifier extends Notifier<ParentDashboardState> {
  @override
  ParentDashboardState build() {
    Future.microtask(_loadFromApi);
    return _seed();
  }

  ParentDashboardState _seed() {
    final parsed = ParentCatalog.dashboardFromJson(ParentCatalog.dashboardJson());
    return ParentDashboardState(
      familyBalance: parsed.familyBalance,
      addedThisWeek: parsed.addedThisWeek,
      showAlert: parsed.showAlert,
      alertMessage: parsed.alertMessage,
      children: parsed.children,
      spendCategories: parsed.spendCategories,
      recentTxns: parsed.recentTxns,
    );
  }

  Future<void> _loadFromApi() async {
    try {
      final data = await ref.read(parentRepositoryProvider).fetchDashboard();
      final selected = state.selectedChildIndex;
      final alertVisible = state.showAlert;
      state = ParentDashboardState(
        familyBalance: data.familyBalance,
        addedThisWeek: data.addedThisWeek,
        selectedChildIndex: selected,
        showAlert: alertVisible && data.showAlert,
        alertMessage: data.alertMessage,
        children: data.children,
        spendCategories: data.spendCategories,
        recentTxns: data.recentTxns,
      );
    } catch (_) {
      // Keep the seed dashboard when the API is unreachable.
    }
  }

  void selectChild(int index) {
    if (index >= 0 && index < state.children.length) {
      state = state.copyWith(selectedChildIndex: index);
    }
  }

  void dismissAlert() {
    state = state.copyWith(showAlert: false);
  }

  void addChild(ChildProfile child) {
    state = state.copyWith(children: [...state.children, child]);
  }
}

final parentDashboardProvider =
    NotifierProvider<ParentDashboardNotifier, ParentDashboardState>(
      ParentDashboardNotifier.new,
    );
