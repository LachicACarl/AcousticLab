import 'dart:async';

/// Best-effort output classification supplied by a platform route adapter.
///
/// [unknown] means the adapter cannot currently determine the output. The
/// service does not infer the active route from device availability alone.
enum AudioOutputRoute {
  bluetooth,
  builtInSpeaker,
  other,
  unknown,
}

typedef SafetyTimerFactory = Timer Function(
  Duration duration,
  void Function() callback,
);

/// Deterministic safety policy for unexpected loss of the expected Bluetooth
/// output. Platform code must report actual route observations explicitly.
class AudioRouteSafetyService {
  AudioRouteSafetyService({
    required this.onUnsafeRoute,
    this.gracePeriod = const Duration(milliseconds: 1800),
    SafetyTimerFactory? timerFactory,
  }) : _timerFactory = timerFactory ?? Timer.new {
    if (gracePeriod <= Duration.zero) {
      throw ArgumentError.value(gracePeriod, 'gracePeriod',
          'Must be greater than zero.');
    }
  }

  final Future<void> Function() onUnsafeRoute;
  final Duration gracePeriod;
  final SafetyTimerFactory _timerFactory;

  StreamSubscription<AudioOutputRoute>? _routeSubscription;
  StreamSubscription<bool>? _bleSubscription;
  Timer? _graceTimer;
  AudioOutputRoute _route = AudioOutputRoute.unknown;
  bool _intentionalDisconnect = false;
  bool _pauseTriggered = false;
  bool _disposed = false;

  AudioOutputRoute get latestRoute => _route;
  bool get isIntentionalDisconnect => _intentionalDisconnect;

  /// Attach injectable observations. Streams may be supplied by platform
  /// adapters and tests; this class itself does not claim to discover the
  /// active route from audio_session device-presence events.
  Future<void> listen({
    required Stream<AudioOutputRoute> routeChanges,
    Stream<bool>? bleConnectionChanges,
  }) async {
    if (_disposed) {
      throw StateError('AudioRouteSafetyService has been disposed.');
    }
    await _routeSubscription?.cancel();
    await _bleSubscription?.cancel();
    _routeSubscription = routeChanges.listen(reportRoute);
    if (bleConnectionChanges != null) {
      _bleSubscription = bleConnectionChanges.listen(reportBleConnection);
    }
  }

  void reportRoute(AudioOutputRoute route) {
    if (_disposed || _intentionalDisconnect) return;
    _route = route;

    if (route == AudioOutputRoute.bluetooth) {
      _cancelGracePeriod();
      _pauseTriggered = false;
      return;
    }

    if (route == AudioOutputRoute.builtInSpeaker) {
      _cancelGracePeriod();
      _triggerSafetyPause();
      return;
    }

    // Unknown or another output can be a transient handoff. BLE state is
    // supplementary: a GATT disconnect alone never overrides a confirmed
    // Bluetooth audio route.
    _startGracePeriod();
  }

  void reportBleConnection(bool connected) {
    if (_disposed || _intentionalDisconnect) return;
    if (connected) {
      if (_route == AudioOutputRoute.bluetooth) {
        _cancelGracePeriod();
        _pauseTriggered = false;
      }
      return;
    }

    // GATT and A2DP are separate transports. Only use BLE loss to reinforce
    // an already uncertain/non-Bluetooth route, never as sole proof of loss.
    if (_route != AudioOutputRoute.bluetooth) {
      _startGracePeriod();
    }
  }

  /// Call before an app-initiated disconnect so it is not treated as a fault.
  void setIntentionalDisconnect(bool intentional) {
    _intentionalDisconnect = intentional;
    if (intentional) {
      _cancelGracePeriod();
    } else if (_route != AudioOutputRoute.bluetooth) {
      _startGracePeriod();
    }
  }

  void _startGracePeriod() {
    if (_disposed || _intentionalDisconnect || _pauseTriggered) return;
    _graceTimer ??= _timerFactory(gracePeriod, () {
      _graceTimer = null;
      if (_disposed ||
          _intentionalDisconnect ||
          _route == AudioOutputRoute.bluetooth) {
        return;
      }
      _triggerSafetyPause();
    });
  }

  void _cancelGracePeriod() {
    _graceTimer?.cancel();
    _graceTimer = null;
  }

  void _triggerSafetyPause() {
    if (_disposed || _intentionalDisconnect || _pauseTriggered) return;
    _pauseTriggered = true;
    unawaited(onUnsafeRoute());
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _cancelGracePeriod();
    await _routeSubscription?.cancel();
    await _bleSubscription?.cancel();
    _routeSubscription = null;
    _bleSubscription = null;
  }
}
