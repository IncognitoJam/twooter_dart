import 'package:twooter_dart/twooter_dart.dart';
import 'package:test/test.dart';
import 'dart:math';

String _randomUsername({length = 10}) {
  final rng = Random();
  final characters =
      '1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';

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

      var messageIds = List<String>();
      test('Retrieve tagged messages', () async {
        final tag = '#twooter';
        messageIds = await client.getTagged(tag);

        expect(messageIds, isNotNull);
        expect(messageIds, isList);
      });

      test('Retrieve message by id', () async {
        final messageId = messageIds[0];
        final message = await client.getMessage(messageId);

        expect(message, isNotNull);
        expect(message.id, equals(messageId));
      });
    });

    group('Username tests', () {
      final username = 'flutter-app-' + _randomUsername(length: 5);
      var token;

      test('Register username', () async {
        token = await client.registerName(username);

        expect(token, isNotNull);
      });

      test('Check is active username', () async {
        final value = await client.isActiveName(username);

        expect(value, isTrue);
      });

      test('Refresh username', () async {
        final value = await client.refreshName(username, token);

        expect(value, isTrue);
      });

      test('Post message', () async {
        final message = 'Write your own Twooter client in Dart! Use the '
            'twooter_dart library on GitHub. '
            'https://github.com/IncognitoJam/twooter_dart '
            '#dartlang #twooter #dev #github';
        final value = await client.postMessage(token, username, message);

        expect(value, isNotNull);
        expect(value.length, isNonZero);
      });
    });
  });
}
