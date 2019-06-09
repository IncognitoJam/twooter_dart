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
  group('Twooter Client tests', () {
    TwooterClient client;

    setUp(() {
      client = TwooterClient();
    });

    test('Check online status', () async {
      final value = await client.isUp();

      expect(value, isTrue);
    });

    group('Message tests', () {
      test('Retrieve latest messages', () async {
        final messages = await client.getMessages();

        expect(messages, isNotNull);
        expect(messages, isList);
        expect(messages, isNotEmpty);
      });

      test('Retrieve tagged messages', () async {
        final tag = '#twooter';
        final messageIds = await client.getTagged(tag);

        expect(messageIds, isNotNull);
        expect(messageIds, isList);
      });
    });

    group('Username tests', () {
      final username = 'flutter-app-' + _randomUsername(length: 5);

      test('Register username', () async {
        final value = await client.registerName(username);

        expect(value, isNotNull);
      });

      test('Check is active username', () async {
        final value = await client.isActiveName(username);

        expect(value, isTrue);
      });
    });
  });
}
