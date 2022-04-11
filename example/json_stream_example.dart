import 'package:json_stream/json_stream.dart';

void main() {
  print(parse('.5'));
  print(parse('.5e5'));
  print(parse('-.5e5'));
  print(parse('"hello"'));
  print(parse('["hello", 10]'));
  print(parse('{"hello": 10}'));
}
