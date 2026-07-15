import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Events published by the network layer to signal auth-lifecycle changes.
enum AuthEvent {
  /// Emitted when token refresh fails; all consumers should clear their session.
  forceLogout,
}

/// A lightweight broadcast event bus scoped to authentication events.
///
/// Bridges the network layer ([AuthInterceptor]) — which must not import the
/// auth feature — with the auth state machine ([AuthNotifier]).
///
/// [AuthNotifier] subscribes to [events] in its `build()` method and reacts
/// to [AuthEvent.forceLogout] by transitioning to the unauthenticated state.
class AuthEventBus {
  AuthEventBus() : _controller = StreamController<AuthEvent>.broadcast();

  final StreamController<AuthEvent> _controller;

  /// The broadcast stream of [AuthEvent]s.
  Stream<AuthEvent> get events => _controller.stream;

  /// Publishes [event] to all active subscribers.
  void dispatch(AuthEvent event) {
    if (!_controller.isClosed) _controller.add(event);
  }

  void dispose() => _controller.close();
}

/// Application-scoped [AuthEventBus] provider.
///
/// Kept alive (non-auto-dispose) so the bus outlives any individual screen
/// and is reliably accessible by both the network layer and [AuthNotifier].
final authEventBusProvider = Provider<AuthEventBus>((ref) {
  final bus = AuthEventBus();
  ref.onDispose(bus.dispose);
  return bus;
});
