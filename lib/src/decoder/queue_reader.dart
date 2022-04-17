import 'dart:collection';

class SyncReader<T> {
  final Queue<T> _queue;

  int _position = 0;

  SyncReader(this._queue);

  int get position => _position;

  bool get isEmpty => _queue.isEmpty;

  bool get isNotEmpty => _queue.isNotEmpty;

  T? get first {
    if (_queue.isEmpty) {
      return null;
    }
    return _queue.first;
  }

  T removeFirst() {
    final ret = _queue.removeFirst();
    _position++;
    return ret;
  }
}
