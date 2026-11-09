import 'dart:async';

/// Serializes asynchronous operations that mutate one shared resource.
///
/// Each caller waits for the previous operation to finish. A failed operation
/// does not poison the queue, and the next operation is still allowed to run.
class AsyncOperationLock {
  Future<void> _tail = Future<void>.value();

  Future<T> synchronized<T>(Future<T> Function() operation) async {
    final previous = _tail;
    final release = Completer<void>();
    _tail = release.future;

    await previous;
    try {
      return await operation();
    } finally {
      release.complete();
    }
  }
}
