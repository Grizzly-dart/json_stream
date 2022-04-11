import 'dart:async';
import 'dart:collection';

class Streamer<T> {
  final Stream<T> _stream;

  final _queue = Queue<T>();

  var _finished = false;

  Completer<void>? _completer;

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

  Future<bool> get isEmpty async {
    if (_completer != null) {
      throw Exception('concurrent reads not allowed');
    }

    if (_queue.isNotEmpty) {
      return false;
    } else if (_finished) {
      return true;
    }
    final completer = Completer<T>();
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

  Future<T?> get first async {
    if (_completer != null) {
      throw Exception('concurrent reads not allowed');
    }

    if (_queue.isNotEmpty) {
      return _queue.first;
    } else if (_finished) {
      return null;
    }
    final completer = Completer<T>();
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

  Future<T?> get first async {
    if (_completer != null) {
      throw Exception('concurrent reads not allowed');
    }

    if (_queue.isNotEmpty) {
      return _queue.first;
    } else if (_finished) {
      return null;
    }
    final completer = Completer<T>();
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

    return _queue.removeFirst();
  }
}