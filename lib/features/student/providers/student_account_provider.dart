import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/student_account_model.dart';

part 'student_account_provider.g.dart';

@riverpod
class StudentAccount extends _$StudentAccount {
  @override
  Future<StudentAccountModel> build() async {
    // -------------------------------------------------------------------------
    // API Call (Commented out for UI testing)
    // -------------------------------------------------------------------------
    // final user = ref.watch(authProvider).user;
    // final studentId = user?.id ?? 'student_123';
    // return ref.read(studentAccountRepositoryProvider).fetchAccount(studentId);

    return const StudentAccountModel(
      studentId: 'student_123',
      balance: 124.50,
      dailyLimit: 200.0,
      todaySpent: 75.50,
      transactions: [],
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    // state = await AsyncValue.guard(() => _fetch());
    state = const AsyncData(
      StudentAccountModel(
        studentId: 'student_123',
        balance: 124.50,
        dailyLimit: 200.0,
        todaySpent: 75.50,
        transactions: [],
      ),
    );
  }

  /// Processes payment using scanned QR payload
  Future<void> payWithQr(String qrPayload) async {
    // -------------------------------------------------------------------------
    // API Call (Commented out for UI testing)
    // -------------------------------------------------------------------------
    // final user = ref.read(authProvider).user;
    // final studentId = user?.id ?? 'student_123';
    // final newAccount = await ref
    //     .read(studentAccountRepositoryProvider)
    //     .processPayment(studentId: studentId, qrPayload: qrPayload);
    // state = AsyncData(newAccount);

    final current =
        state.asData?.value ??
        const StudentAccountModel(
          studentId: 'student_123',
          balance: 124.50,
          dailyLimit: 200.0,
          todaySpent: 75.50,
          transactions: [],
        );
    state = AsyncData(
      StudentAccountModel(
        studentId: current.studentId,
        balance: (current.balance - 10.0).clamp(0.0, double.infinity),
        dailyLimit: current.dailyLimit,
        todaySpent: current.todaySpent + 10.0,
        transactions: current.transactions,
      ),
    );
  }

  /// Updates spending limits (used by parent view)
  Future<void> updateLimit(double limit) async {
    // -------------------------------------------------------------------------
    // API Call (Commented out for UI testing)
    // -------------------------------------------------------------------------
    // final user = ref.read(authProvider).user;
    // final studentId = user?.id ?? 'student_123';
    // final newAccount = await ref
    //     .read(studentAccountRepositoryProvider)
    //     .updateSpendingLimit(studentId: studentId, limit: limit);
    // state = AsyncData(newAccount);

    final current =
        state.asData?.value ??
        const StudentAccountModel(
          studentId: 'student_123',
          balance: 124.50,
          dailyLimit: 200.0,
          todaySpent: 75.50,
          transactions: [],
        );
    state = AsyncData(
      StudentAccountModel(
        studentId: current.studentId,
        balance: current.balance,
        dailyLimit: limit,
        todaySpent: current.todaySpent,
        transactions: current.transactions,
      ),
    );
  }
}
