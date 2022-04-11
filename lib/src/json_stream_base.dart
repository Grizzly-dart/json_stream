import 'dart:collection';

import 'package:characters/characters.dart';

dynamic parse(String input) {
  if (input.isEmpty) {
    throw FormatException(
        'SyntaxError: Unexpected end of JSON input', input, 0);
  }

  final characters = Queue.of(Characters(input));
  return _parse(characters);
}

dynamic _parse(Queue<String> characters) {
  _skipWhiteSpace(characters);
  switch (characters.first) {
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
      final String c = characters.first;
      if (c.codeUnits.length != 1) {
        throw FormatException();
      }
      final code = c.codeUnitAt(0);
      if (code >= 48 && code <= 57) {
        return _parseNumber(characters);
      }
      throw FormatException();
  }
}

Map<String, dynamic> _parseMap(Queue<String> characters) {
  if (characters.removeFirst() != "{") {
    throw Exception('state error');
  }

  final entries = <MapEntry<String, dynamic>>[];

  loop:
  while (true) {
    _skipWhiteSpace(characters);
    switch (characters.first) {
      case "}":
        characters.removeFirst();
        break loop;
      case '"':
        entries.add(_parseMapRow(characters));
        break;
      default:
        throw FormatException();
    }
  }

  return Map.fromEntries(entries);
}

MapEntry<String, dynamic> _parseMapRow(Queue<String> characters) {
  if (characters.first != '"') {
    throw Exception('state error');
  }

  final key = _parseString(characters);
  _skipWhiteSpace(characters);

  if (characters.isEmpty) {
    throw FormatException();
  }
  if (characters.removeFirst() != ":") {
    throw FormatException();
  }
  _skipWhiteSpace(characters);
  final value = _parse(characters);
  _skipWhiteSpace(characters);
  if (characters.first == ",") {
    characters.removeFirst();
  }

  return MapEntry(key, value);
}

String _parseString(Queue<String> characters) {
  if (characters.first != '"') {
    throw Exception('state error');
  } else {
    characters.removeFirst();
  }

  final sb = StringBuffer();

  bool isEscaping = false;
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
        characters.removeFirst();
        if (!isEscaping) {
          return sb.toString();
        } else {
          sb.write('"');
          isEscaping = false;
        }
        break;
      default:
        if(isEscaping) {
          sb.write(_unescape(characters.removeFirst()));
          isEscaping = false;
        } else {
          sb.write(characters.removeFirst());
        }
    }
  }

  throw FormatException();
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

void _skipWhiteSpace(Queue<String> characters) {
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

num _parseNumber(Queue<String> characters) {
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

List<dynamic> _parseList(Queue<String> characters) {
  if (characters.first != '[') {
    throw FormatException("expected '[' but found ${characters.first}");
  } else {
    characters.removeFirst();
  }

  final ret = [];

  while (characters.isNotEmpty) {
    if (characters.first == ']') {
      break;
    }
    ret.add(_parse(characters));

    if (characters.isNotEmpty && characters.first == ",") {
      characters.removeFirst();
    }
  }

  if (characters.isEmpty) {
    throw FormatException('SyntaxError: Unexpected end of JSON input');
  } else {
    characters.removeFirst();
  }

  return ret;
}

bool _parseTrue(Queue<String> characters) {
  _matchString(characters, ["t", "r", "u", "e"]);
  return true;
}

bool _parseFalse(Queue<String> characters) {
  _matchString(characters, ["f", "a", "l", "s", "e"]);
  return false;
}

dynamic _parseNull(Queue<String> characters) {
  _matchString(characters, ["n", "u", "l", "l"]);
  return null;
}

void _matchString(Queue<String> characters, List<String> match) {
  for (final c in match) {
    if (characters.isEmpty) {
      throw FormatException('SyntaxError: Unexpected end of JSON input');
    }

    if (characters.first != c) {
      throw FormatException();
    }

    characters.removeFirst();
  }
}
