import 'dart:async';
import 'dart:collection';

class SerialExecutor {
  SerialExecutor();
  final DoubleLinkedQueue<Completer<void>> _queue =
      DoubleLinkedQueue<Completer<void>>();

  bool get isLocked => _queue.isNotEmpty;

  int get tasks => _queue.length;

  Future<void> lock() async {
    final previousTask = _queue.lastOrNull?.future ?? Future<void>.value();

    _queue.add(Completer<void>.sync());

    return previousTask;
  }

  void unlock() {
    if (_queue.isEmpty) {
      assert(
        false,
        'SerialExecutor called unlock(), but executor is not locked',
      );
      return;
    }

    final completer = _queue.removeFirst();

    if (completer.isCompleted) {
      assert(
        false,
        'SerialExecutor called unlock(), but completer already completed',
      );
      return;
    }

    completer.complete();
  }

  Future<T> synchronized<T>(Future<T> Function() fn) async {
    await lock();

    try {
      return await fn();
    } finally {
      unlock();
    }
  }
}
