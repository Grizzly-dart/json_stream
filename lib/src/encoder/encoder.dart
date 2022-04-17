import 'package:characters/characters.dart';

String? encode(dynamic v, {StringSink? sink}) {
  StringBuffer? sb;
  sink ??= sb = StringBuffer();
  _write(v, sink);
  return sb?.toString();
}

String? encodeMany(Iterable<dynamic> values,
    {StringSink? sink, String? prefix, String? suffix = '\n'}) {
  StringBuffer? sb;
  sink ??= sb = StringBuffer();
  for (final v in values) {
    if (prefix != null) {
      sink.write(prefix);
    }
    _write(v, sink);
    if (suffix != null) {
      sink.write(suffix);
    }
  }
  return sb?.toString();
}

Future<String?> encodeManyStream(Stream<dynamic> values,
    {StringSink? sink, String? prefix, String? suffix = '\n'}) async {
  StringBuffer? sb;
  sink ??= sb = StringBuffer();
  await for (final v in values) {
    if (prefix != null) {
      sink.write(prefix);
    }
    _write(v, sink);
    if (suffix != null) {
      sink.write(suffix);
    }
  }
  return sb?.toString();
}

void _write(dynamic v, StringSink sink) {
  if (v is num) {
    sink.write(v.toString());
  } else if (v == null) {
    sink.write('null');
  } else if (v is bool) {
    sink.write(v.toString());
  } else if (v is String) {
    _writeString(v, sink);
  } else if (v is Map<String, dynamic>) {
    _writeMap(v, sink);
  } else if (v is Iterable) {
    _writeList(v, sink);
  } else {
    throw UnsupportedError('invalid type ${v.runtimeType}');
  }
}

void _writeString(String v, StringSink sink) {
  sink.write('"');
  for (final c in v.characters) {
    if (c == r'\') {
      sink.write(r'\\');
    } else if (c == r'/') {
      sink.write(r'\/');
    } else if (c == r'"') {
      sink.write(r'\"');
    } else if (c == '\b') {
      sink.write(r'\b');
    } else if (c == '\f') {
      sink.write(r'\f');
    } else if (c == '\r') {
      sink.write(r'\r');
    } else if (c == '\n') {
      sink.write(r'\n');
    } else if (c == '\t') {
      sink.write(r'\t');
    } else {
      sink.write(c);
    }
  }
  sink.write('"');
}

void _writeMap(Map<String, dynamic> map, StringSink sink) {
  sink.write('{');

  final length = map.length;

  int i = 1;
  for (final entry in map.entries) {
    _writeString(entry.key, sink);
    sink.write(':');
    _write(entry.value, sink);
    if (i < length) {
      sink.write(',');
    }
    i++;
  }

  sink.write('}');
}

void _writeList(Iterable list, StringSink sink) {
  sink.write('[');

  final length = list.length;

  int i = 1;
  for (final entry in list) {
    _write(entry, sink);

    if (i < length) {
      sink.write(',');
    }
    i++;
  }

  sink.write(']');
}
