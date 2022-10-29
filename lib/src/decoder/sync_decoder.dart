import 'dart:collection';

import 'package:characters/characters.dart';
import 'package:json_stream/json_stream.dart';
import 'package:json_stream/src/decoder/queue_reader.dart';
import 'package:json_stream/src/utils/utils.dart';

dynamic decode(String input) {
  final characters = SyncReader<String>(Queue.from(input.characters));
  final ret = _parseValue(characters);
  _skipWhiteSpace(characters);

  if (characters.isNotEmpty) {
    throw SyntaxException('unexpected input', characters.position);
  }

  return ret;
}

Iterable<dynamic> parseMany(String input) sync* {
  final characters = SyncReader<String>(Queue.from(input.characters));

  while (characters.isNotEmpty) {
    yield _parseValue(characters);
    _skipWhiteSpace(characters);
  }
}

dynamic _parseValue(SyncReader<String> characters) {
  _skipWhiteSpace(characters);

  if (characters.isEmpty) {
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

void _skipWhiteSpace(SyncReader<String> characters) {
  while (characters.isNotEmpty) {
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

Map<String, dynamic> _parseMap(SyncReader<String> characters) {
  if (characters.isEmpty) {
    throw FormatException('Unexpected end of JSON input');
  }

  if (characters.first != "{") {
    throw Exception(
        "StateError@${characters.position}: expected '{' found '${characters.first}'");
  } else {
    characters.removeFirst();
  }

  final entries = <MapEntry<String, dynamic>>[];

  loop:
  while (characters.isNotEmpty) {
    _skipWhiteSpace(characters);
    switch (characters.first) {
      case "}":
        break loop;
      case '"':
        entries.add(_parseMapRow(characters));
        break;
      default:
        throw SyntaxException(
            "unexpected character ${characters.first} expected '}' or '\"'",
            characters.position);
    }
  }

  if (characters.isEmpty) {
    throw FormatException('Unexpected end of JSON input');
  } else {
    characters.removeFirst(); // Consume '}'
  }

  return Map.fromEntries(entries);
}

MapEntry<String, dynamic> _parseMapRow(SyncReader<String> characters) {
  if (characters.isEmpty) {
    throw FormatException('Unexpected end of JSON input');
  }

  if (characters.first != '"') {
    throw Exception(
        "StateError@${characters.position}: expected '\"' found ${characters.first}");
  }

  final key = _parseString(characters);
  _skipWhiteSpace(characters);

  if (characters.isEmpty) {
    throw FormatException('Unexpected end of JSON input');
  } else if (characters.first != ":") {
    throw SyntaxException(
        "unexpected character ${characters.first} expected ':'",
        characters.position);
  } else {
    characters.removeFirst();
  }

  _skipWhiteSpace(characters);
  final value = _parseValue(characters);
  _skipWhiteSpace(characters);

  // Remove the trailing ','
  if (characters.isNotEmpty && characters.first == ",") {
    characters.removeFirst();
  }

  return MapEntry(key, value);
}

List<dynamic> _parseList(SyncReader<String> characters) {
  if (characters.isEmpty) {
    throw FormatException('Unexpected end of JSON input');
  }

  if (characters.first != '[') {
    throw SyntaxException(
        "expected '[' but found ${characters.first}", characters.position);
  } else {
    characters.removeFirst();
  }

  final ret = [];

  while (characters.isNotEmpty) {
    _skipWhiteSpace(characters);

    if (characters.first == ']') {
      break;
    }
    ret.add(_parseValue(characters));

    _skipWhiteSpace(characters);

    if (characters.isNotEmpty && characters.first == ",") {
      characters.removeFirst();
    }
  }

  if (characters.isEmpty) {
    throw FormatException('Unexpected end of JSON input');
  } else {
    characters.removeFirst(); // Consume ']'
  }

  return ret;
}

num _parseNumber(SyncReader<String> characters) {
  final sb = <String>[];

  loop:
  while (characters.isNotEmpty) {
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
    if (characters.isEmpty) {
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

bool _parseTrue(SyncReader<String> characters) {
  _matchString(characters, ["t", "r", "u", "e"]);
  return true;
}

bool _parseFalse(SyncReader<String> characters) {
  _matchString(characters, ["f", "a", "l", "s", "e"]);
  return false;
}

dynamic _parseNull(SyncReader<String> characters) {
  _matchString(characters, ["n", "u", "l", "l"]);
  return null;
}

void _matchString(SyncReader<String> characters, List<String> match) {
  int i = 0;
  for (final c in match) {
    if (characters.isEmpty) {
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

String _parseString(SyncReader<String> characters) {
  if (characters.isEmpty) {
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
  while (characters.isNotEmpty) {
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
          sb.write(_unescape(characters));
          isEscaping = false;
        } else {
          sb.write(characters.removeFirst());
        }
    }
  }

  if (characters.isEmpty) {
    throw FormatException('Unexpected end of JSON input');
  } else {
    characters.removeFirst(); // Consume '"'
  }

  return sb.toString();
}

String _unescape(SyncReader<String> characters) {
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
        if (characters.isEmpty) {
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
