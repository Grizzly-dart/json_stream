import 'package:json_stream/json_stream.dart';

void main() {
  print(decode('.5'));
  print(decode('.5e5'));
  print(decode('-.5e5'));
  print(decode('"hello"'));
  print(decode('["hello", 10]'));
  print(decode('{"hello": 10}'));
}
