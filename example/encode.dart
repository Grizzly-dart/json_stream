import 'dart:async';

import 'package:json_stream/json_stream.dart';

Future<void> main() async {
  print(encode("hello"));
  print(encode(5));
  print(encode(5.56));
  print(encode(null));
  print(encode(["hello", 5, null, 0.5]));
  print(encode({"key1": "value1", "key2": 5, "key3": null}));
}
