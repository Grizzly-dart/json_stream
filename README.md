# json_stream.dart

is a Dart library to parse JSON and NDJSON (newline delimited JSON).

# Decode

```dart
void main() {
  print(decode('.5'));
  print(decode('.5e5'));
  print(decode('-.5e5'));
  print(decode('"hello"'));
  print(decode('["hello", 10]'));
  print(decode('{"hello": 10}'));
}
```

# Encode

```dart
Future<void> main() async {
  print(encode("hello"));
  print(encode(5));
  print(encode(5.56));
  print(encode(null));
  print(encode(["hello", 5, null, 0.5]));
  print(encode({"key1": "value1", "key2": 5, "key3": null}));
}
```
