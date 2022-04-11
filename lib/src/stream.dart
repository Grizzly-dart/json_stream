import 'dart:collection';
import 'dart:convert';

import 'package:characters/characters.dart';

Future<dynamic> parseStream(Stream<String> input) {
  return _parse(input
      .map((event) => event.characters.toList())
      .expand((element) => element));
}

Future<dynamic> _parse(Stream<String> characters) {
  // TODO
}

class CharacterStreamer {
  final Stream<String> _stream;

  CharacterStreamer(this._stream);

  Future<void> next() {
    // TODO
  }
}

Future<num> _parseNumber(Queue<String> characters) async {
  final sb = <String>[];

  if (characters.isEmpty) {
    throw FormatException();
  }

  if (characters.first == '-') {
    sb.add(characters.first);
    characters.removeFirst();
  }

  while (characters.isNotEmpty) {
    final String c = characters.first;
    if (c.codeUnits.length != 1) {
      throw FormatException();
    }
    final code = c.codeUnitAt(0);
    if (code >= 48 && code <= 57) {
      // Digits
      sb.add(characters.removeFirst());
    } else if (code == 101 || code == 69) {
      // e or R
      sb.add(characters.removeFirst());
    } else if (code == 46) {
      // .
      sb.add(characters.removeFirst());
    } else {
      break;
    }
  }

  return num.parse(sb.join());
}