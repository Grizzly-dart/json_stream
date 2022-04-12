import 'dart:convert';
import 'dart:io';

import 'package:json_stream/json_stream.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('parse_stream.positive', () {
    test('string.basic', () async {
      var file = File('data/string.json').openRead();
      final v = await parseStream(file.transform(utf8.decoder));
      expect(v, 'hello');
    });
    test('string.escaped', () async {
      var file = File('data/string_escaped.json').openRead();
      final v = await parseStream(file.transform(utf8.decoder));
      expect(v, [
        "\\",
        "\n",
        "a\rb",
        "\"",
        "\"who",
        "who\"",
        "who\"is\"it",
        "who\"\"is\"\"\"it",
        "/",
        "\b",
        "\f",
        "\t"
      ]);
    });
    test('int.basic', () async {
      var file = File('data/int.json').openRead();
      final v = await parseStream(file.transform(utf8.decoder));
      expect(v, 5);
      expect(v, isA<int>());
    });
    test('num.basic', () async {
      var file = File('data/num.json').openRead();
      final v = await parseStream(file.transform(utf8.decoder));
      expect(v, 0.005);
    });
    test('null.basic', () async {
      var file = File('data/null.json').openRead();
      final v = await parseStream(file.transform(utf8.decoder));
      expect(v, null);
    });
    test('list.basic', () async {
      var file = File('data/list.json').openRead();
      final v = await parseStream(file.transform(utf8.decoder));
      expect(v, [
        145,
        "a",
        true,
        -0.5,
        ["nested", "list"]
      ]);
    });
    test('map.basic', () async {
      var file = File('data/map.json').openRead();
      final v = await parseStream(file.transform(utf8.decoder));
      expect(v, {
        "int": 5,
        "num": -0.5,
        "string": "hello",
        "bool": true,
        "list": [1, 2, 3, 4, 5],
        "map": {"key1": "value1", "key2": "value2"},
        "null": null
      });
    });
  });
}
