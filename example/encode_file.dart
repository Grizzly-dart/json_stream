import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:json_stream/json_stream.dart';

Future<void> main() async {
  final sink = File('/tmp/example.json').openWrite();
  encodeJSON({"key1": "value1", "key2": 5, "key3": null}, sink: sink);
  await sink.flush();
}
