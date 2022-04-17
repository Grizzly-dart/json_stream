import 'dart:async';
import 'dart:collection';

class Streamer<T> {
  final Stream<T> _stream;

  final _queue = Queue<T>();

  var _finished = false;

  Completer<void>? _completer;

  int _position = 0;

  Streamer(this._stream) {
    _stream.listen((event) {
      _queue.add(event);
      if (_completer != null) {
        _completer!.complete();
        _completer = null;
      }
    }, onDone: () {
      _finished = true;
      if (_completer != null) {
        _completer!.complete();
        _completer = null;
      }
    });
  }

  int get position => _position;

  Future<bool> get isEmpty async {
    if (_completer != null) {
      throw Exception('concurrent reads not allowed');
    }

    if (_queue.isNotEmpty) {
      return false;
    } else if (_finished) {
      return true;
    }
    final completer = Completer<void>();
    _completer = completer;
    await completer.future;
    if (_queue.isNotEmpty) {
      return false;
    } else if (_finished) {
      return true;
    } else {
      throw Exception('unexpected internal state');
    }
  }

  Future<bool> get isNotEmpty async => !await isEmpty;

  Future<T?> get waitFirst async {
    if (_completer != null) {
      throw Exception('concurrent reads not allowed');
    }

    if (_queue.isNotEmpty) {
      return _queue.first;
    } else if (_finished) {
      return null;
    }
    final completer = Completer<void>();
    _completer = completer;
    await completer.future;
    if (_queue.isNotEmpty) {
      return _queue.first;
    } else if (_finished) {
      return null;
    } else {
      throw Exception('unexpected internal state');
    }
  }

  T? get first {
    if (_completer != null) {
      throw Exception('concurrent reads not allowed');
    }

    if (_queue.isNotEmpty) {
      return _queue.first;
    } else if (_finished) {
      return null;
    }

    throw Exception('the buffer is empty');
  }

  T removeFirst() {
    if (_completer != null) {
      throw Exception('concurrent reads not allowed');
    }

    if (_queue.isEmpty) {
      if (!_finished) {
        throw Exception('the buffer is empty');
      } else {
        throw Exception('the channel is empty and closed');
      }
    }

    _position++;
    return _queue.removeFirst();
  }
}
