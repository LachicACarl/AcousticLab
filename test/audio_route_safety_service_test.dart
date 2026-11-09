import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:iema/services/audio_route_safety_service.dart';

void main() {
  group('AudioRouteSafetyService', () {
    late FakeTimerFactory timers;
    late int pauseCalls;
    late AudioRouteSafetyService service;

    setUp(() {
      timers = FakeTimerFactory();
      pauseCalls = 0;
      service = AudioRouteSafetyService(
        gracePeriod: const Duration(milliseconds: 1800),
        timerFactory: timers.create,
        onUnsafeRoute: () async { pauseCalls++; },
      );
    });

    tearDown(() async => service.dispose());

    test('built-in speaker triggers immediate safety pause', () async {
      service.reportRoute(AudioOutputRoute.builtInSpeaker);
      await Future<void>.delayed(Duration.zero);
      expect(pauseCalls, 1);
      expect(timers.activeTimers, 0);
    });

    test('unknown route pauses only after grace period', () async {
      service.reportRoute(AudioOutputRoute.unknown);
      expect(pauseCalls, 0);
      timers.fireActive();
      await Future<void>.delayed(Duration.zero);
      expect(pauseCalls, 1);
    });

    test('Bluetooth route returning cancels pending grace timer', () async {
      service.reportRoute(AudioOutputRoute.unknown);
      service.reportRoute(AudioOutputRoute.bluetooth);
      timers.fireActive();
      await Future<void>.delayed(Duration.zero);
      expect(pauseCalls, 0);
    });

    test('BLE disconnect alone does not override confirmed Bluetooth route',
        () async {
      service.reportRoute(AudioOutputRoute.bluetooth);
      service.reportBleConnection(false);
      timers.fireActive();
      await Future<void>.delayed(Duration.zero);
      expect(pauseCalls, 0);
    });

    test('BLE disconnect reinforces an uncertain route', () async {
      service.reportBleConnection(false);
      service.reportRoute(AudioOutputRoute.unknown);
      timers.fireActive();
      await Future<void>.delayed(Duration.zero);
      expect(pauseCalls, 1);
    });

    test('intentional disconnect bypasses safety pause', () async {
      service.setIntentionalDisconnect(true);
      service.reportRoute(AudioOutputRoute.builtInSpeaker);
      timers.fireActive();
      await Future<void>.delayed(Duration.zero);
      expect(pauseCalls, 0);
    });

    test('does not trigger duplicate pauses for one route-loss episode',
        () async {
      service.reportRoute(AudioOutputRoute.builtInSpeaker);
      service.reportRoute(AudioOutputRoute.builtInSpeaker);
      await Future<void>.delayed(Duration.zero);
      expect(pauseCalls, 1);
    });
  });
}

class FakeTimerFactory {
  final List<FakeTimer> _timers = [];

  int get activeTimers => _timers.where((timer) => !timer.isCancelled).length;

  Timer create(Duration duration, void Function() callback) {
    final timer = FakeTimer(callback);
    _timers.add(timer);
    return timer;
  }

  void fireActive() {
    for (final timer in _timers.where((timer) => !timer.isCancelled).toList()) {
      timer.fire();
    }
  }
}

class FakeTimer implements Timer {
  FakeTimer(this._callback);

  final void Function() _callback;
  bool _cancelled = false;
  bool _fired = false;

  bool get isCancelled => _cancelled || _fired;

  void fire() {
    if (isCancelled) return;
    _fired = true;
    _callback();
  }

  @override
  void cancel() => _cancelled = true;

  @override
  bool get isActive => !isCancelled;

  @override
  int get tick => _fired ? 1 : 0;
}
