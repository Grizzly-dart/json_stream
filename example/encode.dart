import 'dart:async';
import 'dart:io';

import 'package:json_stream/json_stream.dart';

Future<void> main() async {
  print(encodeJSON("hello"));
  print(encodeJSON(5));
  print(encodeJSON(5.56));
  print(encodeJSON(null));
  print(encodeJSON(["hello", 5, null, 0.5]));
  print(encodeJSON({"key1": "value1", "key2": 5, "key3": null}));
}
