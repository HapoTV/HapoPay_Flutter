import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../models/student_account_model.dart';
import '../repository/student_account_repository.dart';

part 'student_account_provider.g.dart';

@riverpod
class StudentAccount extends _$StudentAccount {
  @override
  Future<StudentAccountModel> build() async {
    return _fetch();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  /// Processes payment using a scanned QR payload.
  Future<void> payWithQr(String qrPayload) async {
    final studentId = _studentId();
    final updated = await ref
        .read(studentAccountRepositoryProvider)
        .processPayment(studentId: studentId, qrPayload: qrPayload);
    if (!ref.mounted) return;
    state = AsyncData(updated);
  }

  /// Updates the daily spending limit. A limit of `0` locks the card.
  Future<void> updateLimit(double limit) async {
    final studentId = _studentId();
    final updated = await ref
        .read(studentAccountRepositoryProvider)
        .updateSpendingLimit(studentId: studentId, limit: limit);
    if (!ref.mounted) return;
    state = AsyncData(updated);
  }

  Future<StudentAccountModel> _fetch() {
    return ref
        .read(studentAccountRepositoryProvider)
        .fetchAccount(_studentId());
  }

  String _studentId() {
    ref.watch(authProvider);
    final id = ref.read(authProvider).user?.id;
    if (id == null || id.isEmpty) return 'student_123';
    return id;
  }
}
