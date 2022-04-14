import 'dart:async';
import 'package:characters/characters.dart';

void encodeJSON(dynamic v, StreamSink<String> sink) {
  if(v is num) {
    sink.add(v.toString());
  } else if(v == null) {
    sink.add('null');
  } else if(v is bool) {
    sink.add(v.toString());
  } else if(v is String) {
    // TODO
  } else if(v is Map<String, dynamic>) {
    // TODO
  } else if(v is List) {
    // TODO
  } else {
    throw UnsupportedError('invalid type ${v.runtimeType}');
  }
}

void _writeString(String v, StreamSink<String> sink) {
  sink.add('"');
  for(final c in v.characters) {
    if(c == r'\') {
        sink.add(r'\\');
    } else if(c == r'/') {
      sink.add(r'\/');
    } else if(c == r'"') {
      sink.add(r'\"');
    } else if(c == '\b') {
      sink.add(r'\b');
    } else if(c == '\f') {
      sink.add(r'\f');
    } else if(c == '\r') {
      sink.add(r'\r');
    } else if(c == '\n') {
      sink.add(r'\n');
    } else if(c == '\t') {
      sink.add(r'\t');
    } else {
      sink.add(c);
    }
  }
  sink.add('"');
}

void _writeMap(Map<String, dynamic> map, StreamSink<String> sink) {
  sink.add('{');

  for(final entry in map.entries) {
    _writeString(entry.key, sink);
    // TODO
  }

  sink.add('}');
}