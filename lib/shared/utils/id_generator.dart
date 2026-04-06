import 'dart:math';

abstract final class IdGenerator {
  static final Random _random = Random();

  static String generate({String prefix = 'id'}) {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final salt = _random.nextInt(0x7fffffff).toRadixString(16);
    return '$prefix-$timestamp-$salt';
  }
}
