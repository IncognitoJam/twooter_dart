import 'package:twooter_dart/twooter_dart.dart';
import 'package:test/test.dart';
import 'dart:math';

String _randomUsername({length = 10}) {
  final rng = Random();
  final characters = '1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';

  // create 12 char string
  final charCodes = new List.generate(length, (index) {
    int n = rng.nextInt(characters.length);
    return characters.codeUnitAt(n);
  });

  return String.fromCharCodes(charCodes);
}

void main() {
  group('A group of tests', () {
    TwooterClient client;

    setUp(() {
      client = TwooterClient();
    });

    test('First Test', () async {
      final value = await client.isUp();
      expect(value, isTrue);
    });

    test('Register Random Name', () async {
      final username = 'flutter-app-' + _randomUsername(length: 5);
      final value = await client.registerName(username);
      expect(value, isNotNull);
    });
  });
}
