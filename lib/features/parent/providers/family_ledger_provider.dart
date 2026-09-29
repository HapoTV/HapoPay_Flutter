import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/parent_catalog.dart';
import '../presentation/screens/models/transaction_record_model.dart';
import '../repository/parent_repository.dart';

class FamilyLedgerState {
  final String filterChild; // 'all', 'Amara', 'Kwame'
  final String filterStatus; // 'all', 'approved', 'flagged'
  final List<TxnRecord> allTransactions;

  const FamilyLedgerState({
    this.filterChild = 'all',
    this.filterStatus = 'all',
    this.allTransactions = const [],
  });

  List<TxnRecord> get filteredTransactions {
    return allTransactions.where((t) {
      if (filterChild != 'all' && t.child != filterChild) return false;
      if (filterStatus != 'all' && t.status != filterStatus) return false;
      return true;
    }).toList();
  }

  double get totalIn => filteredTransactions
      .where((t) => t.amount > 0)
      .fold<double>(0.0, (sum, t) => sum + t.amount);

  double get totalOut => filteredTransactions
      .where((t) => t.amount < 0)
      .fold<double>(0.0, (sum, t) => sum + t.amount.abs());

  Map<String, List<TxnRecord>> get groupedByDate {
    final Map<String, List<TxnRecord>> map = {};
    for (final t in filteredTransactions) {
      map.putIfAbsent(t.date, () => []).add(t);
    }
    return map;
  }

  FamilyLedgerState copyWith({
    String? filterChild,
    String? filterStatus,
    List<TxnRecord>? allTransactions,
  }) {
    return FamilyLedgerState(
      filterChild: filterChild ?? this.filterChild,
      filterStatus: filterStatus ?? this.filterStatus,
      allTransactions: allTransactions ?? this.allTransactions,
    );
  }
}

class FamilyLedgerNotifier extends Notifier<FamilyLedgerState> {
  @override
  FamilyLedgerState build() {
    Future.microtask(_loadFromApi);
    return FamilyLedgerState(
      allTransactions: ParentCatalog.ledgerFromJson(ParentCatalog.ledgerJson()),
    );
  }

  Future<void> _loadFromApi() async {
    try {
      final txns = await ref.read(parentRepositoryProvider).fetchLedger();
      state = state.copyWith(allTransactions: txns);
    } catch (_) {
      // Keep the seed ledger when the API is unreachable.
    }
  }

  void setFilterChild(String child) {
    state = state.copyWith(filterChild: child);
  }

  void setFilterStatus(String status) {
    state = state.copyWith(filterStatus: status);
  }
}

final familyLedgerProvider =
    NotifierProvider<FamilyLedgerNotifier, FamilyLedgerState>(
      FamilyLedgerNotifier.new,
    );
