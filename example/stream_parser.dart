import 'dart:convert';
import 'dart:io';

import 'package:json_stream/src/stream.dart';

Future<void> main() async {
  var file = File('data/string.json').openRead();
  print(await parseStream(file.transform(utf8.decoder)));

  file = File('data/int.json').openRead();
  print(await parseStream(file.transform(utf8.decoder)));

  file = File('data/num.json').openRead();
  print(await parseStream(file.transform(utf8.decoder)));

  file = File('data/null.json').openRead();
  print(await parseStream(file.transform(utf8.decoder)));
  // TODO
}