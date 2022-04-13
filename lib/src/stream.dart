import 'dart:async';

import 'streamer.dart';

import 'package:characters/characters.dart';

Future<dynamic> parseStream(Stream<String> input) {
  return _parse(Streamer(input
      .map((event) => event.characters.toList())
      .expand((element) => element)));
}

Future<dynamic> _parse(Streamer<String> characters) async {
  final ret = await _parseOne(characters);

  await _skipWhiteSpace(characters);

  if (await characters.isNotEmpty) {
    throw SyntaxException('unexpected input', characters.position);
  }

  return ret;
}

Future<dynamic> _parseOne(Streamer<String> characters) async {
  await _skipWhiteSpace(characters);

  if (await characters.isEmpty) {
    throw FormatException('Unexpected end of JSON input');
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

      throw SyntaxException("unexpected character '$c'", characters.position);
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
    throw FormatException('Unexpected end of JSON input');
  }

  if (characters.first != "{") {
    throw Exception("state error. expected '{' found '${characters.first}'");
  } else {
    characters.removeFirst();
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
        throw SyntaxException(
            "unexpected character ${characters.first} expected '}' or '\"'",
            characters.position);
    }
  }

  if (await characters.isEmpty) {
    throw FormatException('Unexpected end of JSON input');
  } else {
    characters.removeFirst(); // Consume '}'
  }

  return Map.fromEntries(entries);
}

Future<MapEntry<String, dynamic>> _parseMapRow(
    Streamer<String> characters) async {
  if (await characters.isEmpty) {
    throw FormatException('Unexpected end of JSON input');
  }

  if (characters.first != '"') {
    throw Exception("state error. expected '\"' found ${characters.first}");
  }

  final key = await _parseString(characters);
  await _skipWhiteSpace(characters);

  if (await characters.isEmpty) {
    throw FormatException('Unexpected end of JSON input');
  } else if (characters.first != ":") {
    throw SyntaxException(
        "unexpected character ${characters.first} expected ':'",
        characters.position);
  } else {
    characters.removeFirst();
  }

  await _skipWhiteSpace(characters);
  final value = await _parseOne(characters);
  await _skipWhiteSpace(characters);

  // Remove the trailing ','
  if (await characters.isNotEmpty && characters.first == ",") {
    characters.removeFirst();
  }

  return MapEntry(key, value);
}

Future<List<dynamic>> _parseList(Streamer<String> characters) async {
  if (await characters.isEmpty) {
    throw FormatException('Unexpected end of JSON input');
  }

  if (characters.first != '[') {
    throw SyntaxException(
        "expected '[' but found ${characters.first}", characters.position);
  } else {
    characters.removeFirst();
  }

  final ret = [];

  while (await characters.isNotEmpty) {
    await _skipWhiteSpace(characters);

    if (characters.first == ']') {
      break;
    }
    ret.add(await _parseOne(characters));

    await _skipWhiteSpace(characters);

    if (await characters.isNotEmpty && characters.first == ",") {
      characters.removeFirst();
    }
  }

  if (await characters.isEmpty) {
    throw FormatException('Unexpected end of JSON input');
  } else {
    characters.removeFirst(); // Consume ']'
  }

  return ret;
}

Future<num> _parseNumber(Streamer<String> characters) async {
  final sb = <String>[];

  loop:
  while (await characters.isNotEmpty) {
    final String c = characters.first!;

    switch (c) {
      case ",":
      case "]":
      case "}":
      case " ":
      case "\t":
      case "\r":
      case "\n":
        break loop;
      default:
        sb.add(characters.removeFirst());
    }
  }

  if (sb.isEmpty) {
    if (await characters.isEmpty) {
      throw FormatException('Unexpected end of JSON input');
    } else {
      throw Exception('state error');
    }
  }

  try {
    return num.parse(sb.join());
  } catch (e) {
    throw SyntaxException('invalid number. found ${sb.toString()}',
        characters.position - sb.length);
  }
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
  int i = 0;
  for (final c in match) {
    if (await characters.isEmpty) {
      throw FormatException('Unexpected end of JSON input');
    }

    if (characters.first != c) {
      throw SyntaxException(
          "expected '${match.join()}'but found '${match.sublist(0, i)}${characters.first}'",
          characters.position);
    }

    i++;
    characters.removeFirst();
  }
}

Future<String> _parseString(Streamer<String> characters) async {
  if (await characters.isEmpty) {
    throw FormatException('Unexpected end of JSON input');
  }

  if (characters.first != '"') {
    throw Exception("state error. expected '\"' but found ${characters.first}");
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
        }
        break;
      default:
        if (isEscaping) {
          sb.write(await _unescape(characters));
          isEscaping = false;
        } else {
          sb.write(characters.removeFirst());
        }
    }
  }

  if (await characters.isEmpty) {
    throw FormatException('Unexpected end of JSON input');
  } else {
    characters.removeFirst(); // Consume '"'
  }

  return sb.toString();
}

Future<String> _unescape(Streamer<String> characters) async {
  switch (characters.first) {
    case '\\':
      characters.removeFirst();
      return '\\';
    case 'n':
      characters.removeFirst();
      return '\n';
    case 'r':
      characters.removeFirst();
      return '\r';
    case '"':
      characters.removeFirst();
      return '"';
    case "/":
      characters.removeFirst();
      return '/';
    case "b":
      characters.removeFirst();
      return '\b';
    case "f":
      characters.removeFirst();
      return '\f';
    case "t":
      characters.removeFirst();
      return '\t';
    case "u":
      final sb = StringBuffer();
      characters.removeFirst();
      for (int i = 0; i < 4; i++) {
        if (await characters.isEmpty) {
          throw FormatException('Unexpected end of JSON input');
        }
        final c = characters.first!;
        if (!c.isHex) {
          throw SyntaxException(
              "expected a hex digit but found ${characters.first}",
              characters.position);
        }

        characters.removeFirst();
        sb.write(c);
      }
      return String.fromCharCode(int.parse(sb.toString(), radix: 16));
    default:
      throw SyntaxException(
          "invalid string escape found '\\${characters.first}'",
          characters.position);
  }
}

extension on String {
  bool get isHex {
    if (codeUnits.length != 1) {
      return false;
    }
    final code = codeUnitAt(0);
    if (code >= 48 && code <= 57) {
      return true;
    } else if (code >= 97 && code <= 102) {
      return true;
    } else if (code >= 65 && code <= 70) {
      return true;
    }
    return false;
  }
}

class SyntaxException implements Exception {
  final int offset;

  final String message;

  SyntaxException(this.message, this.offset);

  @override
  String toString() => 'Syntax error at $offset: $message';
}
