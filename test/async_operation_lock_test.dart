import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:iema/services/async_operation_lock.dart';

void main() {
  group('AsyncOperationLock', () {
    test('serializes rapid overlapping state transitions', () async {
      final lock = AsyncOperationLock();
      final firstGate = Completer<void>();
      final events = <String>[];

      final disconnect = lock.synchronized(() async {
        events.add('disconnect:start');
        await firstGate.future;
        events.add('disconnect:end');
      });

      final reconnect = lock.synchronized(() async {
        events.add('reconnect:start');
        events.add('reconnect:end');
      });

      final secondDisconnect = lock.synchronized(() async {
        events.add('second-disconnect:start');
        events.add('second-disconnect:end');
      });

      await Future<void>.delayed(Duration.zero);
      expect(events, ['disconnect:start']);

      firstGate.complete();
      await Future.wait([disconnect, reconnect, secondDisconnect]);

      expect(events, [
        'disconnect:start',
        'disconnect:end',
        'reconnect:start',
        'reconnect:end',
        'second-disconnect:start',
        'second-disconnect:end',
      ]);
    });

    test('a failed operation releases the queue for the next operation',
        () async {
      final lock = AsyncOperationLock();
      final events = <String>[];

      await expectLater(
        lock.synchronized<void>(() async {
          events.add('failed:start');
          throw StateError('simulated disconnect failure');
        }),
        throwsA(isA<StateError>()),
      );

      await lock.synchronized(() async {
        events.add('next:start');
      });

      expect(events, ['failed:start', 'next:start']);
    });
  });
}
