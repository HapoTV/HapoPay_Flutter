// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_account_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(studentAccountRepository)
final studentAccountRepositoryProvider = StudentAccountRepositoryProvider._();

final class StudentAccountRepositoryProvider extends $FunctionalProvider<
    StudentAccountRepository,
    StudentAccountRepository,
    StudentAccountRepository> with $Provider<StudentAccountRepository> {
  StudentAccountRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'studentAccountRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$studentAccountRepositoryHash();

  @$internal
  @override
  $ProviderElement<StudentAccountRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StudentAccountRepository create(Ref ref) {
    return studentAccountRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudentAccountRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudentAccountRepository>(value),
    );
  }
}

String _$studentAccountRepositoryHash() =>
    r'54363b58c5cd5e99301b920b7460d6b65231b4b5';
