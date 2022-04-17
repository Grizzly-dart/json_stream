import 'dart:convert';
import 'dart:io';

import 'package:json_stream/json_stream.dart';

Future<void> main() async {
  var file = File('data/json/string.json').openRead();
  print(await parseStream(file.transform(utf8.decoder)));

  file = File('data/json/int.json').openRead();
  print(await parseStream(file.transform(utf8.decoder)));

  file = File('data/json/num.json').openRead();
  print(await parseStream(file.transform(utf8.decoder)));

  file = File('data/json/null.json').openRead();
  print(await parseStream(file.transform(utf8.decoder)));
  // TODO
}
