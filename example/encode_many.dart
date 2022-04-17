import 'dart:async';
import 'dart:io';

import 'package:json_stream/json_stream.dart';

Future<void> main() async {
  print(encodeMany([
    "hello",
    5,
    5.56,
    null,
    ["hello", 5, null, 0.5],
    {"key1": "value1", "key2": 5, "key3": null}
  ]));
}
