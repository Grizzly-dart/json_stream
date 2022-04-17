export 'sync_decoder.dart';
export 'stream_decoder.dart';

class SyntaxException implements Exception {
  final int offset;

  final String message;

  SyntaxException(this.message, this.offset);

  @override
  String toString() => 'Syntax error at $offset: $message';
}
