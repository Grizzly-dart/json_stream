import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:channel/channel.dart';

import 'streamer.dart';

import 'package:characters/characters.dart';

Future<dynamic> parseStream(Stream<String> input) {
  return _parse(input
      .map((event) => event.characters.toList())
      .expand((element) => element));
}

Future<dynamic> _parse(Stream<String> characters) {
  // TODO
}

Future<num> _parseNumber(Streamer<String> characters) async {
  final sb = <String>[];

  if (await characters.first == null) {
    throw FormatException('Unexpected end of JSON input');
  }

  if (await characters.first == '-') {
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

