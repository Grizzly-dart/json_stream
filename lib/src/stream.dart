import 'dart:async';

import 'streamer.dart';

import 'package:characters/characters.dart';

Future<dynamic> parseStream(Stream<String> input) {
  return _parse(Streamer(input
      .map((event) => event.characters.toList())
      .expand((element) => element)));
}

Future<dynamic> _parse(Streamer<String> characters) async {
  await _skipWhiteSpace(characters);

  if (await characters.isEmpty) {
    throw FormatException();
  }
  final c = characters.first!;

  switch (c) {
    case "{":
      return _parseMap(characters);
    case "[":
      return _parseList(characters);
    case '"':
      return _parseString(characters);
    case "-":
    case ".":
      return _parseNumber(characters);
    case "t":
      return _parseTrue(characters);
    case "f":
      return _parseFalse(characters);
    case "n":
      return _parseNull(characters);
    default:
      if (c.codeUnits.length == 1) {
        final code = c.codeUnitAt(0);
        if (code >= 48 && code <= 57) {
          return _parseNumber(characters);
        }
      }

      throw FormatException('');
  }
}

Future<void> _skipWhiteSpace(Streamer<String> characters) async {
  while (await characters.isNotEmpty) {
    switch (characters.first) {
      case " ":
      case "\n":
      case "\r":
      case "\t":
        characters.removeFirst();
        break;
      default:
        return;
    }
  }
}

Future<Map<String, dynamic>> _parseMap(Streamer<String> characters) async {
  if (await characters.isEmpty) {
    throw FormatException();
  }

  if (characters.removeFirst() != "{") {
    throw Exception('state error');
  }

  final entries = <MapEntry<String, dynamic>>[];

  loop:
  while (await characters.isNotEmpty) {
    await _skipWhiteSpace(characters);
    switch (characters.first) {
      case "}":
        break loop;
      case '"':
        entries.add(await _parseMapRow(characters));
        break;
      default:
        throw FormatException();
    }
  }

  if (await characters.isEmpty) {
    throw FormatException('SyntaxError: Unexpected end of JSON input');
  } else {
    characters.removeFirst(); // Consume '}'
  }

  return Map.fromEntries(entries);
}

Future<MapEntry<String, dynamic>> _parseMapRow(
    Streamer<String> characters) async {
  if (await characters.isEmpty) {
    throw FormatException();
  }

  if (characters.first != '"') {
    throw Exception('state error');
  }

  final key = await _parseString(characters);
  await _skipWhiteSpace(characters);

  if (await characters.isEmpty) {
    throw FormatException();
  } else if (characters.first != ":") {
    throw FormatException();
  } else {
    characters.removeFirst();
  }

  await _skipWhiteSpace(characters);
  final value = await _parse(characters);
  await _skipWhiteSpace(characters);

  // Remove the trailing ','
  if (await characters.isNotEmpty && characters.first == ",") {
    characters.removeFirst();
  }

  return MapEntry(key, value);
}

Future<List<dynamic>> _parseList(Streamer<String> characters) async {
  if (await characters.isEmpty) {
    throw FormatException('SyntaxError: Unexpected end of JSON input');
  }

  if (characters.first != '[') {
    throw FormatException("expected '[' but found ${characters.first}");
  } else {
    characters.removeFirst();
  }

  final ret = [];

  while (await characters.isNotEmpty) {
    await _skipWhiteSpace(characters);

    if (characters.first == ']') {
      break;
    }
    ret.add(await _parse(characters));

    await _skipWhiteSpace(characters);

    if (await characters.isNotEmpty && characters.first == ",") {
      characters.removeFirst();
    }
  }

  if (await characters.isEmpty) {
    throw FormatException('SyntaxError: Unexpected end of JSON input');
  } else {
    characters.removeFirst(); // Consume ']'
  }

  return ret;
}

Future<num> _parseNumber(Streamer<String> characters) async {
  final sb = <String>[];

  while (await characters.isNotEmpty) {
    final String c = characters.first!;
    if (c.codeUnits.length != 1) {
      throw FormatException();
    }
    final code = c.codeUnitAt(0);
    if (code >= 48 && code <= 57) {
      // Digits
      sb.add(characters.removeFirst());
    } else if (code == 101 || code == 69) {
      // e or E
      sb.add(characters.removeFirst());
    } else if (code == 46) {
      // .
      sb.add(characters.removeFirst());
    } else if (code == 45) {
      // -
      sb.add(characters.removeFirst());
    } else {
      break;
    }
  }

  if (sb.isEmpty) {
    if (await characters.isEmpty) {
      throw FormatException('Unexpected end of JSON input');
    } else {
      throw FormatException('invalid');
    }
  }

  return num.parse(sb.join());
}

Future<bool> _parseTrue(Streamer<String> characters) async {
  await _matchString(characters, ["t", "r", "u", "e"]);
  return true;
}

Future<bool> _parseFalse(Streamer<String> characters) async {
  await _matchString(characters, ["f", "a", "l", "s", "e"]);
  return false;
}

Future<dynamic> _parseNull(Streamer<String> characters) async {
  await _matchString(characters, ["n", "u", "l", "l"]);
  return null;
}

Future<void> _matchString(
    Streamer<String> characters, List<String> match) async {
  for (final c in match) {
    if (await characters.isEmpty) {
      throw FormatException('SyntaxError: Unexpected end of JSON input');
    }

    if (characters.first != c) {
      throw FormatException();
    }

    characters.removeFirst();
  }
}

Future<String> _parseString(Streamer<String> characters) async {
  if (await characters.waitFirst == null) {
    throw FormatException('Unexpected end of JSON input');
  }

  if (characters.first != '"') {
    throw Exception('state error');
  } else {
    characters.removeFirst();
  }

  final sb = StringBuffer();

  bool isEscaping = false;
  loop:
  while (await characters.isNotEmpty) {
    switch (characters.first) {
      case '\\':
        characters.removeFirst();
        if (!isEscaping) {
          isEscaping = true;
        } else {
          isEscaping = false;
          sb.write('\\');
        }
        break;
      case '"':
        if (isEscaping) {
          sb.write('"');
          isEscaping = false;
          characters.removeFirst();
        } else {
          break loop;
          // TODO
        }
        break;
      default:
        if (isEscaping) {
          sb.write(_unescape(characters.removeFirst()));
          isEscaping = false;
        } else {
          sb.write(characters.removeFirst());
        }
    }
  }

  if (await characters.isEmpty) {
    throw FormatException('SyntaxError: Unexpected end of JSON input');
  } else {
    characters.removeFirst(); // Consume '"'
  }

  return sb.toString();
}

String _unescape(String char) {
  switch (char) {
    case '\\':
      return '\\';
    case 'n':
      return '\n';
    case 'r':
      return '\r';
    case '"':
      return '"';
    case "/":
      return '/';
    case "b":
      return '\b';
    case "f":
      return '\f';
    case "t":
      return '\t';
    case "u":
      // TODO
      throw UnimplementedError();
    default:
      throw FormatException();
  }
}
