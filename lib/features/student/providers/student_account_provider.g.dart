// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_account_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StudentAccount)
final studentAccountProvider = StudentAccountProvider._();

final class StudentAccountProvider
    extends $AsyncNotifierProvider<StudentAccount, StudentAccountModel> {
  StudentAccountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'studentAccountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$studentAccountHash();

  @$internal
  @override
  StudentAccount create() => StudentAccount();
}

String _$studentAccountHash() => r'30a42b06906183d125bb42421459a253aa9ab829';

abstract class _$StudentAccount extends $AsyncNotifier<StudentAccountModel> {
  FutureOr<StudentAccountModel> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<StudentAccountModel>, StudentAccountModel>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<StudentAccountModel>, StudentAccountModel>,
        AsyncValue<StudentAccountModel>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
