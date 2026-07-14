import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../storage/secure_storage_service.dart';
import '../storage/storage_provider.dart';

/// Abstracts biometric and device-credential authentication.
///
/// ## Design constraints
/// - No biometric logic lives in UI widgets; all calls go through this service.
/// - Any [PlatformException] (device not supported, not enrolled, locked out,
///   user cancelled) is treated as authentication failure rather than an error,
///   so callers receive a clean `bool` result.
/// - Falls back to device PIN / pattern / passcode when biometrics are
///   unavailable.
/// - User preference (enable/disable) is persisted in [SecureStorageService].
class BiometricAuthService {
  BiometricAuthService({
    required LocalAuthentication localAuth,
    required SecureStorageService storage,
  })  : _localAuth = localAuth,
        _storage = storage;

  final LocalAuthentication _localAuth;
  final SecureStorageService _storage;

  // ---------------------------------------------------------------------------
  // Device capability
  // ---------------------------------------------------------------------------

  /// Returns `true` if the device supports biometric or device-credential
  /// authentication (regardless of whether any credentials are enrolled).
  Future<bool> isAvailable() async {
    try {
      return await _localAuth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  /// Returns the list of enrolled biometric types (face, fingerprint, etc.).
  ///
  /// Returns an empty list if the device is not supported or no biometrics
  /// are enrolled.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return const [];
    }
  }

  // ---------------------------------------------------------------------------
  // Authentication
  // ---------------------------------------------------------------------------

  /// Presents the system authentication prompt.
  ///
  /// Supports Face ID, fingerprint, and any enrolled biometric, with automatic
  /// fallback to PIN / pattern / passcode.
  ///
  /// Returns `false` for all graceful failures (not available, not enrolled,
  /// locked out, user cancelled) instead of throwing.
  Future<bool> authenticate({
    String localizedReason = 'Authenticate to access HapoPay',
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          // Allow PIN/pattern/passcode fallback when biometrics are unavailable.
          biometricOnly: false,
        ),
      );
    } on PlatformException {
      // Covers: NotAvailable, NotEnrolled, PasscodeNotSet, LockedOut,
      // PermanentlyLockedOut, and user cancellation on all platforms.
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Preference persistence
  // ---------------------------------------------------------------------------

  /// Persists whether the user has opted into biometric unlock.
  Future<void> setEnabled(bool enabled) =>
      _storage.setBiometricEnabled(enabled);

  /// Returns `true` if the user has previously enabled biometric unlock.
  Future<bool> isEnabled() => _storage.isBiometricEnabled();
}

/// Application-scoped [BiometricAuthService] provider.
final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return BiometricAuthService(
    localAuth: LocalAuthentication(),
    storage: ref.watch(tokenStorageProvider),
  );
});
