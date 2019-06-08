import 'package:twooter_dart/twooter_dart.dart';
import 'package:test/test.dart';

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
  });
}
