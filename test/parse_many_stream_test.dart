import 'dart:convert';
import 'dart:io';

import 'package:json_stream/json_stream.dart';
import 'package:test/test.dart';

void main() {
  group('parse_stream.positive', () {
    test('string.basic', () async {
      var file = File('data/json/string.json').openRead();
      final v = await parseStream(file.transform(utf8.decoder));
      expect(v, 'hello');
    });
    test('string.escaped', () async {
      var file = File('data/json/string_escaped.json').openRead();
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
    test('string.unicode', () async {
      var file = File('data/json/string_escaped_unicode.json').openRead();
      final v = await parseStream(file.transform(utf8.decoder));
      expect(v, [
        "ॐ",
        "⌘",
        "🤓"
      ]);
    });
    test('int.basic', () async {
      var file = File('data/json/int.json').openRead();
      final v = await parseStream(file.transform(utf8.decoder));
      expect(v, 5);
      expect(v, isA<int>());
    });
    test('num.basic', () async {
      var file = File('data/json/num.json').openRead();
      final v = await parseStream(file.transform(utf8.decoder));
      expect(v, 0.005);
    });
    test('null.basic', () async {
      var file = File('data/json/null.json').openRead();
      final v = await parseStream(file.transform(utf8.decoder));
      expect(v, null);
    });
    test('list.basic', () async {
      var file = File('data/json/list.json').openRead();
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
      var file = File('data/json/map.json').openRead();
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
  group('parse_stream.negative', () {
    test('empty', () async {
      var file = File('data/json/negative/empty.json').openRead();
      expect(() async => await parseStream(file.transform(utf8.decoder)),
          throwsA(allOf(isA<FormatException>())));
    });
    test('empty.whitespaces', () async {
      var file = File('data/json/negative/empty_whitespaces.json').openRead();
      expect(() async => await parseStream(file.transform(utf8.decoder)),
          throwsA(allOf(isA<FormatException>())));
    });
    test('true.partial', () async {
      var file = File('data/json/negative/true_partial.json').openRead();
      expect(() async => await parseStream(file.transform(utf8.decoder)),
          throwsA(allOf(isA<FormatException>())));
    });
    test('false.partial', () async {
      var file = File('data/json/negative/false_partial.json').openRead();
      expect(() async => await parseStream(file.transform(utf8.decoder)),
          throwsA(allOf(isA<FormatException>())));
    });
    test('null.partial', () async {
      var file = File('data/json/negative/false_partial.json').openRead();
      expect(() async => await parseStream(file.transform(utf8.decoder)),
          throwsA(allOf(isA<FormatException>())));
    });
    test('int.wrong', () async {
      var file = File('data/json/negative/int_wrong.json').openRead();
      expect(() async => await parseStream(file.transform(utf8.decoder)),
          throwsA(allOf(isA<SyntaxException>())));
    });
  });
}
