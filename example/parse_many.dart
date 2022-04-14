import 'dart:convert';
import 'dart:io';

import 'package:json_stream/src/stream.dart';

Future<void> main() async {
  var file = File('data/ndjson/int.jsonl').openRead();
  print(await parseManyStream(file.transform(utf8.decoder)).toList());

  file = File('data/ndjson/string.jsonl').openRead();
  print(await parseManyStream(file.transform(utf8.decoder)).toList());
  // TODO
}