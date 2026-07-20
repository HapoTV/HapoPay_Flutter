import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/student_account_model.dart';
import '../repository/student_account_repository.dart';

part 'student_account_provider.g.dart';

@riverpod
class StudentAccount extends _$StudentAccount {
  @override
  Future<StudentAccountModel> build() async {
    // Watch user changes so that logging in/out refreshes the account state
    final user = ref.watch(authProvider).user;
    final studentId = user?.id ?? 'student_123';
    return ref.read(studentAccountRepositoryProvider).fetchAccount(studentId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch());
  }

  /// Processes payment using scanned QR payload
  Future<void> payWithQr(String qrPayload) async {
    final user = ref.read(authProvider).user;
    final studentId = user?.id ?? 'student_123';

    // We get the new account state back upon success
    final newAccount = await ref
        .read(studentAccountRepositoryProvider)
        .processPayment(studentId: studentId, qrPayload: qrPayload);
    state = AsyncData(newAccount);
  }

  /// Updates spending limits (used by parent view)
  Future<void> updateLimit(double limit) async {
    final user = ref.read(authProvider).user;
    final studentId = user?.id ?? 'student_123';

    final newAccount = await ref
        .read(studentAccountRepositoryProvider)
        .updateSpendingLimit(studentId: studentId, limit: limit);
    state = AsyncData(newAccount);
  }

  Future<StudentAccountModel> _fetch() async {
    final user = ref.read(authProvider).user;
    final studentId = user?.id ?? 'student_123';
    return ref.read(studentAccountRepositoryProvider).fetchAccount(studentId);
  }
}
